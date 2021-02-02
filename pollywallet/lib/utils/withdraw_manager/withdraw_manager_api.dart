import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pollywallet/models/bridge_api_models/bridge_api_data.dart';
import 'package:pollywallet/models/bridge_api_models/bridge_api_message.dart';
import 'package:pollywallet/models/exit_payload/exit_payload.dart';
import 'package:pollywallet/utils/network/network_config.dart';
import 'package:pollywallet/utils/network/network_manager.dart';

enum PlasmaState {
  BURNPENDING,
  BURNFAILED,
  BURNED,
  CHECKPOINTED,
  PENDINGCONFIRM,
  BADEXITHASH,
  CONFIRMFAILED,
  CONFIRMEXITABLE,
  READYTOEXIT,
  EXITED,
  EXITPENDING,
  EXITFAILED
}
enum PosState {
  FAILEDEXIT,
  FAILEDBURN,
  PENDINGBURN,
  BURNEDNOTEXITED,
  BURNEDNOTCHECKPOINTED,
  PENDING,
  BURNED,
  CHECKPOINTED,
  EXITED,
}

class WithdrawManagerApi {
  static String baseUrl = "https://bridge-api.matic.today";
  static Future<PosState> checkPosStatus(String txHash) async {
    String burnUrl = baseUrl + "/v1/pos-burn";
    String exitUrl = baseUrl + "/v1/pos-exit";
    var body = {
      "txHashes": [txHash],
    };
    Future burnFuture = http.post(burnUrl, body: jsonEncode(body));
    Future exitFuture = http.post(exitUrl, body: jsonEncode(body));
    var burnStatus = await burnFuture;
    Map json = jsonDecode(burnStatus.body);
    BridgeApiData obj;
    json.forEach((key, value) {
      obj = new BridgeApiData(
          txHash: key, message: BridgeApiMessage.fromJson(value));
    });

    BridgeApiData exitStatus;
    if (obj.message.code == -4) {
      var resp2 = await exitFuture;
      print(resp2.body);
      Map json2 = jsonDecode(resp2.body);
      json2.forEach((key, value) {
        exitStatus = new BridgeApiData(
            txHash: key, message: BridgeApiMessage.fromJson(value));
      });
      if (exitStatus.message.code == -7) {
        return PosState.PENDING;
      } else if (exitStatus.message.code == -6) {
        return PosState.FAILEDEXIT;
      } else if (exitStatus.message.code == -5) {
        return PosState.EXITED;
      } else {
        return PosState.BURNEDNOTEXITED;
      }
    } else if (obj.message.code == -5) {
      return PosState.EXITED;
    } else if (obj.message.code == -2) {
      return PosState.FAILEDBURN;
    } else if (obj.message.code == -3) {
      return PosState.BURNEDNOTCHECKPOINTED;
    } else {
      return PosState.FAILEDBURN;
    }
  }

  static Future<PlasmaState> checkPlasmaState(String txHash) async {
    String burnUrl = baseUrl + "/v1/plasma-burn";
    String confirmUrl = baseUrl + "/v1/plasma-confirm";
    String exitUrl = baseUrl + "/v1/plasma-exit";
    var body = {
      "txHashes": [txHash],
    };
    Future burnFuture = http.post(burnUrl, body: jsonEncode(body));
    Future confirmFuture = http.post(confirmUrl, body: jsonEncode(body));
    Future exitFuture = http.post(exitUrl, body: jsonEncode(body));
    var burnResp = await burnFuture;
    Map burnJson = jsonDecode(burnResp.body);
    print(burnJson);
    print(burnResp.body);
    BridgeApiData burnObj;
    burnJson.forEach((key, value) {
      burnObj = new BridgeApiData(
          txHash: key, message: BridgeApiMessage.fromJson(value));
    });
    if (burnObj.message.code == -1) {
      return PlasmaState.BURNPENDING;
    } else if (burnObj.message.code == -2) {
      return PlasmaState.BURNFAILED;
    } else if (burnObj.message.code == -3) {
      return PlasmaState.BURNED;
    } else if (burnObj.message.code == -4) {
      var confirmResp = await confirmFuture;
      Map confirmJson = jsonDecode(confirmResp);
      BridgeApiData confirmObj;
      confirmJson.forEach((key, value) {
        confirmObj = new BridgeApiData(
            txHash: key, message: BridgeApiMessage.fromJson(value));
      });
      if (confirmObj.message.code == -5) {
        return PlasmaState.PENDINGCONFIRM;
      } else if (confirmObj.message.code == -6) {
        return PlasmaState.BADEXITHASH;
      } else if (confirmObj.message.code == -7) {
        return PlasmaState.CONFIRMFAILED;
      } else if (confirmObj.message.code == -8) {
        return PlasmaState.CONFIRMEXITABLE;
      } else if (confirmObj.message.code == -9) {
        var exitResp = await exitFuture;
        Map exitJson = jsonDecode(exitResp);
        BridgeApiData exitObj;
        exitJson.forEach((key, value) {
          exitObj = new BridgeApiData(
              txHash: key, message: BridgeApiMessage.fromJson(value));
        });
        if (exitObj.message.code == -12) {
          return PlasmaState.EXITPENDING;
        } else {
          return PlasmaState.EXITFAILED;
        }
      } else if (confirmObj.message.code == -10) {
        return PlasmaState.EXITED;
      } else {
        return PlasmaState.CHECKPOINTED;
      }
    } else {
      return PlasmaState.BURNFAILED;
    }
  }

  static Future<String> plasmaExitTime(String txHash) async {
    String confirmUrl = baseUrl + "/v1/plasma-confirm";
    var body = {
      "txHashes": [txHash],
    };
    Future confirmFuture = http.post(confirmUrl, body: jsonEncode(body));
    var confirmResp = await confirmFuture;
    Map confirmJson = jsonDecode(confirmResp);
    BridgeApiData confirmObj;
    confirmJson.forEach((key, value) {
      confirmObj = new BridgeApiData(
          txHash: key, message: BridgeApiMessage.fromJson(value));
    });
    if (confirmObj.message.code == -8) {
      String str = confirmObj.message.msg.trim().split(" ")[2];
      return str;
    } else
      return null;
  }

  static Future<String> getPayloadForExit(String burnTxHash) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    String url = config.exitPayload + burnTxHash;
    var resp = await http.get(url);
    var json = jsonDecode(resp.body);
    print(resp.body);
    var payload = Payload.fromJson(json);
    if (payload.error == null) {
      return payload.result;
    } else {
      return null;
    }
  }
}

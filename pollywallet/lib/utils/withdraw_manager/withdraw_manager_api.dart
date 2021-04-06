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

  static Future<PlasmaState> checkPlasmaState(
      String txHash, String withdrawTx, String confirmTx) async {
    String burnUrl = baseUrl + "/v1/plasma-burn";
    String confirmUrl = baseUrl + "/v1/plasma-confirm";
    String exitUrl = baseUrl + "/v1/plasma-exit";
    var body1 = {
      "txHashes": [txHash],
    };

    var body2 = {
      "txHashes": [
        {"burnTxHash": txHash, "confirmTxHash": withdrawTx},
      ]
    };
    var body3 = {
      "txHashes": [confirmTx],
    };
    Future burnFuture = http.post(burnUrl, body: jsonEncode(body1));
    Future confirmFuture = http.post(confirmUrl, body: jsonEncode(body2));
    Future exitFuture = http.post(exitUrl, body: jsonEncode(body3));
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
      if (withdrawTx == "" || withdrawTx == null) {
        return PlasmaState.CHECKPOINTED;
      }
      var confirmResp = await confirmFuture;
      print(confirmUrl);
      print(exitUrl);
      Map confirmJson = jsonDecode(confirmResp.body);
      print(confirmJson);
      BridgeApiData confirmObj;
      bool badPayload = false;
      confirmJson.forEach((key, value) {
        print(value);
        if (value == "Bad Payload") {
          badPayload = true;
          return PlasmaState.BADEXITHASH;
        }
        confirmObj = new BridgeApiData(
            txHash: key, message: BridgeApiMessage.fromJson(value));
      });
      if (badPayload) {
        return PlasmaState.BADEXITHASH;
      }
      if (confirmObj.message.code == -5) {
        return PlasmaState.PENDINGCONFIRM;
      } else if (confirmObj.message.code == -6) {
        return PlasmaState.BADEXITHASH;
      } else if (confirmObj.message.code == -7) {
        return PlasmaState.CONFIRMFAILED;
      } else if (confirmObj.message.code == -8) {
        return PlasmaState.CONFIRMEXITABLE;
      } else if (confirmObj.message.code == -9) {
        if (confirmTx == "" || confirmTx == null) {
          return PlasmaState.READYTOEXIT;
        }
        var exitResp = await exitFuture;
        Map exitJson = jsonDecode(exitResp.body);
        BridgeApiData exitObj;
        exitJson.forEach((key, value) {
          print(value);
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

  static Future<String> plasmaExitTime(
      String burnTxHash, String confirmTxHash) async {
    String confirmUrl = baseUrl + "/v1/plasma-confirm";

    var body = {
      "txHashes": [
        {"burnTxHash": burnTxHash, "confirmTxHash": confirmTxHash},
      ]
    };
    Future confirmFuture = http.post(confirmUrl, body: jsonEncode(body));
    var confirmResp = await confirmFuture;
    Map confirmJson = jsonDecode(confirmResp.body);
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

  static Future<String> getPayloadForExitPos(String burnTxHash) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    String url = config.exitPayloadPos + burnTxHash;
    var resp = await http.get(url);
    var json = jsonDecode(resp.body);
    print(resp.body);
    var payload = Payload.fromJson(json);
    if (payload.result != null) {
      return payload.result;
    } else {
      return null;
    }
  }

  static Future<String> getPayloadForExitPlasma(String burnTxHash) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    String url = config.exitPayloadPlasma + burnTxHash;
    print(url);
    var resp = await http.get(url);
    var json = jsonDecode(resp.body);
    var payload = Payload.fromJson(json);
    print(payload.result);
    if (payload.result != null) {
      return payload.result;
    } else {
      return null;
    }
  }

  static Future<int> posStatusCodes(String txHash, String exitHash) async {
    String burnUrl = baseUrl + "/v1/pos-burn";
    String exitUrl = baseUrl + "/v1/pos-exit";
    var body = {
      "txHashes": [txHash],
    };
    var body2 = {
      "txHashes": [exitHash],
    };
    print(body);
    Future burnFuture = http.post(burnUrl, body: jsonEncode(body));

    var burnStatus = await burnFuture;
    Map json = jsonDecode(burnStatus.body);
    print(burnStatus.body);
    BridgeApiData obj = BridgeApiData(
        txHash: txHash, message: BridgeApiMessage.fromJson(json[txHash]));
    if (obj.message.code == -4) {
      if (exitHash != "" && exitHash != null) {
        Future exitFuture = http.post(exitUrl, body: jsonEncode(body2));
        var exitResp = await exitFuture;
        Map json2 = jsonDecode(exitResp.body);
        BridgeApiData obj2 = BridgeApiData(
            txHash: txHash,
            message: BridgeApiMessage.fromJson(json2[exitHash]));
        return obj2.message.code;
      } else {
        return obj.message.code;
      }
    } else
      return obj.message.code;
  }

  static Future<int> plasmaStatusCodes(
      String txHash, String confirmHash, String exitHash) async {
    print(confirmHash);
    String burnUrl = baseUrl + "/v1/plasma-burn";
    String confirmUrl = baseUrl + "/v1/plasma-confirm";
    String exitUrl = baseUrl + "/v1/plasma-exit";
    print(exitUrl);
    var body1 = {
      "txHashes": [txHash],
    };

    var body2 = {
      "txHashes": [
        {"burnTxHash": txHash, "confirmTxHash": confirmHash},
      ]
    };
    var body3 = {
      "txHashes": [exitHash],
    };
    Future burnFuture = http.post(burnUrl, body: jsonEncode(body1));
    Future confirmFuture = http.post(confirmUrl, body: jsonEncode(body2));
    Future exitFuture = http.post(exitUrl, body: jsonEncode(body3));
    var burnStatus = await burnFuture;
    Map json = jsonDecode(burnStatus.body);
    BridgeApiData obj = BridgeApiData(
        txHash: txHash, message: BridgeApiMessage.fromJson(json[txHash]));
    if (obj.message.code == -4) {
      if (confirmHash != "" && confirmHash != null) {
        var confirmResp = await confirmFuture;
        print(confirmResp.body);
        Map json2 = jsonDecode(confirmResp.body);
        BridgeApiData obj2 = BridgeApiData(
            txHash: confirmHash,
            message: BridgeApiMessage.fromJson(json2[confirmHash]));
        if (obj2.message.code == -9 && exitHash != "" && exitHash != null) {
          var exitResp = await exitFuture;
          Map json2 = jsonDecode(exitResp.body);
          BridgeApiData obj3 = BridgeApiData(
              txHash: exitHash,
              message: BridgeApiMessage.fromJson(json2[exitHash]));
          return obj3.message.code;
        }
        return obj2.message.code;
      } else {
        return obj.message.code;
      }
    }
    return obj.message.code;
  }
}

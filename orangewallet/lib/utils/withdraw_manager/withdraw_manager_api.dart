import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:orangewallet/models/bridge_api_models/bridge_api_data.dart';
import 'package:orangewallet/models/bridge_api_models/bridge_api_message.dart';
import 'package:orangewallet/models/exit_payload/exit_payload.dart';
import 'package:orangewallet/utils/network/network_config.dart';
import 'package:orangewallet/utils/network/network_manager.dart';

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
  static const ERC20_TRANSFER_EVENT_SIG =
      '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef';
  static const ERC721_TRANSFER_EVENT_SIG =
      '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef';
  static const ERC721_WITHDRAW_BATCH_EVENT_SIG =
      '0xf871896b17e9cb7a64941c62c188a4f5c621b86800e3d15452ece01ce56073df';
  static const ERC1155_TRANSFER_SINGLE_EVENT_SIG =
      '0xc3d58168c5ae7397731d063d5bbf3d657854427343f4c083240f7aacaa2d0f62';
  static const ERC1155_TRANSFER_BATCH_EVENT_SIG =
      '0x4a39dc06d4c0dbc64b70af90fd698a233a518aa5d07e595d983b8c0526c8f7fb';
  static const MESSAGE_SENT_EVENT_SIG =
      '0x8c5261668696ce22758910d05bab8f186d6eb247ceac2af2e82c7dc17669b036';
  static const TRANSFER_WITH_METADATA_EVENT_SIG =
      '0xf94915c6d1fd521cee85359239227480c7e8776d7caf1fc3bacad5c269b66a14';
  static const ERC721_WITHDRAW_EVENT_SIG_PLASMA =
      '0x9b1bfa7fa9ee420a16e124f794c35ac9f90472acc99140eb2f6447c714cad8eb';
  static const ERC20_WITHDRAW_EVENT_SIG_PLASMA =
      '0xebff2602b3f468259e1e99f613fed6691f3a6526effe6ef3e768ba7ae7a36c4f';
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

      Map confirmJson = jsonDecode(confirmResp.body);
      BridgeApiData confirmObj;
      bool badPayload = false;
      confirmJson.forEach((key, value) {
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
    String url = config.exitPayload + burnTxHash;
    var resp = await http.get(url);
    var json = jsonDecode(resp.body);
    var payload = Payload.fromJson(json);
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

    Future burnFuture = http.post(burnUrl, body: jsonEncode(body));

    var burnStatus = await burnFuture;
    Map json = jsonDecode(burnStatus.body);
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
    String burnUrl = baseUrl + "/v1/plasma-burn";
    String confirmUrl = baseUrl + "/v1/plasma-confirm";
    String exitUrl = baseUrl + "/v1/plasma-exit";
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
    print("plasma");
    print(body1);
    print(body2);

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

  static Future<String> getExitPayload(
      String burnTxHash, String exitSignature) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    String url = config.exitPayload +
        "/" +
        burnTxHash +
        "?eventSignature=" +
        exitSignature;
    var resp = await http.get(url);
    var json = jsonDecode(resp.body);
    var payload = Payload.fromJson(json);
    if (payload.result != null) {
      return payload.result;
    } else {
      return null;
    }
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pollywallet/models/bridge_api_models/bridge_api_data.dart';
import 'package:pollywallet/models/bridge_api_models/bridge_api_message.dart';

enum PlasmaState {
  BURNED,
  CHECKPOINTED,
  CONFIRMED,
  EXITED,
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
    Future burnFuture = http.post(burnUrl, body: body);
    Future exitFuture = http.post(exitUrl, body: body);
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
      Map json2 = jsonDecode(resp2);
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
}

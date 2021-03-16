import 'dart:convert';

import 'package:pollywallet/models/bridge_api_models/bridge_api_data.dart';
import 'package:pollywallet/models/bridge_api_models/bridge_api_message.dart';
import 'package:pollywallet/models/bridge_api_models/deposit_status_model.dart';
import 'package:pollywallet/utils/network/network_manager.dart';
import 'package:http/http.dart' as http;

class DepositBridgeApi {
  // Depoist status codes available at https://www.notion.so/maticnetwork/Bridge-API-82fe0f19b3d34c9a9853c7c44c47eb92
  static Future<BridgeApiData> depositStatusCode(String txHash) async {
    var config = await NetworkManager.getNetworkObject();
    var baseUrl = config.maticBridgeApi;
    DepositStatusModel model = DepositStatusModel(txHashes: [txHash]);
    var params = model.toJson();

    var resp =
        await http.post(baseUrl + "/v1/deposit", body: jsonEncode(params));
    BridgeApiData data = BridgeApiData(
        txHash: txHash,
        message: BridgeApiMessage.fromJson(
            jsonDecode(resp.body)["depositTxStatus"][txHash.toLowerCase()]));
    return data;
  }
}

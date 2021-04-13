import 'package:orangewallet/models/bridge_api_models/bridge_api_message.dart';

class BridgeApiData {
  final String txHash;
  final BridgeApiMessage message;

  BridgeApiData({this.txHash, this.message});
}

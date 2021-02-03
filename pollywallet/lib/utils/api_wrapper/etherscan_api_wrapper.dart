import 'dart:convert';

import 'package:pollywallet/api_key.dart';
import 'package:pollywallet/models/etherscan_models/etherescan_tx_list.dart';
import 'package:pollywallet/utils/misc/box.dart';
import 'package:pollywallet/utils/network/network_config.dart';
import 'package:pollywallet/utils/network/network_manager.dart';
import 'package:http/http.dart' as http;

class EtherscanApiWrapper {
  Future<EtherScanTxList> transactionList() async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    String address = await BoxUtils.getAddress();
    var url = config.etherscanEndpoint +
        "?module=account&action=txlist&address=" +
        address +
        "&startblock=0&endblock=99999999&sort=asc&apikey=" +
        EtherscanKey;
    var resp = await http.get(url);
    var json = jsonDecode(resp.body);
    var obj = EtherScanTxList.fromJson(json);
    return obj;
  }
}

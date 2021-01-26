import 'dart:convert';

import 'package:pollywallet/api_key.dart';
import 'package:pollywallet/models/covalent_models/covalent_token_list.dart';
import 'package:pollywallet/utils/api_wrapper/testnet_token_data.dart';
import 'package:pollywallet/utils/misc/box.dart';
import 'package:http/http.dart' as http;

class CovalentApiWrapper {
  static const baseUrl = "https://api.covalenthq.com/v1";
  static Future<CovalentTokenList> tokensMaticList() async {
    int id = await BoxUtils.getNetworkConfig();
    print(id);
    CovalentTokenList ctl;
    if (id == 0) {
      ctl = await TestNetTokenData.maticTokenList();
    } else {
      //String address = await CredentialManager.getAddress();
      String url = baseUrl +
          "/137/address/" +
          "0x3E7eb0a1ABeCF97591073970DbcED2d4924C3de0" +
          "/balances_v2/?key=" +
          CovalentKey;
      var resp = await http.get(url);
      var json = jsonDecode(resp.body);
      ctl = CovalentTokenList.fromJson(json);
    }
    return ctl;
  }

  static Future<CovalentTokenList> tokenEthList() async {
    int id = await BoxUtils.getNetworkConfig();
    print(id);
    CovalentTokenList ctl;
    if (id == 0) {
      ctl = await TestNetTokenData.goerliTokenList();
    } else {
      //String address = await CredentialManager.getAddress();
      String url = baseUrl +
          "/1/address/" +
          "0x3E7eb0a1ABeCF97591073970DbcED2d4924C3de0" +
          "/balances_v2/?key=" +
          CovalentKey;
      var resp = await http.get(url);
      var json = jsonDecode(resp.body);
      ctl = CovalentTokenList.fromJson(json);
    }
    return ctl;
  }
}

import 'dart:convert';

import 'package:pollywallet/api_key.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/covalent_models/covalent_token_list.dart';
import 'package:pollywallet/models/covalent_models/token_history.dart';
import 'package:pollywallet/utils/api_wrapper/testnet_token_data.dart';
import 'package:pollywallet/utils/misc/box.dart';
import 'package:http/http.dart' as http;
import 'package:pollywallet/utils/misc/credential_manager.dart';
import 'package:pollywallet/utils/web3_utils/ethereum_transactions.dart';
import 'package:pollywallet/utils/web3_utils/matic_transactions.dart';

class CovalentApiWrapper {
  static const baseUrl = "https://api.covalenthq.com/v1";
  static Future<CovalentTokenList> tokensMaticList() async {
    int id = await BoxUtils.getNetworkConfig();
    print(id);
    String address = await CredentialManager.getAddress();
    String url;
    CovalentTokenList ctl;
    Future future;
    if (id == 0) {
      url = baseUrl +
          "/80001/address/" +
          address +
          "/balances_v2/?key=" +
          CovalentKey;
      future = MaticTransactions.balanceOf(maticAddress);
    } else {
      //String address = await CredentialManager.getAddress();
      url = baseUrl +
          "/137/address/" +
          "0x3E7eb0a1ABeCF97591073970DbcED2d4924C3de0" +
          "/balances_v2/?key=" +
          CovalentKey;
      future = MaticTransactions.balanceOf(maticAddress);
    }

    var resp = await http.get(url);
    BigInt native = await future;
    var data = Items(
        balance: native.toString(),
        contractAddress: maticAddress,
        contractDecimals: 18,
        contractTickerSymbol: "MATIC",
        contractName: "Matic",
        logoUrl: tokenIconUrl,
        quote: 0,
        quoteRate: 0);
    var json = jsonDecode(resp.body);
    ctl = CovalentTokenList.fromJson(json);
    ctl.data.items.add(data);
    return ctl;
  }

  static Future<TokenHistory> maticTokenTransfers(
      String contractAddress) async {
    int id = await BoxUtils.getNetworkConfig();
    print(id);
    TokenHistory ctl;
    //String address = await CredentialManager.getAddress();
    String url =
        "https://api.covalenthq.com/v1/137/address/0x67DDBc63918c7FFfec530b8C1259C8Be590C883f/transfers_v2/?contract-address=0xc2132d05d31c914a87c6611c10748aeb04b58e8f&key=ckey_780ed3c9aba3496e8e9948bada0";
    var resp = await http.get(url);
    var json = jsonDecode(resp.body);
    ctl = TokenHistory.fromJson(json);

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

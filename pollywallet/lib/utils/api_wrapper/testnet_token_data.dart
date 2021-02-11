import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/covalent_models/covalent_token_list.dart';
import 'package:pollywallet/utils/web3_utils/ethereum_transactions.dart';
import 'package:pollywallet/utils/web3_utils/matic_transactions.dart';

class TestNetTokenData {
  static Future<CovalentTokenList> maticTokenList() async {
    Map<String, String> contracts = {
      "erc20Test": "0x2d7882beDcbfDDce29Ba99965dd3cdF7fcB10A1e",
      "plasmaWeth": "0x4DfAe612aaCB5b448C12A591cD0879bFa2e51d62",
      "posWeth": "0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa",
      "mrc20": "0x0000000000000000000000000000000000001010",
    };
    List<Items> ls = new List();
    List<Future> futureList = new List<Future>();
    List<String> keys = new List<String>();
    for (var key in contracts.keys) {
      Future future = MaticTransactions.balanceOf(contracts[key]);
      futureList.add(future);
      keys.add(key);
    }
    for (int i = 0; i < futureList.length; i++) {
      BigInt balance = await futureList[i];
      Items item = new Items(
          contractTickerSymbol: keys[i],
          balance: balance.toString(),
          quote: 0,
          contractName: keys[i],
          quoteRate: 0,
          contractAddress: contracts[keys[i]],
          logoUrl: tokenIconUrl,
          contractDecimals: 18);
      ls.add(item);
    }
    Data data = new Data(items: ls);
    CovalentTokenList ctl = new CovalentTokenList(data: data);
    return ctl;
  }

  static Future<CovalentTokenList> goerliTokenList() async {
    Map<String, String> contracts = {
      "erc20Test": "0x655f2166b0709cd575202630952d71e2bb0d61af",
      "plasmaWeth": "0x60D4dB9b534EF9260a88b0BED6c486fe13E604Fc",
      "ETH": ethAddress,
      "Matic": "0x499d11E0b6eAC7c0593d8Fb292DCBbF815Fb29Ae",
    };
    List<Items> ls = new List();
    List<Future> futureList = new List<Future>();
    List<String> keys = new List<String>();

    for (var key in contracts.keys) {
      Future future = EthereumTransactions.balanceOf(contracts[key]);
      futureList.add(future);
      keys.add(key);
    }
    for (int i = 0; i < futureList.length; i++) {
      BigInt balance = await futureList[i];
      Items item = new Items(
          contractTickerSymbol: keys[i],
          balance: balance.toString(),
          quote: 0,
          contractName: keys[i],
          quoteRate: 0,
          contractAddress: contracts[keys[i]],
          logoUrl: tokenIconUrl,
          contractDecimals: 18);
      ls.add(item);
    }
    Data data = new Data(items: ls);
    CovalentTokenList ctl = new CovalentTokenList(data: data);
    return ctl;
  }
}

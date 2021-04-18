import 'package:orangewallet/constants.dart';
import 'package:orangewallet/models/covalent_models/covalent_token_list.dart';
import 'package:orangewallet/utils/web3_utils/ethereum_transactions.dart';
import 'package:orangewallet/utils/web3_utils/matic_transactions.dart';

class TestNetTokenData {
  static Future<CovalentTokenList> goerliTokenList() async {
    Map<String, String> contracts = {
      "erc20Test": "0x655f2166b0709cd575202630952d71e2bb0d61af",
      "plasmaWeth": "0x60D4dB9b534EF9260a88b0BED6c486fe13E604Fc",
      "ETH": ethAddress,
      "Matic": "0x499d11E0b6eAC7c0593d8Fb292DCBbF815Fb29Ae",
    };
    Map<String, String> erc721 = {
      "erc721": "0xfa08b72137ef907deb3f202a60efbc610d2f224b",
    };
    Map<String, String> erc1155 = {
      "erc1155pos": "0x2e3Ef7931F2d0e4a7da3dea950FF3F19269d9063",
    };

    List<Items> ls = [];
    List<Future> futureList = [];
    List<String> keys = [];
    List<Future> erc721Futures = [];
    List<String> erc721Keys = [];
    List<Future> erc1155Futures = [];
    List<String> erc1155Keys = [];
    for (var key in contracts.keys) {
      Future future = EthereumTransactions.balanceOf(contracts[key]);
      futureList.add(future);
      keys.add(key);
    }
    for (var key in erc721.keys) {
      Future future = EthereumTransactions.erc721TokenId(erc721[key]);
      erc721Futures.add(future);
      erc721Keys.add(key);
    }
    for (var key in erc1155.keys) {
      Future future =
          EthereumTransactions.balanceOfERC1155(BigInt.from(123), erc1155[key]);
      erc1155Futures.add(future);
      erc1155Keys.add(key);
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
    for (int i = 0; i < erc721Futures.length; i++) {
      BigInt id = await erc721Futures[i];
      if (id == null) continue;
      Items item = new Items(
          contractTickerSymbol: erc721Keys[i],
          balance: "1",
          quote: 0,
          contractName: erc721Keys[i],
          quoteRate: 0,
          contractAddress: erc721[erc721Keys[i]],
          logoUrl: tokenIconUrl,
          nftData: [
            NftData(
                tokenId: id.toString(),
                supportsErc: ["erc20", "erc721"],
                externalData: ExternalData(
                    name: "ERC721 Test",
                    description: "ERC721 test token for matic.",
                    image:
                        "https://media.giphy.com/media/3orieKKmYyvUdR3RkY/giphy.gif"))
          ],
          contractDecimals: 0);
      ls.add(item);
    }
    for (int i = 0; i < erc1155Futures.length; i++) {
      BigInt id = BigInt.from(123);
      BigInt balance = await erc1155Futures[i];
      if (balance == null) continue;
      Items item = new Items(
          contractTickerSymbol: erc1155Keys[i],
          balance: balance.toString(),
          quote: 0,
          contractName: erc1155Keys[i],
          quoteRate: 0,
          contractAddress: erc1155[erc1155Keys[i]],
          logoUrl: tokenIconUrl,
          nftData: [
            NftData(
                tokenId: id.toString(),
                tokenBalance: balance.toString(),
                supportsErc: ["erc20", "erc1155"],
                externalData: ExternalData(
                    name: "ERC1155 Test",
                    description: "ERC1155 test token for matic.",
                    image:
                        "https://media.giphy.com/media/3orieKKmYyvUdR3RkY/giphy.gif"))
          ],
          contractDecimals: 0);
      ls.add(item);
    }
    Data data = new Data(items: ls);
    CovalentTokenList ctl = new CovalentTokenList(data: data);
    return ctl;
  }
}

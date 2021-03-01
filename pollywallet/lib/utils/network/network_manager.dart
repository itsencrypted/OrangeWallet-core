import 'package:pollywallet/utils/misc/box.dart';
import 'package:pollywallet/utils/network/network_config.dart';

import '../../constants.dart';

class NetworkManager {
  static Future<NetworkConfigObject> getNetworkObject() async {
    int id = await BoxUtils.getNetworkConfig();
    var config;
    if (id == 0) {
      config = NetworkConfig.TestnetConfig;
    } else {
      config = NetworkConfig.MainnetConfig;
    }
    NetworkConfigObject obj = new NetworkConfigObject(
        endpoint: config[endpoint],
        blockExplorerMatic: config[blockExplorerMatic],
        chainId: config[chainId],
        ethChainId: config[ethChainId],
        ethEndpoint: config[ethEndpoint],
        rootChainProxy: config[rootChainProxy],
        rootChainMatic: config[rootChainMatic],
        erc20PredicatePos: config[erc20PredicatePos],
        erc721PredicatePos: config[erc721PredicatePos],
        ethWebsocket: config[ethWebsocket],
        maticWebsocket: config[maticWebsocket],
        etherscanEndpoint: config[etherscanEndpoint],
        withdrawManagerProxy: config[withdrawManagerProxy],
        plasmaRegistry: config[plasmaRegistry],
        depositManager: config[depositManager],
        exitPayloadPos: config[exitPayloadPos],
        blockExplorerEth: config[blockExplorerEth],
        stakingEndpoint: config[stakingEndpoint],
        transakLink: config[transakLink],
        maticToken: config[maticToken],
        stakeManagerProxy: config[stakeManagerProxy],
        exitPayloadPlasma: config[exitPayloadPlasma],
        erc20PredicatePlasma: config[erc20PredicatePlasma],
        erc721PredicatePlasma: config[erc721PredicatePlasma],
        erc1155PredicatePos: config[erc1155PredicatePos]);

    return obj;
  }
}

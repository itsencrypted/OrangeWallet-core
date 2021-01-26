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
        blockExplorer: config[blockExplorer],
        chainId: config[chainId],
        ethChainId: config[ethChainId],
        ethEndpoint: config[ethEndpoint],
        rootChainProxy: config[rootChainProxy],
        rootChainMatic: config[rootChainMatic],
        erc20Predicate: config[erc20Predicate],
        erc721Predicate: config[erc721Predicate],
        ethWebsocket: config[ethWebsocket],
        maticWebsocket: config[maticWebsocket],
        etherscanEndpoint: config[etherscanEndpoint],
        withdrawManagerProxy: config[withdrawManagerProxy],
        plasmaRegistry: config[plasmaRegistry],
        depositManager: config[depositManager]);
    return obj;
  }
}

import '../../constants.dart';

class NetworkConfig {
  static const TestnetConfig = {
    endpoint: "https://rpc-mumbai.matic.today",
    blockExplorerMatic: "https://explorer-mumbai.maticvigil.com",
    blockExplorerEth: "https://goerli.etherscan.io",
    chainId: 80001,
    ethEndpoint: "https://goerli.infura.io/v3/311ef590f7e5472a90edfa1316248cff",
    ethChainId: 5,
    maticBridgeApi:
        "https://bridge-api.matic.today", // Todo: Change it to testnet
    maticWebsocket: "wss://ws-mumbai.matic.today",
    ethWebsocket:
        "wss://goerli.infura.io/ws/v3/311ef590f7e5472a90edfa1316248cff",
    rootChainProxy: "0xBbD7cBFA79faee899Eaf900F13C9065bF03B1A74",
    rootChainMatic: "0x8829EC24A1BcaCdcF4a3CBDE3A4498172e9FCDcE",
    erc20Predicate: "0xdD6596F2029e6233DEFfaCa316e6A95217d4Dc34",
    erc721Predicate: "0x74D83801586E9D3C4dc45FfCD30B54eA9C88cf9b",
    etherscanEndpoint: "https://api-goerli.etherscan.io/api",
    withdrawManagerProxy: "0x2923C8dD6Cdf6b2507ef91de74F1d5E0F11Eac53",
    plasmaRegistry: "0xeE11713Fe713b2BfF2942452517483654078154D",
    depositManager: "0x7850ec290A2e2F40B82Ed962eaf30591bb5f5C96",
    exitPayload: "https://apis.matic.network/api/v1/mumbai/pos-exit-payload/",
    stakingEndpoint: "https://staking.api.matic.network/api/v2",
  };
  static const MainnetConfig = {
    endpoint: "https://rpc-mainnet.matic.network",
    blockExplorerMatic: "https://explorer-mainnet.maticvigil.com/",
    blockExplorerEth: "https://etherscan.io",
    chainId: 137,
    ethEndpoint:
        "https://mainnet.infura.io/v3/311ef590f7e5472a90edfa1316248cff",
    ethChainId: 1,
    maticBridgeApi: "https://bridge-api.matic.today",
    maticWebsocket: "wss://ws-mainnet.matic.network",
    ethWebsocket:
        "wss://mainnet.infura.io/ws/v3/311ef590f7e5472a90edfa1316248cff",
    rootChainProxy: "0xA0c68C638235ee32657e8f720a23ceC1bFc77C77", //proxy
    rootChainMatic: "0xD4888faB8bd39A663B63161F5eE1Eae31a25B653",
    erc20Predicate: "0x886e02327cAd4E1E29688C7Db0c9d28879ac44Da",
    erc721Predicate: "0xe4924d8708D6646C0A6B2985DCFe2855211f4ddD",
    etherscanEndpoint: "https://api.etherscan.io/api",
    withdrawManagerProxy: "0x2A88696e0fFA76bAA1338F2C74497cC013495922",
    plasmaRegistry: "0x33a02E6cC863D393d6Bf231B697b82F6e499cA71",
    depositManager: "0xd505C3822C787D51d5C2B1ae9aDB943B2304eB23",
    exitPayload: "http://apis.matic.network/api/v1/matic/pos-exit-payload/",
    stakingEndpoint: "https://staking.api.matic.network/api/v1",
  };
}

class NetworkConfigObject {
  final String endpoint;
  final String blockExplorerMatic;
  final int chainId;
  final String ethEndpoint;
  final int ethChainId;
  final String rootChainProxy;
  final String rootChainMatic;
  final String erc20Predicate;
  final String erc721Predicate;
  final String maticWebsocket;
  final String ethWebsocket;
  final String maticBridgeApi;
  final String etherscanEndpoint;
  final String withdrawManagerProxy;
  final String plasmaRegistry;
  final String depositManager;
  final String exitPayload;
  final String blockExplorerEth;
  final String stakingEndpoint;
  NetworkConfigObject({
    this.endpoint,
    this.etherscanEndpoint,
    this.maticBridgeApi,
    this.blockExplorerMatic,
    this.chainId,
    this.ethChainId,
    this.ethEndpoint,
    this.rootChainProxy,
    this.rootChainMatic,
    this.erc721Predicate,
    this.erc20Predicate,
    this.ethWebsocket,
    this.maticWebsocket,
    this.withdrawManagerProxy,
    this.plasmaRegistry,
    this.depositManager,
    this.exitPayload,
    this.blockExplorerEth,
    this.stakingEndpoint,
  });
}

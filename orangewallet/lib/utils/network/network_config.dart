import 'package:orangewallet/theme_data.dart';

import '../../constants.dart';

class NetworkConfig {
  static final primary = AppTheme.primaryColor.toString();
  static final TestnetConfig = {
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
    erc20PredicatePos: "0xdD6596F2029e6233DEFfaCa316e6A95217d4Dc34",
    erc721PredicatePos: "0x74D83801586E9D3C4dc45FfCD30B54eA9C88cf9b",
    etherscanEndpoint: "https://api-goerli.etherscan.io/api",
    withdrawManagerProxy: "0x2923C8dD6Cdf6b2507ef91de74F1d5E0F11Eac53",
    plasmaRegistry: "0xeE11713Fe713b2BfF2942452517483654078154D",
    depositManager: "0x7850ec290A2e2F40B82Ed962eaf30591bb5f5C96",
    exitPayload: "https://apis.matic.network/api/v1/mumbai/exit-payload",

    stakingEndpoint: "https://staking.api.subgraph.matic.today/api/v2",
    transakLink:
        "https://staging-global.transak.com?apiKey=176a6690-e87c-4c10-ad40-cfc5e1a70599&networks=matic&defaultNetwork=matic&defaultCryptoCurrency=matic&hideMenu=true&walletAddress=",
    maticToken: "0x499d11e0b6eac7c0593d8fb292dcbbf815fb29ae",
    stakeManagerProxy: "0x00200eA4Ee292E253E6Ca07dBA5EdC07c8Aa37A3",
    erc20PredicatePlasma: "0x033a0A06dc6e78a518003C81B64f9CA80A55cb06",
    erc721PredicatePlasma: "0xDbBffd69Ef9F34bA8Fb8722157A51a4733992B35",
    erc1155PredicatePos: "0xB19a86ba1b50f0A395BfdC3557608789ee184dC8"
  };
  //apiKey=176a6690-e87c-4c10-ad40-cfc5e1a70599&
  static const MainnetConfig = {
    endpoint: "https://rpc-mainnet.matic.network",
    blockExplorerMatic: "https://explorer-mainnet.maticvigil.com/",
    blockExplorerEth: "https://etherscan.io",
    chainId: 137,
    ethEndpoint:
        "https://mainnet.infura.io/v3/311ef590f7e5472a90edfa1316248cff",
    ethChainId: 1,
    maticBridgeApi: "https://bridge-api.matic.network",
    maticWebsocket: "wss://ws-mainnet.matic.network",
    ethWebsocket:
        "wss://mainnet.infura.io/ws/v3/311ef590f7e5472a90edfa1316248cff",
    rootChainProxy: "0xA0c68C638235ee32657e8f720a23ceC1bFc77C77", //proxy
    rootChainMatic: "0xD4888faB8bd39A663B63161F5eE1Eae31a25B653",
    erc20PredicatePos: "0x40ec5B33f54e0E8A33A975908C5BA1c14e5BbbDf",
    erc721PredicatePos: "0xE6F45376f64e1F568BD1404C155e5fFD2F80F7AD",
    etherscanEndpoint: "https://api.etherscan.io/api",
    withdrawManagerProxy: "0x2A88696e0fFA76bAA1338F2C74497cC013495922",
    plasmaRegistry: "0x33a02E6cC863D393d6Bf231B697b82F6e499cA71",
    depositManager: "0x401F6c983eA34274ec46f84D70b31C151321188b",

    exitPayload: "https://apis.matic.network/api/v1/matic/exit-payload",
    stakingEndpoint: "https://staking.api.matic.network/api/v1",
    transakLink:
        "https://global.transak.com?apiKey=176a6690-e87c-4c10-ad40-cfc5e1a70599&networks=matic&defaultNetwork=matic&defaultCryptoCurrency=matic&hideMenu=true&walletAddress=",
    maticToken: "0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0",
    stakeManagerProxy: "0x5e3Ef299fDDf15eAa0432E6e66473ace8c13D908",
    erc20PredicatePlasma: "0x886e02327cAd4E1E29688C7Db0c9d28879ac44Da",
    erc721PredicatePlasma: "0xe4924d8708D6646C0A6B2985DCFe2855211f4ddD",
    erc1155PredicatePos: "0x0B9020d4E32990D67559b1317c7BF0C15D6EB88f"
  };
}

//apiKey=94a9ecae-8bbf-4c76-986b-b568df3548dc&
class NetworkConfigObject {
  final String endpoint;
  final String blockExplorerMatic;
  final int chainId;
  final String ethEndpoint;
  final int ethChainId;
  final String rootChainProxy;
  final String rootChainMatic;
  final String erc20PredicatePos;
  final String erc721PredicatePos;
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
  final String transakLink;
  final String maticToken;
  final String stakeManagerProxy;
  final String erc20PredicatePlasma;
  final String erc721PredicatePlasma;
  final String erc1155PredicatePos;
  NetworkConfigObject(
      {this.endpoint,
      this.etherscanEndpoint,
      this.maticBridgeApi,
      this.blockExplorerMatic,
      this.chainId,
      this.ethChainId,
      this.ethEndpoint,
      this.rootChainProxy,
      this.rootChainMatic,
      this.erc721PredicatePos,
      this.erc20PredicatePos,
      this.ethWebsocket,
      this.maticWebsocket,
      this.withdrawManagerProxy,
      this.plasmaRegistry,
      this.depositManager,
      this.exitPayload,
      this.blockExplorerEth,
      this.stakingEndpoint,
      this.transakLink,
      this.maticToken,
      this.stakeManagerProxy,
      this.erc20PredicatePlasma,
      this.erc721PredicatePlasma,
      this.erc1155PredicatePos});
}

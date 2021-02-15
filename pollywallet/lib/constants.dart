import 'dart:ui';

const String balanceString = "Matic Wallet Balance";
const sendButtonColor = Color(0xff8248E5);
const receiveButtonColor = Color(0xffEABC78);
const String tokenIcon = "assets/icons/token_icon.png";
const String profitIcon = "assets/icons/profit.png";
const String imageNotFoundIcon = "assets/icons/image_not_found.png";
//ABIs
const childERC20Abi = "assets/abi/childERC20.json";
const depositManagerAbi = "assets/abi/deposit_manager.json";
const erc20Abi = "assets/abi/erc20.json";
const erc20PredicateAbi = "assets/abi/erc20predicate.json";
const erc721Abi = "assets/abi/erc721.json";
const plasmaRegistryAbi = "assets/abi/plasma_registry.json";
const rootChainProxyAbi = "assets/abi/root_chain_proxy.json";
const rootChainAbi = "assets/abi/root_chain.json";
const withdrawManagerAbi = "assets/abi/withdraw_manager.json";
const stakingContractAbi = "assets/abi/staking_contract.json";
const erc1155Abi = "assets/abi/erc1155.json";

// urls
const tokenIconUrl =
    "https://icon-icons.com/downloadimage.php?id=95510&root=1385/PNG/128/&file=eur-crypto-cryptocurrency-cryptocurrencies-cash-money-bank-payment_95510.png";
// Routes
const String pinWidgetRoute = "pinWidgetRoute";
const String importMnemonicRoute = "importMnemonicRoute";
const String homeRoute = "homeRoute";
const String coinListRoute = "coinListRoute";
const String coinProfileRoute = "coinProfileRoute";
const String payAmountRoute = "payAmountRoute";
const String confirmMaticTransactionRoute = "confirmMaticTransactionRoute";
const String transactionStatusMaticRoute = "transactionStatusMaticRoute";
const String bridgeActionRoute = "bridgeActionRoute";
const String allValidatorsRoute = "allValidatorsRoute";
const String delegationRoute = "delegationRoute";
const String depositAmountRoute = "depositAmountRoute";
const String ethereumTransactionConfirmRoute =
    "ethereumTransactionConfirmRoute";
const String withdrawAmountRoute = "withdrawAmountRoute";
const String ethereumTransactionStatusRoute = "ethereumTransactionStatus";
const String withdrawsListRoute = "withdrawsListRoute";
const String transactionListRoute = "transactionListRoute";
const String receivePageRoute = "receivePageRoute";
const String exportMnemonic = "exportMnemonic";
const String networkSettingRoute = "networkSettingRoute";
const String transakRoute = "transakRoute";
const String validatorAndDelegationProfileRoute =
    "validatorAndDelegationProfileRoute";
const String delegationAmountRoute = "delegationAmountRoute";
const String accountRoute = "accountRoute";
const String pinForNewAccountRoute = "pinForNewAccountRoute";
const String nftTokenProfile = "nftTokenProfile";
const String nftTokenList = "nftTokenList";
const String stakeManagerProxy = "stakeManagerProxy";
const String stakeWithDrawAmountRoute = "stakeWithDrawAmountRoute";
const String nftDepoitSelectRoute = "nftDepoitSelectRoute";
//strings
const endpoint = "endpoint";
const blockExplorerMatic = "blockExplorerMatic";
const blockExplorerEth = "blockExplorerEth";
const chainId = "chainId";
const credentialBox = "credentialBox";
const networkBox = "networkBox";
const networkString = "network";
const ethEndpoint = "ethEndpoint";
const ethChainId = "ethChainId";
const rootChainProxy = "rootChain";
const maticWebsocket = "maticWebsocket";
const ethWebsocket = "ethWebsocket";
const rootChainMatic = "rootChainMatic";
const erc20Predicate = "erc20Predicate";
const erc721Predicate = "erc721Predicate";
const withdrawManagerProxy = "withdrawManagerProxy";
const etherscanEndpoint = "etherscanEndpoint";
const maticBridgeApi = "maticBridgeApi";
const pendingTxBox = "pendingTxBox";
const plasmaRegistry = "plasmaRegistry";
const depositManager = "depositManager";
const stakingEndpoint = "stakingEndpoint";
const exitPayload = "exitPayLoad";
const transakLink = "transakLink";
const maticToken = "maticToken";
const uintMax =
    "115792089237316195423570985008687907853269984665640564039457584007913129639935";
const ethAddress = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE";
const maticAddress = "0x0000000000000000000000000000000000001010";

//ENUMS
enum BridgeType { PLASMA, POS, NONE, BOTH }

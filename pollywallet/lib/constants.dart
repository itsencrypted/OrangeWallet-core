import 'dart:ui';

const String _baseIcon = "assets/icons";

const String balanceString = "Matic Wallet Balance";
const sendButtonColor = Color(0xff8248E5);
const receiveButtonColor = Color(0xffEABC78);
const String tokenIcon = "$_baseIcon/token_icon.png";
const String profitIcon = "$_baseIcon/profit.png";
const String imageNotFoundIcon = "$_baseIcon/image_not_found.png";
const String ethIcon = "$_baseIcon/eth_icon.png";
const String boltIcon = "$_baseIcon/bolt.png";
const String arrowIcon = "$_baseIcon/arrow.png";
const String appLandingSvg = "$_baseIcon/app_landing.svg";
const String sendingLottieJson = "$_baseIcon/sending_lottie.json";
const String sentLottieJson = "$_baseIcon/sent_lottie.json";
const String sentFailedLottieJson = "$_baseIcon/sending_failed_lottie.json";

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
const mrc20Abi = "assets/abi/mrc20.json";
const erc721ChildAbi = "assets/abi/childERC721.json";
const erc1155ChildAbi = "assets/abi/childERC1155.json";

// urls
const maticIconUrl =
    "https://logos.covalenthq.com/tokens/0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0.png";
const tokenIconUrl =
    "https://icon-icons.com/downloadimage.php?id=95510&root=1385/PNG/128/&file=eur-crypto-cryptocurrency-cryptocurrencies-cash-money-bank-payment_95510.png";
// Routes
const String appLandingRoute = "appLandingRoute";
const String importWalletRoute = "importWalletRoute";
const String landingSetPinRoute = "landingSetPinRoute";
const String createWalletRoute = 'createWalletRoute';
const String sendingStatusRoute = 'sendingStatusRoute';
const String pinWidgetRoute = "pinWidgetRoute";
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
const String sendNftRoute = "sendNftRoute";
const String burnNftRoute = "burnNftRoute";
const String erc1155DepositRoute = "erc1155DepositRoute";
const String erc1155BurnRoute = "erc1155BurnRoute";
const String walletConnectIosRoute = "walletConnectRouteIos";
const String pickTokenRoute = "pickTokenRoute";
const String walletConnectAndroidRoute = "walletConnectAndroidRoute";
const String transactionDetailsRoute = "transactionDetailsRoute";
const String notificationsScreenRoute = "notificationsScreenRoute";
const String depositStatusRoute = "depositStatusRoute";
const String splashRoute = "splashRoute";
const String withdrawStatusPosRoute = "withdrawStatusPosRoute";
const String withdrawStatusPlasmaRoute = "withdrawStatusPlasmaRoute";

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
const erc20PredicatePos = "erc20Predicate";
const erc721PredicatePos = "erc721Predicate";
const withdrawManagerProxy = "withdrawManagerProxy";
const etherscanEndpoint = "etherscanEndpoint";
const maticBridgeApi = "maticBridgeApi";
const pendingTxBox = "pendingTxBox";
const plasmaRegistry = "plasmaRegistry";
const depositManager = "depositManager";
const stakingEndpoint = "stakingEndpoint";
const exitPayloadPos = "exitPayLoadPos";
const exitPayloadPlasma = "exitPayloadPlasma";
const transakLink = "transakLink";
const maticToken = "maticToken";
const erc20PredicatePlasma = "erc20PredicatePlasma";
const erc721PredicatePlasma = "erc721PredicatePlasma";
const erc1155PredicatePos = "erc1155PredicatePos";
const uintMax =
    "115792089237316195423570985008687907853269984665640564039457584007913129639935";
const ethAddress = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE";
const maticAddress = "0x0000000000000000000000000000000000001010";
const walletconnectChannel = "com.pollywallet/walletconnect";
const addressString = "address";
const privateKeyString = "privateKey";
const wcUri = "walletConnectUri";
const depositTransactionDbBox = "depositTransactionDbBox";
const withdrawdbBox = "withdrawDbBox";
const unbondDbBox = "unbondDbBox";

//ENUMS
enum BridgeType { PLASMA, POS, NONE, BOTH }

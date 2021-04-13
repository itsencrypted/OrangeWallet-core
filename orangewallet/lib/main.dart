import 'package:flutter/material.dart';
import 'package:orangewallet/screens/bridge/select_deposit_bridge.dart';
import 'package:orangewallet/screens/deposit/erc1155_deposit.dart';
import 'package:orangewallet/screens/deposit/nft_select.dart';
import 'package:orangewallet/screens/landing/app_landing.dart';
import 'package:orangewallet/screens/landing/create_wallet.dart';
import 'package:orangewallet/screens/landing/import_wallet.dart';
import 'package:orangewallet/screens/landing/landing_set_pin.dart';
import 'package:orangewallet/screens/new_account_pin_screen.dart';
import 'package:orangewallet/screens/notifications/notifications_screen.dart';
import 'package:orangewallet/screens/receive/receive.dart';
import 'package:orangewallet/screens/send_token/pick_token.dart';
import 'package:orangewallet/screens/send_token/send_nft.dart';
import 'package:orangewallet/screens/settings_screen/export_mnemonic.dart';
import 'package:orangewallet/screens/settings_screen/accounts.dart';
import 'package:orangewallet/screens/settings_screen/network.dart';
import 'package:orangewallet/screens/splash.dart';
import 'package:orangewallet/screens/staking/delegation_screen/delegation_stake_amount.dart';
import 'package:orangewallet/screens/staking/validator_and_delegation_profile.dart';
import 'package:orangewallet/screens/token_list/nft_list_full.dart';
import 'package:orangewallet/screens/token_profile/nft_profile.dart';
import 'package:orangewallet/screens/transaction_list/transactions_screen.dart';
import 'package:orangewallet/screens/transaction_status/deposit_status.dart';
import 'package:orangewallet/screens/transaction_status/sending_status.dart';
import 'package:orangewallet/screens/transaction_status/transaction_details.dart';
import 'package:orangewallet/screens/transaction_status/transaction_status_ethereum.dart';
import 'package:orangewallet/screens/transaction_status/transaction_status_matic.dart';
import 'package:orangewallet/screens/transaction_status/withdraw_status_plasma.dart';
import 'package:orangewallet/screens/transaction_status/withdraw_status_pos.dart';
import 'package:orangewallet/screens/transak_webview.dart';
import 'package:orangewallet/screens/verify_mnemonic.dart';
import 'package:orangewallet/screens/wallet_connect/wallet_connect_android.dart';
import 'package:orangewallet/screens/wallet_connect/wallet_connect_ios.dart';
import 'package:orangewallet/screens/withdraw/burn_erc1155.dart';
import 'package:orangewallet/screens/withdraw/burn_nft.dart';
import 'package:orangewallet/state_manager/staking_data/delegation_data_state/delegations_data_cubit.dart';
import 'package:orangewallet/state_manager/staking_data/validator_data/validator_data_cubit.dart';
import 'package:orangewallet/state_manager/withdraw_burn_state/withdraw_burn_data_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orangewallet/constants.dart';
import 'package:orangewallet/screens/bridge/bridge_actions.dart';
import 'package:orangewallet/screens/deposit/deposit_screen.dart';
import 'package:orangewallet/screens/home/home.dart';
import 'package:orangewallet/screens/pin_widget.dart';
import 'package:orangewallet/screens/send_token/token_amount.dart';
import 'package:orangewallet/screens/staking/delegation_screen/delegation_screen.dart';
import 'package:orangewallet/screens/staking/validators_screen/all_validators.dart';
import 'package:orangewallet/screens/token_list/token_list.dart';
import 'package:orangewallet/screens/token_profile/coin_profile.dart';
import 'package:orangewallet/screens/transaction_confirmation_screen/ethereum_transaction_confirmation.dart';
import 'package:orangewallet/screens/transaction_confirmation_screen/matic_transaction_confirmation.dart';
import 'package:orangewallet/screens/withdraw/withdraw_amount.dart';
import 'package:orangewallet/state_manager/covalent_states/covalent_token_list_cubit_ethereum.dart';
import 'package:orangewallet/state_manager/covalent_states/covalent_token_list_cubit_matic.dart';
import 'package:orangewallet/state_manager/deposit_data_state/deposit_data_cubit.dart';
import 'package:orangewallet/state_manager/send_token_state/send_token_cubit.dart';
import 'package:orangewallet/theme_data.dart';
import 'package:flutter/services.dart';
import 'package:orangewallet/utils/misc/box.dart';

void main() {
  runApp(OrangeWallet());
}

class OrangeWallet extends StatefulWidget {
  @override
  _OrangeWalletState createState() => _OrangeWalletState();
}

class _OrangeWalletState extends State<OrangeWallet> {
  SendTransactionCubit data;
  Widget current = Splash();

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: AppTheme.backgroundWhite,
        statusBarColor: AppTheme.backgroundWhite,
        statusBarBrightness: Brightness.light,
        systemNavigationBarDividerColor: AppTheme.backgroundWhite,
        systemNavigationBarIconBrightness: Brightness.dark));
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    BoxUtils.initializeHive().then((value) {
      BoxUtils.checkLogin().then((bool status) {
        if (status) {
          setState(() {
            current = Home();
          });
        } else {
          setState(() {
            current = AppLandingScreen();
          });
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider<CovalentTokensListMaticCubit>(
            create: (BuildContext context) => CovalentTokensListMaticCubit(),
          ),
          BlocProvider<SendTransactionCubit>(
              create: (BuildContext context) => SendTransactionCubit()),
          BlocProvider<DepositDataCubit>(
              create: (BuildContext context) => DepositDataCubit()),
          BlocProvider<CovalentTokensListEthCubit>(
              create: (BuildContext context) => CovalentTokensListEthCubit()),
          BlocProvider<WithdrawBurnDataCubit>(
              create: (BuildContext context) => WithdrawBurnDataCubit()),
          BlocProvider<ValidatorsdataCubit>(
              create: (BuildContext context) => ValidatorsdataCubit()),
          BlocProvider<DelegationsDataCubit>(
              create: (BuildContext context) => DelegationsDataCubit())
        ],
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'OrangeWallet',
            theme: ThemeData(
              scaffoldBackgroundColor: AppTheme.backgroundWhite,
              primaryTextTheme: AppTheme.textTheme,
              appBarTheme: AppBarTheme(
                  iconTheme: IconThemeData(color: AppTheme.black),
                  brightness: Brightness.light,
                  elevation: 0,
                  color: AppTheme.backgroundWhite),
              platform: TargetPlatform.iOS,
              backgroundColor: AppTheme.backgroundWhite,
              textTheme: Typography.blackCupertino,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            routes: {
              appLandingRoute: (context) => AppLandingScreen(),
              importWalletRoute: (context) => ImportWalletScreen(),
              landingSetPinRoute: (context) => LandingSetPinScreen(),
              createWalletRoute: (context) => CreateWalletScreen(),
              pinWidgetRoute: (context) => PinWidget(),
              sendingStatusRoute: (context) => SendingStatusScreen(),
              homeRoute: (context) => Home(),
              coinListRoute: (context) => TokenList(),
              coinProfileRoute: (context) => CoinProfile(),
              payAmountRoute: (context) => SendTokenAmount(),
              confirmMaticTransactionRoute: (context) =>
                  MaticTransactionConfirm(),
              transactionStatusMaticRoute: (context) =>
                  TransactionStatusMatic(),
              bridgeActionRoute: (context) => BridgeTransfers(),
              allValidatorsRoute: (context) => AllValidators(),
              depositAmountRoute: (context) => DepositScreen(),
              delegationRoute: (context) => DelegationScreen(),
              ethereumTransactionConfirmRoute: (context) =>
                  EthTransactionConfirmation(),
              ethereumTransactionStatusRoute: (context) =>
                  TransactionStatusEthereum(),
              withdrawAmountRoute: (context) => WithdrawScreen(),
              transactionListRoute: (context) => TransactionList(),
              receivePageRoute: (context) => Receive(),
              networkSettingRoute: (context) => NetworkSetting(),
              transakRoute: (context) => TransakWebView(),
              exportMnemonic: (context) => ExportMnemonic(),
              validatorAndDelegationProfileRoute: (context) =>
                  ValidatorAndDelegationProfile(),
              delegationAmountRoute: (context) => DelegationAmount(),
              pinForNewAccountRoute: (context) => NewAccountPinWidget(),
              accountRoute: (context) => AccountSelection(),
              nftTokenList: (context) => FullNftList(),
              nftTokenProfile: (context) => NftProfile(),
              nftDepoitSelectRoute: (context) => NftSelectDeposit(),
              sendNftRoute: (context) => SendNft(),
              burnNftRoute: (context) => NftBurn(),
              erc1155DepositRoute: (context) => Erc1155Deposit(),
              erc1155BurnRoute: (context) => Erc1155Burn(),
              walletConnectIosRoute: (context) => WalletConnectIos(),
              pickTokenRoute: (context) => PickTokenList(),
              walletConnectAndroidRoute: (context) => WalletConnectAndroid(),
              transactionDetailsRoute: (context) => TransactionDetails(),
              notificationsScreenRoute: (context) => NotificationsScreen(),
              depositStatusRoute: (context) => DepositStatus(),
              splashRoute: (context) => Splash(),
              withdrawStatusPosRoute: (context) => WithdrawStatusPos(),
              withdrawStatusPlasmaRoute: (context) => WithdrawStatusPlasma(),
              selectBridgeRoute: (context) => SelectBridge(),
              verifyMnemonic: (context) => VerifyMnemonic()
            },
            home: current),
      ),
    );
  }
}

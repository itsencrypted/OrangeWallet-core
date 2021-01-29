import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/screens/bridge/bridge_actions.dart';
import 'package:pollywallet/screens/deposit/deposit_screen.dart';
import 'package:pollywallet/screens/home/home.dart';
import 'package:pollywallet/screens/landing/landing.dart';
import 'package:pollywallet/screens/pin_widget.dart';
import 'package:pollywallet/screens/send_token/token_amount.dart';
import 'package:pollywallet/screens/token_list/token_list.dart';
import 'package:pollywallet/screens/token_profile/coin_profile.dart';
import 'package:pollywallet/screens/transaction_confirmation_screen/matic_transaction_confirmation.dart';
import 'package:pollywallet/screens/transaction_status/transaction_status_matic.dart';
import 'package:pollywallet/state_manager/covalent_states/covalent_token_list_cubit_ethereum.dart';
import 'package:pollywallet/state_manager/covalent_states/covalent_token_list_cubit_matic.dart';
import 'package:pollywallet/state_manager/deposit_data_state/deposit_data_cubit.dart';
import 'package:pollywallet/state_manager/send_token_state/send_token_cubit.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:flutter/services.dart';
import 'package:pollywallet/utils/misc/box.dart';

void main() {
  runApp(PollyWallet());
}

class PollyWallet extends StatefulWidget {
  @override
  _PollyWalletState createState() => _PollyWalletState();
}

class _PollyWalletState extends State<PollyWallet> {
  SendTransactionCubit data;
  Widget current = ImportMnemonic();

  @override
  void initState() {
    BoxUtils.initializeHive().then((value) {
      BoxUtils.checkLogin().then((bool status) {
        if (status) {
          setState(() {
            current = Home();
          });
        } else {
          setState(() {
            current = ImportMnemonic();
          });
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor:
            AppTheme.backgroundWhite, // navigation bar color
        statusBarColor: AppTheme.backgroundWhite,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
        systemNavigationBarDividerColor: AppTheme.backgroundWhite,
        systemNavigationBarIconBrightness: Brightness.light // status bar color
        ));
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
        ],
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'PollyWallet',
            theme: ThemeData(
              scaffoldBackgroundColor: AppTheme.backgroundWhite,
              primaryTextTheme: AppTheme.textTheme,
              appBarTheme: AppBarTheme(
                  iconTheme: IconThemeData(color: AppTheme.black),
                  brightness: Brightness.light,
                  elevation: 0,
                  backgroundColor: AppTheme.backgroundWhite),
              platform: TargetPlatform.iOS,
              backgroundColor: AppTheme.backgroundWhite,
              textTheme: Typography.blackCupertino,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            routes: {
              pinWidgetRoute: (context) => PinWidget(),
              homeRoute: (context) => Home(),
              coinListRoute: (context) => TokenList(),
              coinProfileRoute: (context) => CoinProfile(),
              payAmountRoute: (context) => SendTokenAmount(),
              confirmMaticTransactionRoute: (context) =>
                  MaticTransactionConfirm(),
              transactionStatusMaticRoute: (context) =>
                  MaticTransactionStatus(),
              bridgeActionRoute: (context) => BridgeTransfers(),
              depositAmountRoute: (context) => DepositScreen(),
            },
            home: current),
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/screens/home/home.dart';
import 'package:pollywallet/screens/landing/landing.dart';
import 'package:pollywallet/screens/pin_widget.dart';
import 'package:pollywallet/state_manager/covalent_states/covalent_token_list_cubit.dart';
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
          BlocProvider<CovalentTokensListCubit>(
            create: (BuildContext context) => CovalentTokensListCubit(),
          ),
          BlocProvider<SendTransactionCubit>(
              create: (BuildContext context) => SendTransactionCubit()),
          BlocProvider<DepositDataCubit>(
              create: (BuildContext context) => DepositDataCubit()),
        ],
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'PollyWallet',
            theme: ThemeData(
              platform: TargetPlatform.iOS,
              backgroundColor: AppTheme.backgroundWhite,
              textTheme: Typography.blackCupertino,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            routes: {
              pinWidgetRoute: (context) => PinWidget(),
              homeRoute: (context) => Home()
            },
            home: current),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/screens/bridge/token_list_tile_bridge.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pollywallet/state_manager/covalent_states/covalent_token_list_cubit_matic.dart';
import 'package:pollywallet/theme_data.dart';

class WithdrawTokenList extends StatefulWidget {
  @override
  _WithdrawTokenListState createState() => _WithdrawTokenListState();
}

class _WithdrawTokenListState extends State<WithdrawTokenList> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CovalentTokensListMaticCubit,
        CovalentTokensListMaticState>(
      builder: (context, state) {
        if (state is CovalentTokensListMaticInitial) {
          return SpinKitFadingFour(
            size: 40,
            color: AppTheme.primaryColor,
          );
        } else if (state is CovalentTokensListMaticLoading) {
          return SpinKitFadingFour(
            size: 40,
            color: AppTheme.primaryColor,
          );
        } else if (state is CovalentTokensListMaticLoaded) {
          if (state.covalentTokenList.data.items.length == 0) {
            return Center(
              child: Text(
                "No tokens",
                style: AppTheme.title,
              ),
            );
          }
          var ls = state.covalentTokenList.data.items.reversed.toList();
          return ListView.builder(
            itemCount: ls.length,
            itemBuilder: (context, index) {
              return TokenListTileBridge(
                tokenData: ls[index],
                action: 1,
              );
            },
          );
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Something went wrong"),
              RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  color: sendButtonColor.withOpacity(0.6),
                  child: Text("Refresh"),
                  onPressed: () {}),
            ],
          );
        }
      },
    );
  }
}
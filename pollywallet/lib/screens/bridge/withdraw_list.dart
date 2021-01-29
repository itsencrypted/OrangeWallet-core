import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/screens/bridge/token_list_tile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pollywallet/state_manager/covalent_states/covalent_token_list_cubit.dart';
import 'package:pollywallet/theme_data.dart';

class WithdrawTokenList extends StatefulWidget {
  @override
  _WithdrawTokenListState createState() => _WithdrawTokenListState();
}

class _WithdrawTokenListState extends State<WithdrawTokenList> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CovalentTokensListCubit, CovalentTokensListState>(
      builder: (context, state) {
        if (state is CovalentTokensListInitial) {
          return SpinKitFadingFour(
            size: 40,
            color: AppTheme.primaryColor,
          );
        } else if (state is CovalentTokensListLoading) {
          return SpinKitFadingFour(
            size: 40,
            color: AppTheme.primaryColor,
          );
        } else if (state is CovalentTokensListLoaded) {
          if (state.covalentTokenList.data.items.length == 0) {
            return Center(
              child: Text(
                "No tokens",
                style: AppTheme.title,
              ),
            );
          }
          var ls = state.covalentTokenList.data.items.reversed.toList();
          return Expanded(
            child: ListView.builder(
              itemCount: ls.length,
              itemBuilder: (context, index) {
                return TokenListTileBridge(
                  tokenData: ls[index],
                  action: 1,
                );
              },
            ),
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

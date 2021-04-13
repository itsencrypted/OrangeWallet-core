import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:orangewallet/constants.dart';
import 'package:orangewallet/screens/bridge/token_list_tile_bridge.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orangewallet/state_manager/covalent_states/covalent_token_list_cubit_matic.dart';
import 'package:orangewallet/theme_data.dart';

class WithdrawTokenList extends StatefulWidget {
  @override
  _WithdrawTokenListState createState() => _WithdrawTokenListState();
}

class _WithdrawTokenListState extends State<WithdrawTokenList> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      var tokenListCubit = context.read<CovalentTokensListMaticCubit>();

      _refreshLoop(tokenListCubit);
    });
    super.initState();
  }

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
          var ls = state.covalentTokenList.data.items.toList();
          return ListView.builder(
            itemCount: ls.length,
            itemBuilder: (context, index) {
              if (ls[index].type == "nft" && ls[index].balance == "0") {
                return Container();
              }
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

  _refreshLoop(CovalentTokensListMaticCubit maticCubit) {
    new Timer.periodic(Duration(seconds: 30), (Timer t) {
      if (mounted) {
        maticCubit.refresh();
      }
    });
  }
}

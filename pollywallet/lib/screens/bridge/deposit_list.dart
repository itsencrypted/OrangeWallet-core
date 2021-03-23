import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pollywallet/screens/bridge/token_list_tile_bridge.dart';
import 'package:pollywallet/state_manager/covalent_states/covalent_token_list_cubit_ethereum.dart';
import 'package:pollywallet/theme_data.dart';

class DepositTokenList extends StatefulWidget {
  DepositTokenList({Key key}) : super(key: key);

  @override
  _DepositTokenListState createState() => _DepositTokenListState();
}

class _DepositTokenListState extends State<DepositTokenList> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final tokenListCubit = context.read<CovalentTokensListEthCubit>();
      _refreshLoop(tokenListCubit);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CovalentTokensListEthCubit, CovalentTokensListEthState>(
      builder: (context, state) {
        if (state is CovalentTokensListEthLoaded) {
          var ls = state.covalentTokenList.data.items.reversed.toList();
          return ListView.builder(
            itemCount: ls.length,
            itemBuilder: (context, index) {
              return TokenListTileBridge(
                tokenData: ls[index],
                action: 0,
              );
            },
          );
        } else if (state is CovalentTokensListEthError) {
          return Center(
            child: Text("Something Went Wrong"),
          );
        } else {
          return Center(
            child: SpinKitFadingFour(
              size: 50,
              color: AppTheme.primaryColor,
            ),
          );
        }
      },
    );
  }

  _refreshLoop(CovalentTokensListEthCubit cubit) {
    new Timer.periodic(Duration(seconds: 30), (Timer t) {
      if (mounted) {
        cubit.refresh();
      }
    });
  }
}

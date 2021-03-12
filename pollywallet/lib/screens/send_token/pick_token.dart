import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/screens/send_token/pick_token_file.dart';
import 'package:pollywallet/state_manager/covalent_states/covalent_token_list_cubit_matic.dart';
import 'package:pollywallet/state_manager/send_token_state/send_token_cubit.dart';
import 'package:pollywallet/theme_data.dart';

class PickTokenList extends StatefulWidget {
  @override
  _PickTokenListState createState() => _PickTokenListState();
}

class _PickTokenListState extends State<PickTokenList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose a coin to send"),
        actions: [IconButton(icon: Icon(Icons.search), onPressed: () {})],
      ),
      body: BlocBuilder<CovalentTokensListMaticCubit,
          CovalentTokensListMaticState>(builder: (context, listState) {
        return BlocBuilder<SendTransactionCubit, SendTransactionState>(
            builder: (context, tokenState) {
          if (listState is CovalentTokensListMaticInitial) {
            return SpinKitFadingFour(
              size: 40,
              color: AppTheme.primaryColor,
            );
          } else if (listState is CovalentTokensListMaticLoading) {
            return SpinKitFadingFour(
              size: 40,
              color: AppTheme.primaryColor,
            );
          } else if (listState is CovalentTokensListMaticLoaded &&
              tokenState is SendTransactionFinal) {
            if (listState.covalentTokenList.data.items.length == 0) {
              return Center(
                child: Text(
                  "No tokens",
                  style: AppTheme.title,
                ),
              );
            }
            var ls = listState.covalentTokenList.data.items
                .where((element) => element.nftData == null)
                .toList();
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                itemCount: ls.length,
                itemBuilder: (context, index) {
                  var token = ls[index];
                  return PickTokenTile(
                    address: tokenState.data.receiver,
                    tokenData: token,
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
                    onPressed: _initializeAgain()),
              ],
            );
          }
        });
      }),
    );
  }

  _initializeAgain() async {
    final tokenListCubit = context.read<CovalentTokensListMaticCubit>();
    await tokenListCubit.getTokensList();
  }

  Future<void> _refresh() async {
    final tokenListCubit = context.read<CovalentTokensListMaticCubit>();
    await tokenListCubit.refresh();
  }
}

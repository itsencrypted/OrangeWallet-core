import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/screens/token_list/coin_list_tile.dart';
import 'package:pollywallet/screens/token_list/nft_list_tile.dart';
import 'package:pollywallet/state_manager/covalent_states/covalent_token_list_cubit_matic.dart';
import 'package:pollywallet/theme_data.dart';

class FullNftList extends StatefulWidget {
  @override
  _FullNftListState createState() => _FullNftListState();
}

class _FullNftListState extends State<FullNftList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Coins"),
        actions: [IconButton(icon: Icon(Icons.search), onPressed: () {})],
      ),
      body: BlocBuilder<CovalentTokensListMaticCubit,
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
            var ls = state.covalentTokenList.data.items
                .where((element) => element.nftData != null)
                .toList();
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                itemCount: ls.length,
                itemBuilder: (context, index) {
                  var token = ls[index];
                  return NftTileCard(
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
        },
      ),
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

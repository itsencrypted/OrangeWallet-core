import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/screens/token_list/coin_list_tile_with_card.dart';
import 'package:pollywallet/state_manager/covalent_states/covalent_token_list_cubit.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/misc/box.dart';

class TokenList extends StatefulWidget {
  @override
  _TokenListState createState() => _TokenListState();
}

class _TokenListState extends State<TokenList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Coins"),
        actions: [IconButton(icon: Icon(Icons.search), onPressed: () {})],
      ),
      body: BlocBuilder<CovalentTokensListCubit, CovalentTokensListState>(
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
            return ListView.builder(
              itemCount: ls.length,
              itemBuilder: (context, index) {
                var token = ls[index];
                return CoinListTileWithCard(
                  tokenData: token,
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
                    onPressed: _refresh()),
              ],
            );
          }
        },
      ),
    );
  }

  _refresh() async {
    final tokenListCubit = context.read<CovalentTokensListCubit>();
    int id = await BoxUtils.getNetworkConfig();
    tokenListCubit.getTokensList(0);
  }
}

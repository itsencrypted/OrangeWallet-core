import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/screens/wallet_tab/coin_list.dart';
import 'package:pollywallet/screens/wallet_tab/top_balance.dart';
import 'package:pollywallet/screens/wallet_tab/transfer_asset_card.dart';
import 'package:pollywallet/state_manager/covalent_states/covalent_token_list_cubit.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/misc/box.dart';
import 'package:pollywallet/utils/network/network_manager.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab>
    with AutomaticKeepAliveClientMixin<HomeTab> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final tokenListCubit = context.read<CovalentTokensListCubit>();
      tokenListCubit.getTokensList(0);
    });
    super.initState();
  }

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
          var amt = 0.0;
          if (state.covalentTokenList.data.items.length > 0) {
            amt = state.covalentTokenList.data.items[0].quote;
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListView(children: [
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 50),
                child: TopBalance(amt.toString()),
              ),
              TransferAssetCard(),
              CoinListCard(
                tokens: state.covalentTokenList.data.items,
              ),
            ]),
          );
        } else {
          // (state is CovalentTokensListError)
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
    );
  }

  _refresh() async {
    final tokenListCubit = context.read<CovalentTokensListCubit>();
    int id = await BoxUtils.getNetworkConfig();
    tokenListCubit.getTokensList(0);
  }

  @override
  bool get wantKeepAlive => true;
}
// Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8.0),
//         child: ListView(children: [
//           Padding(
//             padding: const EdgeInsets.only(top: 30, bottom: 50),
//             child: TopBalance("256.53"),
//           ),
//           TransferAssetCard(),
//           CoinListCard(),
//         ]),
//       )

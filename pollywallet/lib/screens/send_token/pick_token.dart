import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/covalent_models/covalent_token_list.dart';
import 'package:pollywallet/screens/send_token/pick_token_file.dart';
import 'package:pollywallet/state_manager/covalent_states/covalent_token_list_cubit_matic.dart';
import 'package:pollywallet/state_manager/send_token_state/send_token_cubit.dart';
import 'package:pollywallet/theme_data.dart';

class PickTokenList extends StatefulWidget {
  @override
  _PickTokenListState createState() => _PickTokenListState();
}

class _PickTokenListState extends State<PickTokenList> {
  TextEditingController controller = TextEditingController();
  SearchBar searchBar;
  String searchStr = "";
  bool showSearch = false;
  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
        title: new Text('All Tokens'),
        actions: [searchBar.getSearchAction(context)]);
  }

  _TokenListState() {
    searchBar = new SearchBar(
        inBar: showSearch,
        buildDefaultAppBar: buildAppBar,
        setState: setState,
        hintText: "Token Name",
        controller: controller,
        showClearButton: true,
        onSubmitted: onSubmitted,
        onCleared: onClear,
        onClosed: onClose);
  }

  @override
  void initState() {
    controller.addListener(_search);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose a token to send"),
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

            var original = ls;
            if (searchStr != "") {
              ls = ls.where(_searchCond).toList();
            } else {
              ls = original;
            }
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Something went wrong"),
                  RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      color: sendButtonColor.withOpacity(0.6),
                      child: Text("Refresh"),
                      onPressed: () {
                        _initializeAgain();
                      }),
                ],
              ),
            );
          }
        });
      }),
    );
  }

  void onSubmitted(String value) {}
  void onClear() {
    setState(() {
      searchStr = "";

      controller.text = "";
    });
  }

  _search() {
    setState(() {
      searchStr = controller.text;
    });
  }

  void onClose() {
    setState(() {
      searchStr = "";
      controller.text = "";
      showSearch = false;
    });
  }

  bool _searchCond(Items item) {
    var name = item.contractName;

    return name.toLowerCase().contains(searchStr.toLowerCase());
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

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:orangewallet/constants.dart';
import 'package:orangewallet/models/covalent_models/covalent_token_list.dart';
import 'package:orangewallet/models/transaction_data/transaction_data.dart';
import 'package:orangewallet/state_manager/covalent_states/covalent_token_list_cubit_ethereum.dart';
import 'package:orangewallet/state_manager/deposit_data_state/deposit_data_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orangewallet/theme_data.dart';
import 'package:orangewallet/utils/network/network_config.dart';
import 'package:orangewallet/utils/network/network_manager.dart';
import 'package:orangewallet/utils/web3_utils/eth_conversions.dart';
import 'package:orangewallet/utils/web3_utils/ethereum_transactions.dart';
import 'package:orangewallet/widgets/colored_tabbar.dart';
import 'package:orangewallet/widgets/loading_indicator.dart';
import 'package:orangewallet/widgets/nft_tile.dart';
import 'package:web3dart/web3dart.dart';

class Erc1155Deposit extends StatefulWidget {
  @override
  _Erc1155DepositState createState() => _Erc1155DepositState();
}

class _Erc1155DepositState extends State<Erc1155Deposit>
    with SingleTickerProviderStateMixin {
  DepositDataCubit data;
  BuildContext context;
  int bridge = 0;
  double balance;
  List<_Erc1155DepositData> selectedData = [];
  int args; // 0 no bridge , 1 = pos , 2 = plasma , 3 both
  int index = 0;
  TabController _controller;
  var ethCubit;
  @override
  initState() {
    Future.delayed(Duration.zero, () {
      _controller = TabController(length: 2, vsync: this);

      _refreshLoop(ethCubit);
      _controller.addListener(() {
        if (_controller.index == 0) {
          bridge = 1;
        } else {
          bridge = 2;
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ethCubit = context.read<CovalentTokensListEthCubit>();
    this.data = context.read<DepositDataCubit>();
    this.args = ModalRoute.of(context).settings.arguments;

    if (args == 3 && bridge == 0) {
      bridge = 1;
    } else if (args != 3) {
      bridge = args;
    }

    return BlocBuilder<DepositDataCubit, DepositDataState>(
      builder: (BuildContext context, state) {
        return BlocBuilder<CovalentTokensListEthCubit,
                CovalentTokensListEthState>(
            builder: (BuildContext context, tokenState) {
          if (state is DepositDataFinal &&
              tokenState is CovalentTokensListEthLoaded) {
            var token = tokenState.covalentTokenList.data.items
                .where((element) =>
                    element.contractAddress == state.data.token.contractAddress)
                .first;
            var balance = EthConversions.weiToEth(
                BigInt.parse(token.balance), token.contractDecimals);
            this.balance = balance;
            return Scaffold(
              appBar: AppBar(
                  title: Text("Deposit to Matic"),
                  bottom: args == 3
                      ? ColoredTabBar(
                          tabBar: TabBar(
                            controller: _controller,
                            labelStyle: AppTheme.tabbarTextStyle,
                            unselectedLabelStyle: AppTheme.tabbarTextStyle,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: AppTheme.white),
                            tabs: [
                              Tab(
                                child: Align(
                                  child: Text(
                                    'POS',
                                    style: AppTheme.tabbarTextStyle,
                                  ),
                                ),
                              ),
                              Tab(
                                child: Align(
                                  child: Text(
                                    'Plasma',
                                    style: AppTheme.tabbarTextStyle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          borderRadius: AppTheme.cardRadius,
                          color: AppTheme.tabbarBGColor,
                          tabbarMargin: AppTheme.cardRadius,
                          tabbarPadding: AppTheme.paddingHeight / 4,
                        )
                      : null),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.73,
                      child: ListView.builder(
                        itemCount: state.data.token.nftData.length,
                        itemBuilder: (context, index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              FlatButton(
                                onPressed: () {
                                  setState(() {
                                    selectedData
                                            .where((element) =>
                                                element.index == index)
                                            .isNotEmpty
                                        ? selectedData.removeWhere(
                                            (element) => element.index == index)
                                        : selectedData
                                            .add(_Erc1155DepositData(1, index));
                                  });
                                },
                                padding: EdgeInsets.all(0),
                                child: NftDepositTile(
                                  data: token.nftData[index],
                                  selected: selectedData
                                      .where(
                                          (element) => element.index == index)
                                      .isNotEmpty,
                                ),
                              ),
                              selectedData
                                      .where(
                                          (element) => element.index == index)
                                      .isNotEmpty
                                  ? Text(
                                      "Amount to deposit",
                                      style: AppTheme.subtitle,
                                    )
                                  : Container(),
                              selectedData
                                      .where(
                                          (element) => element.index == index)
                                      .isNotEmpty
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 30,
                                          child: FlatButton(
                                            padding: EdgeInsets.all(0),
                                            onPressed: () {
                                              if (selectedData
                                                      .where((element) =>
                                                          element.index ==
                                                          index)
                                                      .first
                                                      .count >
                                                  1) {
                                                setState(() {
                                                  selectedData
                                                      .where((element) =>
                                                          element.index ==
                                                          index)
                                                      .first
                                                      .count--;
                                                });
                                              }
                                            },
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            child: ClipOval(
                                                child: Material(
                                              color: AppTheme.white,
                                              child: SizedBox(
                                                  height: 30,
                                                  width: 30,
                                                  child:
                                                      Center(child: Text("-"))),
                                            )),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Text(selectedData.isEmpty ||
                                                  selectedData
                                                      .where((element) =>
                                                          element.index ==
                                                          index)
                                                      .isEmpty
                                              ? "0"
                                              : selectedData[index]
                                                  .count
                                                  .toString()),
                                        ),
                                        SizedBox(
                                          width: 30,
                                          child: FlatButton(
                                            padding: EdgeInsets.all(0),
                                            onPressed: () {
                                              if (selectedData
                                                      .where((element) =>
                                                          element.index ==
                                                          index)
                                                      .first
                                                      .count <
                                                  int.parse(token.nftData[index]
                                                      .tokenBalance)) {
                                                setState(() {
                                                  selectedData
                                                      .where((element) =>
                                                          element.index ==
                                                          index)
                                                      .first
                                                      .count++;
                                                });
                                              }
                                            },
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            child: ClipOval(
                                                child: Material(
                                              color: AppTheme.white,
                                              child: SizedBox(
                                                  height: 30,
                                                  width: 30,
                                                  child:
                                                      Center(child: Text("+"))),
                                            )),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              floatingActionButton: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  bridge == 2
                      ? ListTile(
                          leading: ClipOval(
                            clipBehavior: Clip.antiAlias,
                            child: Container(
                              child: Text("!",
                                  style: TextStyle(
                                      fontSize: 50,
                                      color: AppTheme.black,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          title: Text("Note"),
                          subtitle: Text(
                              "Assets deposited from Plasma Bridge takes upto 7 days for withdrawl."),
                          isThreeLine: true,
                        )
                      : Container(),
                  SafeArea(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: AppTheme.buttonHeight_44,
                      margin: EdgeInsets.symmetric(
                          horizontal: AppTheme.paddingHeight12),
                      child: TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: AppTheme.orange_500,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppTheme.buttonRadius))),
                        onPressed: () {
                          _sendDepositTransactionERC1155(state, token, context);
                        },
                        child: Text(
                          'Deposit',
                          style: AppTheme.label_medium
                              .copyWith(color: AppTheme.lightgray_700),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Scaffold(
                appBar: AppBar(
                  title: Text("Deposit To Matic"),
                ),
                body: Center(child: Text("Something went Wrong")));
          }
        });
      },
    );
  }

  _sendDepositTransactionERC1155(
      DepositDataFinal state, Items tokenState, BuildContext context) async {
    if (selectedData.isEmpty) {
      Fluttertoast.showToast(
          msg: "Select at least 1 token", toastLength: Toast.LENGTH_LONG);
      return;
    }
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context, false);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Continue"),
      onPressed: () {
        Navigator.pop(context, true);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      shape: AppTheme.cardShape,
      content: Text(
          "You haven't given sufficient approval, would you like to approve now?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    GlobalKey<State> _key = new GlobalKey<State>();
    Dialogs.showLoadingDialog(context, _key);
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    Transaction trx;
    TransactionData transactionData;
    var approvalStatus = false;
    approvalStatus = await EthereumTransactions.erc1155ApprovalStatus(
        state.data.token.contractAddress, config.erc1155PredicatePos);

    if (!approvalStatus) {
      bool appr = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
      if (appr) {
        trx = await EthereumTransactions.erc1155Approve(
            state.data.token.contractAddress, config.erc1155PredicatePos);
        transactionData = TransactionData(
            to: state.data.token.contractAddress,
            amount: "0",
            trx: trx,
            type: TransactionType.APPROVE);
      } else {
        Navigator.of(context, rootNavigator: true).pop();
        return;
      }
    } else {
      List<BigInt> tokenIdList = [];
      List<BigInt> amountList = [];
      selectedData.forEach((element) {
        tokenIdList
            .add(BigInt.parse(state.data.token.nftData[element.index].tokenId));
        amountList.add(BigInt.from(element.count));
      });
      trx = await EthereumTransactions.depositErc1155Pos(
          tokenIdList, amountList, state.data.token.contractAddress);

      transactionData = TransactionData(
          to: config.rootChainProxy,
          amount: "0",
          trx: trx,
          token: tokenState,
          type: TransactionType.DEPOSITPOS);
    }

    Navigator.of(context, rootNavigator: true).pop();

    Navigator.pushNamed(context, ethereumTransactionConfirmRoute,
        arguments: transactionData);
  }

  _refreshLoop(CovalentTokensListEthCubit cubit) {
    new Timer.periodic(Duration(seconds: 30), (Timer t) {
      if (mounted) {
        cubit.refresh();
      }
    });
  }
}

class _Erc1155DepositData {
  int count;
  int index;

  _Erc1155DepositData(this.count, this.index);
}

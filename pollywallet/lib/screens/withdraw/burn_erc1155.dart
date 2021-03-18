import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/covalent_models/covalent_token_list.dart';
import 'package:pollywallet/models/transaction_data/transaction_data.dart';
import 'package:pollywallet/state_manager/covalent_states/covalent_token_list_cubit_matic.dart';
import 'package:pollywallet/state_manager/deposit_data_state/deposit_data_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pollywallet/state_manager/withdraw_burn_state/withdraw_burn_data_cubit.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';
import 'package:pollywallet/utils/withdraw_manager/withdraw_manager_web3.dart';
import 'package:pollywallet/widgets/loading_indicator.dart';
import 'package:pollywallet/widgets/nft_tile.dart';

class Erc1155Burn extends StatefulWidget {
  @override
  _Erc1155BurnState createState() => _Erc1155BurnState();
}

class _Erc1155BurnState extends State<Erc1155Burn> {
  DepositDataCubit data;
  BuildContext context;
  int bridge = 0;
  double balance;
  List<_Erc1155BrunData> selectedData = [];
  int args; // 0 no bridge , 1 = pos , 2 = plasma , 3 both
  int index = 0;
  var tokenListCubit;
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _refreshLoop(tokenListCubit);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    tokenListCubit = context.read<CovalentTokensListMaticCubit>();
    this.data = context.read<DepositDataCubit>();
    this.args = ModalRoute.of(context).settings.arguments;

    if (args == 3 && bridge == 0) {
      bridge = 1;
    } else if (args != 3) {
      bridge = args;
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("Withdraw from Matic"),
        ),
        body: BlocBuilder<WithdrawBurnDataCubit, WithdrawBurnDataState>(
          builder: (BuildContext context, state) {
            return BlocBuilder<CovalentTokensListMaticCubit,
                CovalentTokensListMaticState>(builder: (context, tokenState) {
              if (state is WithdrawBurnDataFinal &&
                  tokenState is CovalentTokensListMaticLoaded) {
                var token = tokenState.covalentTokenList.data.items
                    .where((element) =>
                        element.contractAddress ==
                        state.data.token.contractAddress)
                    .first;
                var balance = EthConversions.weiToEth(
                    BigInt.parse(token.balance), token.contractDecimals);
                this.balance = balance;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    bridge == 1
                        ? Text(
                            "POS bridge",
                            style: AppTheme.title,
                          )
                        : bridge == 2
                            ? Text("Plasma Bridge", style: AppTheme.title)
                            : SizedBox(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: ListView.builder(
                        itemCount: token.nftData.length,
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
                                            .add(_Erc1155BrunData(1, index));
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
                                      "Amount to depoist",
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
                                                  int.parse(state
                                                      .data
                                                      .token
                                                      .nftData[index]
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
                    Column(
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
                          child: ListTile(
                            leading: FlatButton(
                              child: ClipOval(
                                  child: Material(
                                color: AppTheme.secondaryColor.withOpacity(0.3),
                                child: SizedBox(
                                    height: 56,
                                    width: 56,
                                    child: Center(
                                        child: Text(
                                      token.contractName
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: AppTheme.title,
                                    ))),
                              )),
                            ),
                            contentPadding: EdgeInsets.all(0),
                            title: Text(
                              token.contractName,
                              textAlign: TextAlign.center,
                            ),
                            trailing: FlatButton(
                              onPressed: () {
                                _burnErc1155(state, token, context);
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              child: ClipOval(
                                  child: Material(
                                color: AppTheme.primaryColor,
                                child: SizedBox(
                                    height: 56,
                                    width: 56,
                                    child: Center(
                                      child: Icon(Icons.check,
                                          color: AppTheme.white),
                                    )),
                              )),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                );
              } else {
                return Center(child: Text("Something went Wrong"));
              }
            });
          },
        ));
  }

  _burnErc1155(
      WithdrawBurnDataFinal state, Items token, BuildContext context) async {
    if (selectedData.isEmpty) {
      Fluttertoast.showToast(
          msg: "Select at least 1 token", toastLength: Toast.LENGTH_LONG);
      return;
    }
    List<BigInt> tokenIdList = [];
    List<BigInt> amountList = [];
    var sum = 0;
    selectedData.forEach((element) {
      sum += element.count;
      tokenIdList
          .add(BigInt.parse(state.data.token.nftData[element.index].tokenId));
      amountList.add(BigInt.from(element.count));
    });
    var trx = await WithdrawManagerWeb3.burnERC1155(
        state.data.token.contractAddress, tokenIdList, amountList);
    var type;
    if (bridge == 1) {
      type = TransactionType.BURNPOS;
    } else if (bridge == 2) {
      type = TransactionType.BURNPLASMA;
    } else {
      return;
    }

    var transactionData = TransactionData(
        to: state.data.token.contractAddress,
        amount: sum.toString(),
        trx: trx,
        token: token,
        type: type);

    GlobalKey<State> _key = new GlobalKey<State>();
    Dialogs.showLoadingDialog(context, _key);

    Navigator.of(context, rootNavigator: true).pop();

    Navigator.pushNamed(context, confirmMaticTransactionRoute,
        arguments: transactionData);
  }

  _refreshLoop(CovalentTokensListMaticCubit cubit) {
    new Timer.periodic(Duration(seconds: 30), (Timer t) {
      if (mounted) {
        cubit.refresh();
      }
    });
  }
}

class _Erc1155BrunData {
  int count;
  int index;

  _Erc1155BrunData(this.count, this.index);
}

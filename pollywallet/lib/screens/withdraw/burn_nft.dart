import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/tansaction_data/transaction_data.dart';
import 'package:pollywallet/models/transaction_models/transaction_information.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pollywallet/state_manager/covalent_states/covalent_token_list_cubit_matic.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/state_manager/withdraw_burn_state/withdraw_burn_data_cubit.dart';
import 'package:pollywallet/utils/fiat_crypto_conversions.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';
import 'package:pollywallet/utils/withdraw_manager/withdraw_manager_web3.dart';
import 'package:pollywallet/widgets/loading_indicator.dart';
import 'package:pollywallet/widgets/nft_tile.dart';

class NftBurn extends StatefulWidget {
  @override
  _NftBurnState createState() => _NftBurnState();
}

class _NftBurnState extends State<NftBurn> {
  TextEditingController _amount = TextEditingController();
  WithdrawBurnDataCubit data;
  BuildContext context;
  int bridge = 0;
  double balance = 0;
  int args; // 0 no bridge , 1 = pos , 2 = plasma , 3 both
  int index = 0;
  int selectedIndex = 0;
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      var tokenListCubit = context.read<CovalentTokensListMaticCubit>();
      tokenListCubit.getTokensList();

      _refreshLoop(tokenListCubit);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    this.data = context.read<WithdrawBurnDataCubit>();
    this.args = ModalRoute.of(context).settings.arguments;
    print("args");
    print(args);

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      args == 3
                          ? CupertinoSegmentedControl<int>(
                              pressedColor:
                                  AppTheme.somewhatYellow.withOpacity(0.9),
                              groupValue: index,
                              selectedColor:
                                  AppTheme.somewhatYellow.withOpacity(0.9),
                              borderColor:
                                  AppTheme.somewhatYellow.withOpacity(0.01),
                              unselectedColor:
                                  AppTheme.somewhatYellow.withOpacity(0.9),
                              padding: EdgeInsets.all(10),
                              children: {
                                0: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 5),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(3))),
                                    elevation: index == 0 ? 1 : 0,
                                    color: index == 0
                                        ? AppTheme.backgroundWhite
                                        : AppTheme.somewhatYellow
                                            .withOpacity(0.01),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      child: Text(
                                        "POS",
                                        style: AppTheme.body1,
                                      ),
                                    ),
                                  ),
                                ),
                                1: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 5),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(3))),
                                    elevation: index == 1 ? 1 : 0,
                                    color: index == 1
                                        ? AppTheme.backgroundWhite
                                        : AppTheme.somewhatYellow
                                            .withOpacity(0.01),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0, vertical: 10),
                                      child: Text(
                                        "PLASMA",
                                        style: AppTheme.body1,
                                      ),
                                    ),
                                  ),
                                )
                              },
                              onValueChanged: (val) {
                                setState(() {
                                  index = val;
                                  if (val == 0) {
                                    bridge = 1;
                                  } else {
                                    bridge = 2;
                                  }
                                });
                              })
                          : args == 1
                              ? Text("POS Bridge", style: AppTheme.headline)
                              : args == 2
                                  ? Text(
                                      "Plasma Bridge",
                                      style: AppTheme.headline,
                                    )
                                  : Container(),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: ListView.builder(
                          itemCount: token.nftData.length,
                          itemBuilder: (context, index) {
                            return FlatButton(
                              onPressed: () {
                                setState(() {
                                  selectedIndex = index;
                                });
                              },
                              padding: EdgeInsets.all(0),
                              child: NftDepositTile(
                                data: token.nftData[index],
                                selected: index == selectedIndex,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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
                            onPressed: () {
                              if (index == 0) {
                                setState(() {
                                  _amount.text = balance.toString();
                                });
                              } else {
                                setState(() {
                                  _amount.text =
                                      FiatCryptoConversions.cryptoToFiat(
                                              balance, token.quoteRate)
                                          .toString();
                                });
                              }
                            },
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            child: ClipOval(
                                child: Material(
                              color: AppTheme.secondaryColor.withOpacity(0.3),
                              child: SizedBox(
                                  height: 56,
                                  width: 56,
                                  child: Center(
                                    child: Text(
                                      "Max",
                                      style: AppTheme.title,
                                    ),
                                  )),
                            )),
                          ),
                          title: Text(
                            "Balance",
                            style: AppTheme.subtitle,
                          ),
                          subtitle: Text(
                            balance.toStringAsFixed(2) +
                                " " +
                                token.contractName,
                            style: AppTheme.title,
                          ),
                          trailing: FlatButton(
                            onPressed: () {
                              _sendWithDrawTransaction(state, context);
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
        }));
  }

  _sendWithDrawTransaction(
      WithdrawBurnDataFinal state, BuildContext context) async {
    GlobalKey<State> _key = GlobalKey<State>();
    Dialogs.showLoadingDialog(context, _key);
    TransactionData transactionData;
    if (state.data.token.nftData[selectedIndex].tokenBalance == null) {
      var trx = await WithdrawManagerWeb3.burnErc721(
          state.data.token.contractAddress,
          state.data.token.nftData[selectedIndex].tokenId);
      transactionData = TransactionData(
          amount: _amount.text,
          to: state.data.token.contractAddress,
          trx: trx,
          type: TransactionType.WITHDRAW);
      Navigator.of(context, rootNavigator: true).pop();

      Navigator.pushNamed(context, confirmMaticTransactionRoute,
          arguments: transactionData);
    }
  }

  _refreshLoop(CovalentTokensListMaticCubit cubit) {
    new Timer.periodic(Duration(seconds: 30), (Timer t) {
      if (mounted) {
        cubit.refresh();
      }
    });
  }
}

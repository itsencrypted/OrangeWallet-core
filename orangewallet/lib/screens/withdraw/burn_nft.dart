import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:orangewallet/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orangewallet/models/covalent_models/covalent_token_list.dart';
import 'package:orangewallet/models/transaction_data/transaction_data.dart';
import 'package:orangewallet/state_manager/covalent_states/covalent_token_list_cubit_matic.dart';
import 'package:orangewallet/theme_data.dart';
import 'package:orangewallet/state_manager/withdraw_burn_state/withdraw_burn_data_cubit.dart';
import 'package:orangewallet/utils/web3_utils/eth_conversions.dart';
import 'package:orangewallet/utils/withdraw_manager/withdraw_manager_api.dart';
import 'package:orangewallet/utils/withdraw_manager/withdraw_manager_web3.dart';
import 'package:orangewallet/widgets/loading_indicator.dart';
import 'package:orangewallet/widgets/nft_tile.dart';

class NftBurn extends StatefulWidget {
  @override
  _NftBurnState createState() => _NftBurnState();
}

class _NftBurnState extends State<NftBurn> {
  WithdrawBurnDataCubit data;
  BuildContext context;
  int bridge = 0;
  double balance = 0;
  int args; // 0 no bridge , 1 = pos , 2 = plasma , 3 both
  int index = 0;
  int selectedIndex = 0;
  var tokenListCubit;
  bool showWarning = true;
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
    this.data = context.read<WithdrawBurnDataCubit>();
    this.args = ModalRoute.of(context).settings.arguments;
    print("args");
    print(args);

    if (args == 3 && bridge == 0) {
      bridge = 1;
    } else if (args != 3) {
      bridge = args;
    }

    return BlocBuilder<WithdrawBurnDataCubit, WithdrawBurnDataState>(
        builder: (BuildContext context, state) {
      return BlocBuilder<CovalentTokensListMaticCubit,
          CovalentTokensListMaticState>(builder: (context, tokenState) {
        if (state is WithdrawBurnDataFinal &&
            tokenState is CovalentTokensListMaticLoaded) {
          var token = tokenState.covalentTokenList.data.items
              .where((element) =>
                  element.contractAddress == state.data.token.contractAddress)
              .first;
          var balance = EthConversions.weiToEth(
              BigInt.parse(token.balance), token.contractDecimals);
          this.balance = balance;
          return Scaffold(
            appBar: AppBar(
              title: Text("Withdraw from Matic"),
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.73,
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
                ],
              ),
            ),
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                bridge == 2
                    ? MediaQuery.of(context).viewInsets.bottom == 0
                        ? showWarning
                            ? Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.symmetric(
                                    horizontal: AppTheme.paddingHeight12 - 3),
                                child: Card(
                                  color: AppTheme.warningCardColor,
                                  shape: AppTheme.cardShape,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: AppTheme.paddingHeight,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Warning',
                                              style: AppTheme.titleWhite,
                                            ),
                                            IconButton(
                                                icon: Icon(Icons.close),
                                                color: Colors.white,
                                                onPressed: () {
                                                  setState(() {
                                                    showWarning = false;
                                                  });
                                                })
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: AppTheme.paddingHeight,
                                            bottom: AppTheme.paddingHeight,
                                            right: 10),
                                        child: Text(
                                          "This asset will take upto 7 days for withdrawal.",
                                          style: AppTheme.body2White,
                                          maxLines: 100,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : Container()
                        : Container()
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
                        _sendWithDrawTransaction(state, token, context);
                      },
                      child: Text(
                        'Withdraw',
                        style: AppTheme.label_medium
                            .copyWith(color: AppTheme.lightgray_700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        } else if (state is WithdrawBurnDataInitial) {
          print(tokenState.toString());
          print(state.toString());
          return Scaffold(
              floatingActionButton: Container(),
              appBar: AppBar(
                title: Text("Withdraw from Matic"),
              ),
              body: Center(child: Text("Please wait..")));
        } else {
          print(tokenState.toString());
          print(state.toString());
          return Scaffold(
              appBar: AppBar(
                title: Text("Withdraw from Matic"),
              ),
              body: Center(child: Text("Something went Wrong")));
        }
      });
    });
  }

  _sendWithDrawTransaction(
      WithdrawBurnDataFinal state, Items token, BuildContext context) async {
    GlobalKey<State> _key = GlobalKey<State>();
    Dialogs.showLoadingDialog(context, _key);
    TransactionData transactionData;
    var type;
    if (bridge == 1) {
      type = TransactionType.BURNPOS;
    } else if (bridge == 2) {
      type = TransactionType.BURNPLASMA;
    } else {
      return;
    }
    var trx = await WithdrawManagerWeb3.burnErc721(
        state.data.token.contractAddress,
        state.data.token.nftData[selectedIndex].tokenId);
    transactionData = TransactionData(
        amount: "1",
        to: state.data.token.contractAddress,
        trx: trx,
        token: token,
        exitSignature: WithdrawManagerApi.ERC721_TRANSFER_EVENT_SIG,
        type: type);
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

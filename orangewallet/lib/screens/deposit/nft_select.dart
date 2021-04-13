import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

class NftSelectDeposit extends StatefulWidget {
  @override
  _NftSelectDepositState createState() => _NftSelectDepositState();
}

class _NftSelectDepositState extends State<NftSelectDeposit>
    with SingleTickerProviderStateMixin {
  DepositDataCubit data;
  BuildContext context;
  int bridge = 0;
  double balance;
  var state;
  var token;
  int tokenCountToSend = 1;
  int selectedIndex = 0;
  int args; // 0 no bridge , 1 = pos , 2 = plasma , 3 both
  int index = 0;
  TabController _controller;
  var ethCubit;
  @override
  initState() {
    Future.delayed(Duration.zero, () {
      _controller = TabController(length: 2, vsync: this);

      _controller.addListener(() {
        if (_controller.index == 0) {
          bridge = 1;
        } else {
          bridge = 2;
        }
      });
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _refreshLoop(ethCubit);
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
            CovalentTokensListEthState>(builder: (context, tokenstate) {
          if (state is DepositDataFinal &&
              tokenstate is CovalentTokensListEthLoaded) {
            var token = tokenstate.covalentTokenList.data.items
                .where((element) =>
                    element.contractAddress == state.data.token.contractAddress)
                .first;
            this.token = token;
            this.state = state;
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
                        itemCount: state.data.token.nftData.length,
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
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              floatingActionButton: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  bridge == 2
                      ? MediaQuery.of(context).viewInsets.bottom == 0
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
                          _sendDepositTransactionERC721(state, token, context);
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
                  title: Text("Deposit to Matic"),
                ),
                body: Center(child: Text("Something went Wrong")));
          }
        });
      },
    );
  }

  _sendDepositTransactionERC721(
      DepositDataFinal state, Items tokenState, BuildContext context) async {
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
    var spender = "";
    var approvalStatus = false;
    if (bridge == 1) {
      approvalStatus = await EthereumTransactions.erc721ApprovalStatusPos(
          state.data.token.contractAddress);
      spender = config.erc721PredicatePos;
    } else {
      approvalStatus = await EthereumTransactions.erc721ApprovalStatusPlasma(
          state.data.token.contractAddress);
      spender = config.depositManager;
    }

    if (!approvalStatus) {
      bool appr = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
      if (appr) {
        trx = await EthereumTransactions.erc721Approve(
            BigInt.parse(state.data.token.nftData[selectedIndex].tokenId),
            state.data.token.contractAddress,
            spender);
        transactionData = TransactionData(
            to: state.data.token.contractAddress,
            amount: "0",
            trx: trx,
            token: tokenState,
            type: TransactionType.APPROVE);
      } else {
        Navigator.of(context, rootNavigator: true).pop();
        return;
      }
    } else {
      if (bridge == 1) {
        trx = await EthereumTransactions.erc721DepositPos(
            BigInt.parse(state.data.token.nftData[selectedIndex].tokenId),
            state.data.token.contractAddress);

        transactionData = TransactionData(
            to: config.rootChainProxy,
            amount: "0",
            trx: trx,
            token: tokenState,
            type: TransactionType.DEPOSITPOS);
      } else {
        trx = await EthereumTransactions.erc721DepositPlasma(
            BigInt.parse(state.data.token.nftData[selectedIndex].tokenId),
            state.data.token.contractAddress);
        transactionData = TransactionData(
            to: config.depositManager,
            amount: "0",
            trx: trx,
            token: tokenState,
            type: TransactionType.DEPOSITPLASMA);
      }
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

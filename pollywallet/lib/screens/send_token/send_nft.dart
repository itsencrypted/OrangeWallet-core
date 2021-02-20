import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/covalent_models/covalent_token_list.dart';
import 'package:pollywallet/models/tansaction_data/transaction_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pollywallet/screens/send_token/send_nft_tile.dart';
import 'package:pollywallet/state_manager/send_token_state/send_token_cubit.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/network/network_config.dart';
import 'package:pollywallet/utils/network/network_manager.dart';
import 'package:pollywallet/widgets/loading_indicator.dart';
import 'package:web3dart/web3dart.dart';

class SendNft extends StatefulWidget {
  @override
  _SendNftState createState() => _SendNftState();
}

class _SendNftState extends State<SendNft> {
  SendTransactionCubit data;
  BuildContext context;
  double balance;
  int tokenCountToSend = 1;
  int selectedIndex = 0;
  String args; //tokenId
  int index = 0;
  String tokenBalance;

  @override
  Widget build(BuildContext context) {
    this.data = context.read<SendTransactionCubit>();
    this.args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
        appBar: AppBar(title: Text("Deposit to Matic")),
        body: BlocBuilder<SendTransactionCubit, SendTransactionState>(
          builder: (BuildContext context, state) {
            if (state is SendTransactionFinal) {
              NftData token = state.data.token.nftData
                  .where((element) => element.tokenId == args.toString())
                  .first;
              tokenBalance = token.tokenBalance;
              this.balance = balance;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Center(
                        child: SendNftTile(
                          data: token,
                        ),
                      )),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SafeArea(
                        child: ListTile(
                          leading: FlatButton(
                            onPressed: () {
                              if (tokenBalance == null) {
                                return;
                              }
                              setState(() {
                                tokenCountToSend = int.parse(state
                                    .data.token.nftData[index].tokenBalance);
                              });
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
                                    child: tokenBalance == null
                                        ? Text(
                                            state.data.token.contractName
                                                .substring(0, 1)
                                                .toUpperCase(),
                                            style: AppTheme.title,
                                          )
                                        : Text(
                                            "Max",
                                            style: AppTheme.title,
                                          ),
                                  )),
                            )),
                          ),
                          contentPadding: EdgeInsets.all(0),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              state.data.token.nftData[index].tokenBalance ==
                                      null
                                  ? Text(
                                      "NFTs",
                                      style: AppTheme.subtitle,
                                    )
                                  : Text(
                                      "NFTs to send",
                                      style: AppTheme.subtitle,
                                    ),
                              state.data.token.nftData[index].tokenBalance ==
                                      null
                                  ? Text(
                                      state.data.token.nftData.length
                                              .toString() +
                                          " " +
                                          state.data.token.contractName,
                                      style: AppTheme.title,
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 30,
                                          child: FlatButton(
                                            padding: EdgeInsets.all(0),
                                            onPressed: () {
                                              if (tokenCountToSend > 1) {
                                                setState(() {
                                                  tokenCountToSend--;
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
                                          child:
                                              Text(tokenCountToSend.toString()),
                                        ),
                                        SizedBox(
                                          width: 30,
                                          child: FlatButton(
                                            padding: EdgeInsets.all(0),
                                            onPressed: () {
                                              if (tokenCountToSend <
                                                  int.parse(state
                                                      .data
                                                      .token
                                                      .nftData[index]
                                                      .tokenBalance)) {
                                                setState(() {
                                                  tokenCountToSend++;
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
                                    ),
                            ],
                          ),
                          trailing: FlatButton(
                            onPressed: () {
                              _sendDepositTransactionERC721(state, context);
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
          },
        ));
  }

  _sendDepositTransactionERC721(
      SendTransactionFinal state, BuildContext context) async {
    GlobalKey<State> _key = new GlobalKey<State>();
    Dialogs.showLoadingDialog(context, _key);
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    Transaction trx;
    TransactionData transactionData;

    Navigator.of(context, rootNavigator: true).pop();

    Navigator.pushNamed(context, ethereumTransactionConfirmRoute,
        arguments: transactionData);
  }
}

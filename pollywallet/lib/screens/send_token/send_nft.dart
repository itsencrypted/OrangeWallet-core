import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/covalent_models/covalent_token_list.dart';
import 'package:pollywallet/models/tansaction_data/transaction_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pollywallet/models/transaction_models/transaction_information.dart';
import 'package:pollywallet/screens/send_token/send_nft_tile.dart';
import 'package:pollywallet/state_manager/send_token_state/send_token_cubit.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/network/network_config.dart';
import 'package:pollywallet/utils/network/network_manager.dart';
import 'package:pollywallet/utils/web3_utils/matic_transactions.dart';
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
  TextEditingController _address =
      TextEditingController(text: "0x2Ee331840018465bD7Fe74aA4E442b9EA407fBBE");
  RegExp reg = RegExp(r'^0x[a-fA-F0-9]{40}$');

  @override
  Widget build(BuildContext context) {
    this.data = context.read<SendTransactionCubit>();
    this.args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
        appBar: AppBar(title: Text("Send Token")),
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
                  Column(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Center(
                            child: SendNftTile(
                              data: token,
                            ),
                          )),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: TextFormField(
                          controller: _address,
                          keyboardAppearance: Brightness.dark,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (val) =>
                              reg.hasMatch(val) ? null : "Invalid addresss",
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.text,
                          style: AppTheme.bigLabel,
                          decoration: InputDecoration(
                              prefix: FlatButton(
                                child: Icon(Icons.paste),
                                onPressed: () async {
                                  ClipboardData data =
                                      await Clipboard.getData('text/plain');
                                  _address.text = data.text;
                                },
                              ),
                              suffix: FlatButton(
                                child: Icon(Icons.qr_code),
                                onPressed: () async {
                                  var qrResult = await BarcodeScanner.scan();
                                  RegExp reg = RegExp(r'^0x[0-9a-fA-F]{40}$');
                                  print(qrResult.rawContent);
                                  if (reg.hasMatch(qrResult.rawContent)) {
                                    print("Regex");
                                    if (qrResult.rawContent.length == 42) {
                                      _address.text = qrResult.rawContent;
                                    } else {
                                      Fluttertoast.showToast(
                                        msg: "Invalid QR",
                                      );
                                    }
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: "Invalid QR",
                                    );
                                  }
                                },
                              ),
                              hintText: "Address",
                              hintStyle: AppTheme.body1,
                              focusColor: AppTheme.secondaryColor
                              //focusedBorder: InputBorder.none,
                              //enabledBorder: InputBorder.none,
                              ),
                        ),
                      ),
                    ],
                  ),
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
                              if (state.data.token.nftData.first.tokenBalance ==
                                  null) {
                                _sendERC721(BigInt.parse(args),
                                    state.data.token.contractAddress, context);
                              } else {
                                _sendErc1155(
                                    BigInt.parse(args),
                                    BigInt.from(tokenCountToSend),
                                    state.data.token.contractAddress,
                                    context);
                              }
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

  _sendERC721(BigInt id, String tokenAddress, BuildContext context) async {
    if (validateAddress(_address.text) != null) {
      Fluttertoast.showToast(
        msg: "Invalid inputs",
      );
      return;
    }
    GlobalKey<State> _key = new GlobalKey<State>();
    Dialogs.showLoadingDialog(context, _key);
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    Transaction trx =
        await MaticTransactions.transferERC721(id, tokenAddress, _address.text);
    TransactionData transactionData = TransactionData(
        trx: trx, amount: "1", type: TransactionType.SEND, to: _address.text);

    Navigator.of(context, rootNavigator: true).pop();

    Navigator.pushNamed(context, confirmMaticTransactionRoute,
        arguments: transactionData);
  }

  _sendErc1155(BigInt id, BigInt amount, String tokenAddress,
      BuildContext context) async {
    if (validateAddress(_address.text) != null) {
      Fluttertoast.showToast(
        msg: "Invalid inputs",
      );
      return;
    }
    GlobalKey<State> _key = new GlobalKey<State>();
    Dialogs.showLoadingDialog(context, _key);
    Transaction trx = await MaticTransactions.transferErc1155(
        id, amount, tokenAddress, _address.text);
    TransactionData transactionData = TransactionData(
        trx: trx,
        amount: amount.toString(),
        type: TransactionType.SEND,
        to: _address.text);

    Navigator.of(context, rootNavigator: true).pop();

    Navigator.pushNamed(context, confirmMaticTransactionRoute,
        arguments: transactionData);
  }

  String validateAddress(String value) {
    RegExp regex = new RegExp(r'^0x[a-fA-F0-9]{40}$');
    if (!regex.hasMatch(value) || value == null)
      return 'Enter a valid Ethereum address';
    else
      return null;
  }
}

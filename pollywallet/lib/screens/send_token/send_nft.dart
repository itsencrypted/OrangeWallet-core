import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/covalent_models/covalent_token_list.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pollywallet/models/transaction_data/transaction_data.dart';
import 'package:pollywallet/screens/send_token/send_nft_tile.dart';
import 'package:pollywallet/state_manager/covalent_states/covalent_token_list_cubit_matic.dart';
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
  bool showAddress = true;
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
    var tokenListCubit = context.read<CovalentTokensListMaticCubit>();
    _refreshLoop(tokenListCubit);

    return BlocBuilder<SendTransactionCubit, SendTransactionState>(
      builder: (BuildContext context, state) {
        return BlocBuilder<CovalentTokensListMaticCubit,
            CovalentTokensListMaticState>(builder: (context, tokenState) {
          if (state is SendTransactionFinal &&
              tokenState is CovalentTokensListMaticLoaded) {
            var _token = tokenState.covalentTokenList.data.items
                .where((element) =>
                    state.data.token.contractAddress == element.contractAddress)
                .first;
            NftData token = _token.nftData
                .where((element) => element.tokenId == args.toString())
                .first;
            tokenBalance = token.tokenBalance;
            this.balance = balance;
            return Scaffold(
              appBar: AppBar(title: Text("Send NFT")),
              body: SingleChildScrollView(
                physics: MediaQuery.of(context).viewInsets.bottom == 0
                    ? NeverScrollableScrollPhysics()
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Column(
                            children: [
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.43,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 8),
                                    child: SendNftTile(
                                      data: token,
                                    ),
                                  )),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                          MaterialTapTargetSize.shrinkWrap,
                                      child: ClipOval(
                                          child: Material(
                                        color: AppTheme.white,
                                        child: SizedBox(
                                            height: 30,
                                            width: 30,
                                            child: Center(child: Text("-"))),
                                      )),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Text(tokenCountToSend.toString()),
                                  ),
                                  SizedBox(
                                    width: 30,
                                    child: FlatButton(
                                      padding: EdgeInsets.all(0),
                                      onPressed: () {
                                        if (tokenCountToSend <
                                            int.parse(state.data.token
                                                .nftData[index].tokenBalance)) {
                                          setState(() {
                                            tokenCountToSend++;
                                          });
                                        }
                                      },
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      child: ClipOval(
                                          child: Material(
                                        color: AppTheme.white,
                                        child: SizedBox(
                                            height: 30,
                                            width: 30,
                                            child: Center(child: Text("+"))),
                                      )),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 15),
                          child: Card(
                              shape: AppTheme.cardShape,
                              elevation: AppTheme.cardElevations,
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(
                                      "Address",
                                      style: AppTheme.label_medium,
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(showAddress
                                          ? Icons.arrow_drop_up
                                          : Icons.arrow_drop_down),
                                      onPressed: () {
                                        setState(() {
                                          showAddress = !showAddress;
                                        });
                                      },
                                    ),
                                  ),
                                  showAddress
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 18.0, vertical: 8),
                                          child: Container(
                                            margin: EdgeInsets.symmetric(
                                                vertical: 16),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppTheme.cardRadius)),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextButton(
                                                  child: Icon(
                                                    Icons.paste,
                                                    color: Colors.black,
                                                  ),
                                                  onPressed: () async {
                                                    ClipboardData data =
                                                        await Clipboard.getData(
                                                            'text/plain');
                                                    _address.text = data.text;
                                                  },
                                                  style: TextButton.styleFrom(
                                                      backgroundColor:
                                                          AppTheme.warmgray_100,
                                                      elevation: 0,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 12),
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(AppTheme
                                                                      .cardRadius),
                                                              bottomLeft: Radius
                                                                  .circular(AppTheme
                                                                      .cardRadius)))),
                                                ),
                                                Expanded(
                                                  child: TextFormField(
                                                    controller: _address,
                                                    keyboardAppearance:
                                                        Brightness.dark,
                                                    autovalidateMode:
                                                        AutovalidateMode
                                                            .onUserInteraction,
                                                    validator: (val) => reg
                                                            .hasMatch(val)
                                                        ? null
                                                        : "Invalid addresss",
                                                    textAlign: TextAlign.center,
                                                    textAlignVertical:
                                                        TextAlignVertical
                                                            .center,
                                                    keyboardType:
                                                        TextInputType.text,
                                                    style: AppTheme.body_small,
                                                    decoration: InputDecoration(
                                                        fillColor: AppTheme
                                                            .warmgray_100,
                                                        hintText:
                                                            "Enter the reciepients address ",
                                                        filled: true,
                                                        hintStyle:
                                                            AppTheme.body_small,
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                        border:
                                                            OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide
                                                                        .none,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .zero)

                                                        //focusedBorder: InputBorder.none,
                                                        //enabledBorder: InputBorder.none,
                                                        ),
                                                  ),
                                                ),
                                                TextButton(
                                                  child: Icon(
                                                    Icons.qr_code,
                                                    color: Colors.black,
                                                  ),
                                                  onPressed: () async {
                                                    var qrResult =
                                                        await BarcodeScanner
                                                            .scan();
                                                    RegExp reg = RegExp(
                                                        r'^0x[0-9a-fA-F]{40}$');
                                                    print(qrResult.rawContent);
                                                    if (reg.hasMatch(
                                                        qrResult.rawContent)) {
                                                      print("Regex");
                                                      if (qrResult.rawContent
                                                              .length ==
                                                          42) {
                                                        _address.text =
                                                            qrResult.rawContent;
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
                                                  style: TextButton.styleFrom(
                                                      backgroundColor:
                                                          AppTheme.warmgray_100,
                                                      elevation: 0,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 12),
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.only(
                                                              topRight: Radius
                                                                  .circular(AppTheme
                                                                      .cardRadius),
                                                              bottomRight: Radius
                                                                  .circular(AppTheme
                                                                      .cardRadius)))),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container()
                                ],
                              )),
                        ),
                        SizedBox(
                          height: AppTheme.buttonHeight_44,
                        )
                      ],
                    ),
                  ],
                ),
              ),
              floatingActionButton: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SafeArea(
                      child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: AppTheme.buttonHeight_44,
                    margin: EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingHeight12),
                    child: TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: AppTheme.purple_600,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppTheme.buttonRadius))),
                      onPressed: () {
                        if (state.data.token.nftData.first.tokenBalance ==
                            null) {
                          _sendERC721(
                              BigInt.parse(args),
                              state.data.token.contractAddress,
                              state.data.token,
                              context);
                        } else {
                          _sendErc1155(
                              BigInt.parse(args),
                              BigInt.from(tokenCountToSend),
                              state.data.token.contractAddress,
                              state.data.token,
                              context);
                        }
                      },
                      child: Text(
                        'Send',
                        style: AppTheme.label_medium
                            .copyWith(color: AppTheme.lightgray_700),
                      ),
                    ),
                  )),
                ],
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
            );
          } else {
            return Scaffold(
                appBar: AppBar(title: Text("Send NFT")),
                body: Center(child: Text("Something went Wrong")));
          }
        });
      },
    );
  }

  _sendERC721(
      BigInt id, String tokenAddress, Items token, BuildContext context) async {
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
        token: token,
        trx: trx,
        amount: "1",
        type: TransactionType.SEND,
        to: _address.text);

    Navigator.of(context, rootNavigator: true).pop();

    Navigator.pushNamed(context, confirmMaticTransactionRoute,
        arguments: transactionData);
  }

  _sendErc1155(BigInt id, BigInt amount, String tokenAddress, Items token,
      BuildContext context) async {
    try {
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
          token: token,
          amount: amount.toString(),
          type: TransactionType.SEND,
          to: _address.text);

      Navigator.of(context, rootNavigator: true).pop();

      Navigator.pushNamed(context, confirmMaticTransactionRoute,
          arguments: transactionData);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  String validateAddress(String value) {
    RegExp regex = new RegExp(r'^0x[a-fA-F0-9]{40}$');
    if (!regex.hasMatch(value) || value == null)
      return 'Enter a valid Ethereum address';
    else
      return null;
  }

  _refreshLoop(CovalentTokensListMaticCubit maticCubit) {
    new Timer.periodic(Duration(seconds: 30), (Timer t) {
      if (mounted) {
        maticCubit.refresh();
      }
    });
  }
}

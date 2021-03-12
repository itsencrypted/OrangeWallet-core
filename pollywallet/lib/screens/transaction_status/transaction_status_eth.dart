import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/transaction_data/transaction_data.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/network/network_config.dart';
import 'package:pollywallet/utils/network/network_manager.dart';
import 'package:pollywallet/utils/web3_utils/ethereum_transactions.dart';
import 'package:pollywallet/widgets/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';

class EthTransactionStatus extends StatefulWidget {
  @override
  _EthTransactionStatusState createState() => _EthTransactionStatusState();
}

class _EthTransactionStatusState extends State<EthTransactionStatus> {
  TransactionReceipt receipt;
  String txHash;
  StreamSubscription streamSubscription;
  int status = 0; //0=no status, 1= merged, 2= failed
  bool unmerged = false;
  bool speedupStuck = false;
  String blockExplorer = "";
  @override
  void initState() {
    NetworkManager.getNetworkObject().then((config) {
      blockExplorer = config.blockExplorerEth;
    });

    SchedulerBinding.instance.addPostFrameCallback((_) {
      final String txHash = ModalRoute.of(context).settings.arguments;
      print(txHash);
      this.txHash = txHash;
      txStatus(txHash);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Transaction Status"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: speedupStuck
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.cancel_schedule_send_outlined,
                          color: Colors.blue,
                          size: 50,
                        ),
                      ),
                      Text(
                        "Transaction with same nonce has already been merged",
                        style: AppTheme.subtitle,
                        textAlign: TextAlign.center,
                      )
                    ],
                  )
                : Column(
                    mainAxisAlignment: status == 0
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.start,
                    crossAxisAlignment: status == 0
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          status == 0
                              ? SpinKitCubeGrid(
                                  size: 50,
                                  color: AppTheme.primaryColor,
                                )
                              : status == 1
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.green,
                                      size: 50,
                                    )
                                  : Icon(
                                      Icons.cancel,
                                      size: 50,
                                      color: Colors.red,
                                    ),
                        ],
                      ),
                      status == 0
                          ? Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: unmerged
                                      ? Text(
                                          "Your transaction will be added to block soon..")
                                      : Text("Please wait ...."),
                                ),
                                unmerged
                                    ? RaisedButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        color: sendButtonColor.withOpacity(0.6),
                                        child: Text("Speedup Transaction"),
                                        onPressed: _speedUp)
                                    : Container()
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Transaction Hash",
                                      style: AppTheme.title,
                                    ),
                                    FlatButton(
                                      padding: EdgeInsets.all(0),
                                      child: Icon(Icons.open_in_browser),
                                      onPressed: _launchURL,
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    txHash,
                                    style: AppTheme.subtitle,
                                  ),
                                ),
                                Text(
                                  "From",
                                  style: AppTheme.title,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    receipt.from.toString(),
                                    style: AppTheme.subtitle,
                                  ),
                                ),
                                Text(
                                  "To",
                                  style: AppTheme.title,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    receipt.to.toString(),
                                    style: AppTheme.subtitle,
                                  ),
                                ),
                                Text(
                                  "Status",
                                  style: AppTheme.title,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    receipt.status ? "Successful" : "Failed",
                                    style: AppTheme.subtitle,
                                  ),
                                ),
                              ],
                            )
                    ],
                  ),
          ),
        ));
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  Future<void> txStatus(String txHash) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client =
        Web3Client(config.ethEndpoint, http.Client(), socketConnector: () {
      return IOWebSocketChannel.connect(config.ethWebsocket).cast<String>();
    });
    print(txHash);
    final client2 = Web3Client(config.ethEndpoint, http.Client());
    var tx = await client2.getTransactionReceipt(txHash);
    try {
      await client2.getTransactionByHash(txHash);
    } catch (e) {
      setState(() {
        speedupStuck = true;
      });
      return;
    }

    if (tx != null) {
      setState(() {
        if (tx.status) {
          status = 1;
          receipt = tx;
        } else {
          status = 2;
          receipt = tx;
        }
      });
      return;
    }
    setState(() {
      unmerged = true;
    });
    streamSubscription = client.addedBlocks().listen(null);
    streamSubscription.onData((data) async {
      var tx = await client2.getTransactionReceipt(txHash);
      print(tx);
      try {
        await client2.getTransactionByHash(txHash);
      } catch (e) {
        setState(() {
          speedupStuck = true;
        });
      }
      if (tx != null) {
        setState(() {
          if (tx.status) {
            status = 1;
            receipt = tx;
            unmerged = false;
          } else {
            status = 2;
            receipt = tx;
            unmerged = false;
          }
        });
        streamSubscription.cancel();
      }
    });
  }

  _launchURL() async {
    var url = blockExplorer + "/tx/" + txHash;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _speedUp() async {
    GlobalKey<State> key = GlobalKey();
    Dialogs.showLoadingDialog(context, key);
    Transaction trx = await EthereumTransactions.speedUpTransaction(txHash);
    TransactionData data = TransactionData(
        trx: trx,
        type: TransactionType.SPEEDUP,
        to: trx.to.hex,
        gas: trx.gasPrice.getInWei,
        amount: trx.value.getInEther.toString());
    Navigator.of(key.currentContext, rootNavigator: true).pop();
    Navigator.pushNamed(context, ethereumTransactionConfirmRoute,
        arguments: data);
  }
}

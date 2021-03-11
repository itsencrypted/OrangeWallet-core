import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/network/network_config.dart';
import 'package:pollywallet/utils/network/network_manager.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:url_launcher/url_launcher.dart';

class MaticTransactionStatus extends StatefulWidget {
  @override
  _MaticTransactionStatusState createState() => _MaticTransactionStatusState();
}

class _MaticTransactionStatusState extends State<MaticTransactionStatus> {
  TransactionReceipt receipt;
  String txHash;
  StreamSubscription streamSubscription;
  int status = 0; //0= unmerged, 1= merged, 2 = error
  String error = "";
  String blockExplorer = "";
  @override
  void initState() {
    NetworkManager.getNetworkObject().then((config) {
      blockExplorer = config.blockExplorerMatic;
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
            child: Column(
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
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text("Please wait..."),
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
    print(config.ethEndpoint);
    print(config.ethWebsocket);
    final client =
        Web3Client(config.endpoint, http.Client(), socketConnector: () {
      return IOWebSocketChannel.connect(config.maticWebsocket).cast<String>();
    });
    client.getTransactionByHash(txHash);
    print(txHash);
    final client2 = Web3Client(config.endpoint, http.Client());
    var tx = await client2.getTransactionReceipt(txHash);
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
    streamSubscription = client.addedBlocks().listen(null);
    streamSubscription.onData((data) async {
      var tx = await client2.getTransactionReceipt(txHash);
      print(tx);

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
}

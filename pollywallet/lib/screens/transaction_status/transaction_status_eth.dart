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

class EthTransactionStatus extends StatefulWidget {
  @override
  _EthTransactionStatusState createState() => _EthTransactionStatusState();
}

class _EthTransactionStatusState extends State<EthTransactionStatus> {
  TransactionReceipt receipt;
  String txHash;
  StreamSubscription streamSubscription;
  int status = 0; //0= unmerged, 1= merged, 2 = error
  String error = "";
  @override
  void initState() {
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
                    ? Text("Transaction will be added to block soon")
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Transaction Hash",
                            style: AppTheme.title,
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
        Web3Client(config.ethEndpoint, http.Client(), socketConnector: () {
      return IOWebSocketChannel.connect(config.ethWebsocket).cast<String>();
    });
    print(txHash);
    final client2 = Web3Client(config.ethEndpoint, http.Client());
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
}

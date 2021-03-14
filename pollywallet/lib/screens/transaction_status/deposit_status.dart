import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/bridge_api_models/bridge_api_data.dart';
import 'package:pollywallet/models/deposit_models/deposit_transaction_db.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/api_wrapper/deposit_bridge_api.dart';
import 'package:pollywallet/utils/misc/credential_manager.dart';

import 'package:pollywallet/widgets/transaction_details_timeline.dart';

class DepositStatus extends StatefulWidget {
  @override
  _DepositStatusState createState() => _DepositStatusState();
}

class _DepositStatusState extends State<DepositStatus> {
  DepositTransaction data;
  bool show = false;
  BridgeApiData bridgeApiData;
  bool transactionPending = false;
  String fromAddress = "";
  _DepositStatusState({this.transactionPending});
  final List<String> processes = [
    'Initialized',
    'Enroute',
    'Deposited',
  ];
  final List<String> messages = [
    'Deposit has been initialized',
    'Your deposit is on it way',
    'Deposit successful',
  ];
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        data = ModalRoute.of(context).settings.arguments;
        transactionPending = !data.merged;
      });
      DepositBridgeApi.depositStatusCode(data.txHash).then((value) {
        setState(() {
          bridgeApiData = value;
        });
      });
      if (!data.merged) {
        _refreshLoop(data.txHash);
      }
    });
    CredentialManager.getAddress().then((value) {
      setState(() {
        fromAddress = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
        actions: [
          IconButton(
              icon: Icon(Icons.ios_share),
              onPressed: () {
                //TODO add share logic
              })
        ],
      ),
      body: data == null
          ? Center(
              child: SpinKitFadingFour(
                size: 50,
                color: AppTheme.primaryColor,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.paddingHeight / 2),
                child: Column(
                  children: [
                    getTopContainer(),
                    getStatusCard(),
                    Card(
                      shape: AppTheme.cardShape,
                      child: Padding(
                        padding: EdgeInsets.all(AppTheme.paddingHeight / 2),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(AppTheme.cardRadius),
                                color: AppTheme.stackingGrey,
                              ),
                              margin: EdgeInsets.all(AppTheme.paddingHeight),
                              height: 110,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  detailsArea(
                                      title: data.fee == null
                                          ? ""
                                          : data.fee + " ETH",
                                      subtitle: 'Transaction Fee',
                                      topWidget: Icon(Icons.flash_on_outlined)),
                                  detailsArea(
                                      title: 'Ethereum Network',
                                      subtitle: 'Netowrk',
                                      topWidget: Icon(Icons.settings))
                                ],
                              ),
                            ),
                            getListTile(
                              imageUrl: tokenIcon,
                              title: 'from',
                              subtitle: fromAddress,
                              // trailing: IconButton(
                              //     icon: Icon(
                              //       Icons.file_copy,
                              //       color: Colors.black,
                              //     ),
                              //     onPressed: () {}),
                            ),
                            getListTile(
                              imageUrl: tokenIcon,
                              title: 'to',
                              subtitle: "Matic Network",
                              // trailing: IconButton(
                              //     icon: Icon(
                              //       Icons.file_copy,
                              //       color: Colors.black,
                              //     ),
                              //     onPressed: () {}),
                            ),
                            Divider(
                              color: Colors.grey,
                            ),
                            getListTile(
                              imageUrl: tokenIcon,
                              title: 'Transaction Hash',
                              subtitle: data.txHash,
                              trailing: IconButton(
                                  icon: Icon(
                                    Icons.file_copy,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {}),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget getTopContainer() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppTheme.paddingHeight20 * 2),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.all(AppTheme.paddingHeight / 4),
              decoration: BoxDecoration(
                  color: transactionPending ? Colors.red : Colors.green,
                  borderRadius:
                      BorderRadius.circular(AppTheme.cardRadiusSmall)),
              child: Text(
                transactionPending
                    ? "Transaction Pending"
                    : "Transaction Successful",
                style: AppTheme.body2White,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppTheme.paddingHeight / 2),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                Image.asset(
                  tokenIcon,
                  height: AppTheme.tokenIconHeight,
                ),
                SizedBox(
                  width: AppTheme.paddingHeight,
                ),
                Text(
                  "\$${data.amount} ${data.ticker}",
                  style: AppTheme.display1,
                  overflow: TextOverflow.fade,
                ),
                SizedBox(
                  width: AppTheme.paddingHeight20 * 2,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppTheme.paddingHeight / 2),
            child: Text(
              '\$${data.amount}',
              style: AppTheme.subtitle,
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }

  Widget getStatusCard() {
    var index = 0;
    if (bridgeApiData != null) {
      if (bridgeApiData.message.code == 4) {
        index = 0;
      } else if (bridgeApiData.message.code == 1) {
        index = 1;
      } else if (bridgeApiData.message.code == 0) {
        index = 2;
      }
    }
    return Card(
      shape: AppTheme.cardShape,
      child: Padding(
        padding: EdgeInsets.all(AppTheme.paddingHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                transactionPending
                    ? Icon(
                        Icons.timer,
                        color: AppTheme.yellow_500,
                      )
                    : Icon(
                        Icons.check,
                        color: Colors.teal[500],
                      ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: AppTheme.paddingHeight / 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transactionPending
                              ? 'Sending Transaction'
                              : "Transaction Successful",
                          style: AppTheme.header_H5,
                        ),
                        Text(
                          transactionPending
                              ? 'Transaction may take a few moments to complete.'
                              : "Transaction Finished Successfully",
                          maxLines: 4,
                          style: AppTheme.body2,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              bridgeApiData == null
                                  ? ""
                                  : '${bridgeApiData?.message?.msg}',
                              style: AppTheme.body2,
                            ),
                            IconButton(
                                icon: Icon(Icons.keyboard_arrow_down_outlined),
                                onPressed: () {
                                  setState(() {
                                    show = !show;
                                  });
                                }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (show)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    color: Colors.grey,
                  ),
                  TransactionDetailsTimeline(
                    details: processes,
                    doneTillIndex: index,
                    messages: messages,
                  )
                ],
              )
          ],
        ),
      ),
    );
  }

  Widget getListTile(
      {String imageUrl, String title, String subtitle, Widget trailing}) {
    return ListTile(
        leading: Image.asset(
          imageUrl,
          height: AppTheme.tokenIconHeight,
        ),
        title: Text(
          title,
          style: AppTheme.subtitle,
        ),
        subtitle: Text(
          subtitle,
          style: AppTheme.title,
          softWrap: true,
        ),
        trailing: trailing);
  }

  Widget detailsArea({String title, String subtitle, Widget topWidget}) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          topWidget,
          SizedBox(
            height: 8,
          ),
          Text(
            '$title',
            style: AppTheme.balanceMain,
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            '$subtitle',
            style: AppTheme.balanceSub
                .copyWith(color: AppTheme.balanceSub.color.withOpacity(0.6)),
          )
        ],
      ),
    );
  }

  _refreshLoop(String txhash) {
    new Timer.periodic(Duration(seconds: 15), (Timer t) {
      if (mounted &&
          (bridgeApiData == null || bridgeApiData.message.code != 0)) {
        DepositBridgeApi.depositStatusCode(txhash).then((value) {
          setState(() {
            bridgeApiData = value;
            if (value.message.code == 4) {
              transactionPending = true;
            }
          });
        });
      }
    });
  }
}

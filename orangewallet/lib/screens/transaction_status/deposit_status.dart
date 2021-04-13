import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:orangewallet/constants.dart';
import 'package:orangewallet/models/bridge_api_models/bridge_api_data.dart';
import 'package:orangewallet/models/deposit_models/deposit_transaction_db.dart';
import 'package:orangewallet/theme_data.dart';
import 'package:orangewallet/utils/api_wrapper/deposit_bridge_api.dart';
import 'package:orangewallet/utils/misc/box.dart';
import 'package:orangewallet/utils/misc/credential_manager.dart';
import 'package:orangewallet/utils/network/network_manager.dart';

import 'package:orangewallet/widgets/transaction_details_timeline.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class DepositStatus extends StatefulWidget {
  @override
  _DepositStatusState createState() => _DepositStatusState();
}

class _DepositStatusState extends State<DepositStatus> {
  DepositTransaction data;
  bool show = false;
  BridgeApiData bridgeApiData;
  bool transactionPending = true;
  String fromAddress = "";
  bool loading = true;
  String blockExplorer = "";
  var index = 0;
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
    NetworkManager.getNetworkObject().then((config) {
      blockExplorer = config.blockExplorerEth;
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        data = ModalRoute.of(context).settings.arguments;
        transactionPending = !data.merged;
      });

      DepositBridgeApi.depositStatusCode(data.txHash).then((value) {
        setState(() {
          bridgeApiData = value;
          if (value.message.code == 4) {
            transactionPending = true;
          } else {
            transactionPending = false;
          }
          if (value.message.code == 4) {
            index = 0;
          } else if (value.message.code == 1) {
            index = 1;
          } else if (value.message.code == 0) {
            index = 2;
          }
          if (value.message.code == 0) {
            BoxUtils.updateDepositStatus(data.txHash);
            transactionPending = false;
          }
          loading = false;
        });
      });
      if (!data.merged && transactionPending) {
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
                Share.share(
                  blockExplorer + "/tx/" + data.txHash,
                );
              })
        ],
      ),
      body: loading
          ? Center(
              child: SpinKitFadingFour(
                color: AppTheme.primaryColor,
                size: 50,
              ),
            )
          : data == null
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
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.cardRadius),
                                    color: AppTheme.stackingGrey,
                                  ),
                                  margin:
                                      EdgeInsets.all(AppTheme.paddingHeight),
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
                                          topWidget:
                                              Icon(Icons.flash_on_outlined)),
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
                                    icon: Icon(Icons.open_in_browser),
                                    onPressed: _launchURL,
                                  ),
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
                  "${data.amount} ${data.ticker}",
                  style: AppTheme.display1,
                  overflow: TextOverflow.fade,
                ),
                // SizedBox(
                //   width: AppTheme.paddingHeight20 * 2,
                // ),
              ],
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.all(AppTheme.paddingHeight / 2),
          //   child: Text(
          //     '\$${int.parse(data.amount)*data.}',
          //     style: AppTheme.subtitle,
          //     overflow: TextOverflow.fade,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget getStatusCard() {
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
          style: AppTheme.label_medium,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
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
            print(value);
            bridgeApiData = value;
            if (value.message.code != 4) {
              transactionPending = false;
            }
            if (value.message.code == 4) {
              index = 0;
            } else if (value.message.code == 1) {
              index = 1;
            } else if (value.message.code == 0) {
              index = 2;
            }
          });
        });
      }
    });
  }

  _launchURL() async {
    var url = blockExplorer + "/tx/" + data.txHash;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

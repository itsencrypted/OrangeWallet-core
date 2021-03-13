import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/bridge_api_models/bridge_api_data.dart';
import 'package:pollywallet/models/deposit_models/deposit_transaction_db.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/api_wrapper/deposit_bridge_api.dart';
import 'package:pollywallet/utils/misc/box.dart';
import 'package:timelines/timelines.dart';

class TransactionDetails extends StatefulWidget {
  @override
  _TransactionDetailsState createState() => _TransactionDetailsState();
}

class _TransactionDetailsState extends State<TransactionDetails> {
  bool show = false;
  Box<DepositTransaction> box;
  BridgeApiData bridgeApiData;
  final List<String> processes = [
    'done',
    'done',
    'asfa',
    'mun',
  ];

  @override
  void initState() {
    // TODO: implement initState
    //_getBox();
    super.initState();
  }

  _getBox() async {
    box = await BoxUtils.getDepositTransactionsList();
    log(box.values.toString());
    bridgeApiData =
        await DepositBridgeApi.depositStatusCode(box?.values?.first?.txHash);

    log(bridgeApiData.toString());
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            tokenIcon,
                            height: 36,
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Text(
                            "\$${box?.values?.first?.amount} ${box?.values?.first?.name}",
                            style: AppTheme.display1,
                          ),
                          SizedBox(
                            width: 52,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '\$${box?.values?.first?.amount}',
                        style: AppTheme.subtitle,
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.timer,
                            color: Colors.amber,
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Sending Transaction'),
                                  Text(
                                    'Transaction may take a few moments to complete.',
                                    maxLines: 4,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${bridgeApiData?.message?.code}'),
                                      IconButton(
                                          icon: Icon(Icons
                                              .arrow_drop_down_circle_outlined),
                                          onPressed: () {
                                            setState(() {
                                              show = !show;
                                            });
                                          })
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
                            )
                          ],
                        )
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
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
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            detailsArea(
                                title: '0.0001ETH',
                                subtitle: 'Transaction Fee',
                                topWidget: Icon(Icons.flash_on_outlined)),
                            detailsArea(
                                title: 'Matic Network',
                                subtitle: 'Netowrk',
                                topWidget: Icon(Icons.settings))
                          ],
                        ),
                      ),
                      ListTile(
                        leading: Image.asset(
                          tokenIcon,
                          height: 36,
                        ),
                        title: Text(
                          'from',
                          style: AppTheme.subtitle,
                        ),
                        subtitle: Text(
                          "afsassssss",
                          style: AppTheme.title,
                        ),
                        // trailing: IconButton(
                        //     icon: Icon(
                        //       Icons.file_copy,
                        //       color: Colors.black,
                        //     ),
                        //     onPressed: () {}),
                      ),
                      ListTile(
                        leading: Image.asset(
                          tokenIcon,
                          height: 36,
                        ),
                        title: Text(
                          'to',
                          style: AppTheme.subtitle,
                        ),
                        subtitle: Text(
                          "afsassssss",
                          style: AppTheme.title,
                        ),
                        trailing: IconButton(
                            icon: Icon(
                              Icons.file_copy,
                              color: Colors.black,
                            ),
                            onPressed: () {}),
                      ),
                      Divider(
                        color: Colors.grey,
                      ),
                      ListTile(
                        leading: Image.asset(
                          tokenIcon,
                          height: 36,
                        ),
                        title: Text(
                          'Transaction Hash',
                          style: AppTheme.subtitle,
                        ),
                        subtitle: Text(
                          "afsassssss",
                          style: AppTheme.title,
                        ),
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
}

class TransactionDetailsTimeline extends StatelessWidget {
  final List<String> details;
  TransactionDetailsTimeline({this.details});
  @override
  Widget build(BuildContext context) {
    return FixedTimeline.tileBuilder(
      mainAxisSize: MainAxisSize.min,
      theme: TimelineThemeData(
        direction: Axis.vertical,
        nodePosition: 0,
        color: Colors.blue,
        indicatorTheme: IndicatorThemeData(
          position: 0,
          size: 20.0,
        ),
        connectorTheme: ConnectorThemeData(
          thickness: 2.5,
        ),
      ),
      builder: TimelineTileBuilder.connected(
        connectionDirection: ConnectionDirection.before,
        itemCount: details.length,
        contentsBuilder: (_, index) {
          return Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  details[index],
                ),
                Text("messages: processes[index].messages"),
              ],
            ),
          );
        },
        indicatorBuilder: (_, index) {
          if (details[index] == 'done') {
            return DotIndicator(
              color: Colors.red,
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 12.0,
              ),
            );
          } else {
            return OutlinedDotIndicator(
              borderWidth: 2.5,
            );
          }
        },
        connectorBuilder: (_, index, ___) => SolidLineConnector(
          color: details[index] == 'done' ? Colors.red : null,
        ),
      ),
    );
  }
}

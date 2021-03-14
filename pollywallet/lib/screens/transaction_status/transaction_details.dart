import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/bridge_api_models/bridge_api_data.dart';
import 'package:pollywallet/models/deposit_models/deposit_transaction_db.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/api_wrapper/deposit_bridge_api.dart';
import 'package:pollywallet/utils/misc/box.dart';
import 'package:pollywallet/widgets/transaction_details_timeline.dart';

class TransactionDetails extends StatefulWidget {
  @override
  _TransactionDetailsState createState() => _TransactionDetailsState();
}

class _TransactionDetailsState extends State<TransactionDetails> {
  bool show = false;
  Box<DepositTransaction> box;
  BridgeApiData bridgeApiData;
  bool transactionPending = true;
  final List<String> processes = [
    'Initialized',
    'Transaction Pending',
    'Transaction Confirmed',
  ];

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
                      getListTile(
                        imageUrl: tokenIcon,
                        title: 'from',
                        subtitle: "afsassssss",
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
                      getListTile(
                        imageUrl: tokenIcon,
                        title: 'Transaction Hash',
                        subtitle: 'afsassssss',
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
          Container(
            padding: EdgeInsets.all(AppTheme.paddingHeight / 4),
            decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(AppTheme.cardRadiusSmall)),
            child: Text(
              'afsasfa',
              style: AppTheme.body2White,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppTheme.paddingHeight / 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  tokenIcon,
                  height: AppTheme.tokenIconHeight,
                ),
                SizedBox(
                  width: AppTheme.paddingHeight,
                ),
                Text(
                  "\$${box?.values?.first?.amount} ${box?.values?.first?.name}",
                  style: AppTheme.display1,
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
              '\$${box?.values?.first?.amount}',
              style: AppTheme.subtitle,
            ),
          ),
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
                              '${bridgeApiData?.message?.code}',
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
                    doneTillIndex: 1,
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
}

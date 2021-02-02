import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/covalent_models/matic_transactions_list.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/api_wrapper/covalent_api_wrapper.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';

class MaticTransactionList extends StatefulWidget {
  @override
  _MaticTransactionListState createState() => _MaticTransactionListState();
}

class _MaticTransactionListState extends State<MaticTransactionList> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: AppTheme.cardShape,
      elevation: AppTheme.cardElevations,
      color: AppTheme.white,
      child: FutureBuilder(
        future: CovalentApiWrapper.maticTransactionList(),
        builder: (BuildContext context, response) {
          if (response.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitFadingFour(
                color: AppTheme.primaryColor,
                size: 50,
              ),
            );
          } else if (response.connectionState == ConnectionState.done) {
            return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  itemCount: response.data.data.items.length,
                  itemBuilder: (context, index) {
                    TransactionItem item = response.data.data.items[index];

                    return FlatButton(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ListTile(
                            isThreeLine: true,
                            leading: Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                              size: 30,
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    EthConversions.weiToEth(
                                            BigInt.parse(item.value), 18)
                                        .toString(),
                                    style: AppTheme.title),
                                Text(
                                  item.valueQuote == null
                                      ? "\$0.0"
                                      : "\$" + item.valueQuote.toString(),
                                  style: AppTheme.subtitle,
                                ),
                              ],
                            ),
                            title: Text(
                              item.txHash,
                              style: AppTheme.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: item.toAddress == null
                                ? Container()
                                : Wrap(
                                    alignment: WrapAlignment.start,
                                    children: [
                                      Icon(Icons.arrow_forward),
                                      Text(
                                        item.toAddress,
                                        style: AppTheme.subtitle,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                          ),
                          Divider(
                            color: AppTheme.grey,
                          )
                        ],
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                            context, transactionStatusMaticRoute,
                            arguments: item.txHash);
                      },
                    );
                  },
                ));
          } else {
            return Center(
                child: Text(
              "Something Went Wrong",
              style: AppTheme.subtitle,
            ));
          }
        },
      ),
    );
  }

  Future<void> _refresh() async {
    setState(() {});
  }
}

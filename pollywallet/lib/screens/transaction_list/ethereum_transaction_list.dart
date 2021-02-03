import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/etherscan_models/etherescan_tx_list.dart';
import 'package:pollywallet/models/transaction_models/transaction_information.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/api_wrapper/etherscan_api_wrapper.dart';
import 'package:pollywallet/utils/misc/box.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';

class EthereumTransactionList extends StatefulWidget {
  @override
  _EthereumTransactionListState createState() =>
      _EthereumTransactionListState();
}

class _EthereumTransactionListState extends State<EthereumTransactionList>
    with AutomaticKeepAliveClientMixin<EthereumTransactionList> {
  bool _loading = true;
  bool _error = false;
  List<Result> result;
  List<TransactionDetails> pendingTx;
  @override
  void initState() {
    try {
      EtherscanApiWrapper.transactionList().then((value) {
        BoxUtils.getPendingTx(value).then((pending) {
          setState(() {
            result = value.result.reversed.toList();
            pendingTx = pending;
            _loading = false;
          });
        });
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        _error = true;
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
          shape: AppTheme.cardShape,
          elevation: AppTheme.cardElevations,
          color: AppTheme.white,
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: SizedBox(
              height: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _loading || _error || pendingTx.isEmpty
                        ? Container()
                        : Text("Pending Transaction", style: AppTheme.subtitle),
                    _loading || _error || pendingTx.isEmpty
                        ? Container()
                        : ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: pendingTx.length,
                            itemBuilder: (context, index) {
                              TransactionDetails item = pendingTx[index];
                              return FlatButton(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ListTile(
                                      isThreeLine: true,
                                      leading: Icon(
                                        Icons.timer,
                                        color: Colors.red,
                                        size: 30,
                                      ),
                                      title: Text(
                                        item.txHash,
                                        style: AppTheme.title,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: Text(
                                        "Waiting..",
                                        style: AppTheme.title,
                                      ),
                                      subtitle: item.to == null
                                          ? Container()
                                          : Wrap(
                                              alignment: WrapAlignment.start,
                                              children: [
                                                Icon(Icons.arrow_forward),
                                                Text(
                                                  item.to,
                                                  style: AppTheme.subtitle,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                      context, ethereumTransactionStatusRoute,
                                      arguments: item.txHash);
                                },
                              );
                            },
                          ),
                    _loading || _error || result.isEmpty
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Merged  Transactions",
                              style: AppTheme.subtitle,
                            ),
                          ),
                    _loading
                        ? SizedBox(
                            height: MediaQuery.of(context).size.height * 0.8,
                            child: Center(
                              child: SpinKitFadingFour(
                                size: 50,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          )
                        : _error
                            ? Center(
                                child: Text(
                                  "Something went wrong..",
                                  style: AppTheme.body1,
                                ),
                              )
                            : result.isEmpty && pendingTx.isEmpty
                                ? SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.8,
                                    child: Center(
                                      child: Text(
                                        "No Transactions",
                                        style: AppTheme.subtitle,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: result.length,
                                    itemBuilder: (context, index) {
                                      Result item = result[index];
                                      return FlatButton(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ListTile(
                                              isThreeLine: true,
                                              leading: Icon(
                                                Icons.check_circle_outline,
                                                color: Colors.green,
                                                size: 30,
                                              ),
                                              trailing: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                      EthConversions.weiToEth(
                                                                  BigInt.parse(
                                                                      item.value),
                                                                  18)
                                                              .toString() +
                                                          " ETH",
                                                      style: AppTheme.title),
                                                ],
                                              ),
                                              title: Text(
                                                item.hash,
                                                style: AppTheme.title,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              subtitle: item.to == null
                                                  ? Container()
                                                  : Wrap(
                                                      alignment:
                                                          WrapAlignment.start,
                                                      children: [
                                                        Icon(Icons
                                                            .arrow_forward),
                                                        Text(
                                                          item.to,
                                                          style:
                                                              AppTheme.subtitle,
                                                          overflow: TextOverflow
                                                              .ellipsis,
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
                                          Navigator.pushNamed(context,
                                              ethereumTransactionStatusRoute,
                                              arguments: item.hash);
                                        },
                                      );
                                    },
                                  ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Future<void> _refresh() async {
    try {
      var mergedTx = await EtherscanApiWrapper.transactionList();
      pendingTx = await BoxUtils.getPendingTx(mergedTx);
      result = mergedTx.result.reversed.toList();
      setState(() {});
    } catch (e) {
      print(e.toString());
      setState(() {
        _error = true;
      });
    }
  }

  @override
  bool get wantKeepAlive => true;
}

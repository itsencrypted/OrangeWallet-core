import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
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
  List<TransactionDetails> pendingTx = <TransactionDetails>[];
  @override
  void initState() {
    try {
      EtherscanApiWrapper.transactionList().then((value) {
        setState(() {
          result = value.result.reversed.toList();
          _loading = false;
        });
        BoxUtils.getPendingTx(value).then((pending) {
          setState(() {
            pendingTx = pending;
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
    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _loading || _error || pendingTx.isEmpty
                ? Container()
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child:
                        Text("Pending Transaction", style: AppTheme.subtitle),
                  ),
            _loading || _error || pendingTx.isEmpty
                ? Container()
                : ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: pendingTx.length,
                    itemBuilder: (context, index) {
                      TransactionDetails item = pendingTx[index];
                      return Card(
                        shape: AppTheme.cardShape,
                        elevation: AppTheme.cardElevations,
                        child: InkWell(
                          child: ListTile(
                            leading: Padding(
                              padding: EdgeInsets.only(
                                  left: AppTheme.paddingHeight12 / 2),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.timer,
                                    color: Colors.yellow,
                                    size: AppTheme.tokenIconHeight,
                                  ),
                                ],
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("Waiting..",
                                    style: AppTheme.label_medium
                                        .copyWith(color: AppTheme.teal_500)),
                                // Text(
                                //   EthConversions.weiToEth(
                                //               BigInt.parse(item.value),
                                //               18)
                                //           .toString() +
                                //       " ETH",
                                //   style: AppTheme.subtitle,
                                // ),
                              ],
                            ),
                            title: Text(
                              pendingTx[index].txHash,
                              style: AppTheme.label_medium,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: pendingTx[index].time == null
                                ? Container()
                                : Text(
                                    DateFormat.yMMMEd().add_jm().format(
                                        DateTime.parse(pendingTx[index].time)),
                                    style: AppTheme.body_small,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                                context, ethereumTransactionStatusRoute,
                                arguments: pendingTx[index].txHash);
                          },
                        ),
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
                            height: MediaQuery.of(context).size.height * 0.8,
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
                              return Card(
                                shape: AppTheme.cardShape,
                                elevation: AppTheme.cardElevations,
                                child: InkWell(
                                  child: ListTile(
                                    leading: Padding(
                                      padding: EdgeInsets.only(
                                          left: AppTheme.paddingHeight12 / 2),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          item.isError == "0"
                                              ? Icon(
                                                  Icons.check_circle_outline,
                                                  color: Colors.green,
                                                  size:
                                                      AppTheme.tokenIconHeight,
                                                )
                                              : Icon(
                                                  Icons.cancel_outlined,
                                                  color: Colors.red,
                                                  size:
                                                      AppTheme.tokenIconHeight,
                                                ),
                                        ],
                                      ),
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
                                            style: AppTheme.label_medium
                                                .copyWith(
                                                    color: AppTheme.teal_500)),
                                        // Text(
                                        //   EthConversions.weiToEth(
                                        //               BigInt.parse(item.value),
                                        //               18)
                                        //           .toString() +
                                        //       " ETH",
                                        //   style: AppTheme.subtitle,
                                        // ),
                                      ],
                                    ),
                                    title: Text(
                                      item.hash,
                                      style: AppTheme.label_medium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      DateFormat.yMMMEd().add_jm().format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              int.parse(item.timeStamp) *
                                                  1000)),
                                      style: AppTheme.body_small,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, ethereumTransactionStatusRoute,
                                        arguments: item.hash);
                                  },
                                ),
                              );
                            },
                          ),
          ],
        ),
      ),
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

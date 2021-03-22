import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/covalent_models/matic_transactions_list.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/api_wrapper/covalent_api_wrapper.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';

class MaticTransactionList extends StatefulWidget {
  @override
  _MaticTransactionListState createState() => _MaticTransactionListState();
}

class _MaticTransactionListState extends State<MaticTransactionList>
    with AutomaticKeepAliveClientMixin<MaticTransactionList> {
  bool _loading = true;
  bool _error = false;
  MaticTransactionListModel list;
  @override
  void initState() {
    try {
      CovalentApiWrapper.maticTransactionList().then((value) {
        setState(() {
          list = value;
          _loading = false;
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _loading || _error || list.data.items.isEmpty
            ? Container()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Transaction List",
                  style: AppTheme.subtitle,
                ),
              ),
        Expanded(
          child: RefreshIndicator(
              onRefresh: _refresh,
              child: _loading
                  ? Center(
                      child: SpinKitFadingFour(
                        size: 50,
                        color: AppTheme.primaryColor,
                      ),
                    )
                  : _error
                      ? Center(
                          child: Text(
                            "Something went wrong..",
                            style: AppTheme.body1,
                          ),
                        )
                      : list.data.items.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [Text("No transactions")],
                              ),
                            )
                          : ListView.builder(
                              itemCount: list.data.items.length,
                              itemBuilder: (context, index) {
                                TransactionItem item = list.data.items[index];
                                return Card(
                                  shape: AppTheme.cardShape,
                                  elevation: AppTheme.cardElevations,
                                  child: InkWell(
                                    child: ListTile(
                                      // isThreeLine: true,
                                      leading: Padding(
                                        padding: EdgeInsets.only(
                                            left: AppTheme.paddingHeight12 / 2),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            item.successful
                                                ? Icon(
                                                    Icons.check_circle_outline,
                                                    color: Colors.green,
                                                    size: AppTheme
                                                        .tokenIconHeight,
                                                  )
                                                : Icon(
                                                    Icons.cancel_outlined,
                                                    color: Colors.red,
                                                    size: AppTheme
                                                        .tokenIconHeight,
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
                                              item.valueQuote == null
                                                  ? "\$0.0"
                                                  : "\$" +
                                                      item.valueQuote
                                                          .toString(),
                                              style: AppTheme.label_medium
                                                  .copyWith(
                                                      color:
                                                          AppTheme.teal_500)),
                                          Text(
                                            EthConversions.weiToEth(
                                                        BigInt.parse(
                                                            item.value),
                                                        18)
                                                    .toString() +
                                                " MATIC",
                                            style: AppTheme.subtitle,
                                          ),
                                        ],
                                      ),
                                      title: Text(
                                        item.txHash,
                                        style: AppTheme.label_medium,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: item.toAddress == null
                                          ? Container()
                                          : Text(
                                              DateFormat.yMMMEd()
                                                  .add_jm()
                                                  .format(DateTime.parse(
                                                      item.blockSignedAt)),
                                              style: AppTheme.body_small,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                    ),
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, transactionStatusMaticRoute,
                                          arguments: item.txHash);
                                    },
                                  ),
                                );
                              },
                            )),
        ),
      ],
    );
  }

  Future<void> _refresh() async {
    try {
      list = await CovalentApiWrapper.maticTransactionList();
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

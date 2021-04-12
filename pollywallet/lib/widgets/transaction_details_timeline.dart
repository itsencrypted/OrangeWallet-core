import 'package:flutter/material.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/transaction_data/transaction_data.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/web3_utils/ethereum_transactions.dart';
import 'package:pollywallet/widgets/loading_indicator.dart';
import 'package:timelines/timelines.dart';
import 'package:web3dart/web3dart.dart';

class TransactionDetailsTimeline extends StatelessWidget {
  final List<String> details;
  final List<String> messages;
  final int doneTillIndex;
  final String txHash;
  TransactionDetailsTimeline(
      {this.details, this.messages, this.doneTillIndex, this.txHash});
  @override
  Widget build(BuildContext context) {
    return FixedTimeline.tileBuilder(
      mainAxisSize: MainAxisSize.min,
      theme: TimelineThemeData(
        direction: Axis.vertical,
        nodePosition: 0,
        color: AppTheme.warmgray_200,
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
                  style: AppTheme.body_small_bold,
                ),
                messages[index] == "sup"
                    ? index == doneTillIndex
                        ? RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            color: sendButtonColor.withOpacity(0.6),
                            child: Text("Speedup Transaction"),
                            onPressed: () {
                              _speedUp(context, txHash);
                            })
                        : Text("Transaction is being mined",
                            style: AppTheme.caption_normal)
                    : Text(
                        "${messages[index]}",
                        style: AppTheme.caption_normal,
                      ),
              ],
            ),
          );
        },
        indicatorBuilder: (_, index) {
          if (index <= doneTillIndex) {
            return DotIndicator(
              color: AppTheme.orange_500,
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
          color: index <= doneTillIndex ? AppTheme.orange_500 : null,
        ),
      ),
    );
  }

  _speedUp(BuildContext context, String txHash) async {
    GlobalKey<State> key = GlobalKey();
    Dialogs.showLoadingDialog(context, key);
    Transaction trx = await EthereumTransactions.speedUpTransaction(txHash);
    TransactionData data = TransactionData(
        trx: trx,
        type: TransactionType.SPEEDUP,
        to: trx.to.hex,
        gas: trx.gasPrice.getInWei,
        amount: trx.value.getInEther.toString());
    Navigator.of(key.currentContext, rootNavigator: true).pop();
    Navigator.pushNamed(context, ethereumTransactionConfirmRoute,
        arguments: data);
  }
}

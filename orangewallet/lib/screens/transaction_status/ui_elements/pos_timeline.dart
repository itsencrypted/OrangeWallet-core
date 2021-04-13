import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:orangewallet/constants.dart';
import 'package:orangewallet/models/covalent_models/covalent_token_list.dart';
import 'package:orangewallet/models/transaction_data/transaction_data.dart';
import 'package:orangewallet/models/withdraw_models/withdraw_data_db.dart';
import 'package:orangewallet/theme_data.dart';
import 'package:orangewallet/utils/network/network_config.dart';
import 'package:orangewallet/utils/network/network_manager.dart';
import 'package:orangewallet/utils/withdraw_manager/withdraw_manager_web3.dart';
import 'package:orangewallet/widgets/loading_indicator.dart';
import 'package:timelines/timelines.dart';
import 'package:web3dart/web3dart.dart';

class PosTimeline extends StatelessWidget {
  final List<String> details;
  final List<String> messages;
  final int doneTillIndex;
  final String txHash;
  final WithdrawDataDb data;
  PosTimeline(
      {this.details,
      this.messages,
      this.doneTillIndex,
      this.txHash,
      this.data});
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
                messages[index] == "exit"
                    ? index == doneTillIndex
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                color: AppTheme.primaryColor.withOpacity(1),
                                child: SizedBox(
                                    width: 100,
                                    child: Center(
                                      child: Text(
                                        "Exit POS",
                                        style: AppTheme.body2White,
                                      ),
                                    )),
                                onPressed: () {
                                  _exit(context, data.burnHash, data);
                                }),
                          )
                        : Text("Ready for exit", style: AppTheme.caption_normal)
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
              color: AppTheme.primaryColor,
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
          color: index <= doneTillIndex ? AppTheme.primaryColor : null,
        ),
      ),
    );
  }

  _exit(BuildContext context, String txHash, WithdrawDataDb _data) async {
    GlobalKey<State> _key = GlobalKey<State>();
    Dialogs.showLoadingDialog(context, _key);
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    Transaction trx = await WithdrawManagerWeb3.exitPos(txHash);
    if (trx == null) {
      Fluttertoast.showToast(msg: "Something Went Wrong");
      Navigator.of(_key.currentContext, rootNavigator: true).pop();
      return;
    }
    TransactionData data = TransactionData(
        amount: _data.amount,
        type: TransactionType.EXITPOS,
        to: config.rootChainProxy,
        extraData: [_data.burnHash, _data.notificationId],
        token: Items(contractTickerSymbol: _data.name),
        trx: trx);
    Navigator.of(_key.currentContext, rootNavigator: true).pop();
    await Navigator.pushNamed(context, ethereumTransactionConfirmRoute,
        arguments: data);
  }
}

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/covalent_models/covalent_token_list.dart';
import 'package:pollywallet/models/transaction_data/transaction_data.dart';
import 'package:pollywallet/models/withdraw_models/withdraw_data_db.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/network/network_config.dart';
import 'package:pollywallet/utils/network/network_manager.dart';
import 'package:pollywallet/utils/withdraw_manager/withdraw_manager_api.dart';
import 'package:pollywallet/utils/withdraw_manager/withdraw_manager_web3.dart';
import 'package:pollywallet/widgets/loading_indicator.dart';
import 'package:timelines/timelines.dart';
import 'package:web3dart/web3dart.dart';

class PlasmaTimeline extends StatefulWidget {
  final List<String> details;
  final List<String> messages;
  final int doneTillIndex;
  final String txHash;
  final WithdrawDataDb data;
  PlasmaTimeline(
      {this.details,
      this.messages,
      this.doneTillIndex,
      this.txHash,
      this.data});

  @override
  _PlasmaTimelineState createState() => _PlasmaTimelineState();
}

class _PlasmaTimelineState extends State<PlasmaTimeline> {
  DateTime endTime;
  @override
  void initState() {
    if (widget.messages[widget.doneTillIndex] == "challenge") {
      _getExitTime();
    }
    super.initState();
  }

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
        itemCount: widget.details.length,
        contentsBuilder: (_, index) {
          return Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.details[index], style: AppTheme.body_small_bold),
                widget.messages[index] == "challenge"
                    ? endTime == null
                        ? Text("Waiting for challenge period to be over")
                        : Text(
                            "You will be able to exit on ${endTime.day} ${endTime.month} ${endTime.year} - ${endTime.hour}:${endTime.minute}")
                    : widget.messages[index] == "confirm"
                        ? widget.doneTillIndex == index
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    color: sendButtonColor.withOpacity(0.6),
                                    child: SizedBox(
                                        width: 100,
                                        child: Center(
                                            child: Text("Confirm Exit"))),
                                    onPressed: () {
                                      _confirm();
                                    }),
                              )
                            : Text(
                                "Exit to be confirmed",
                                style: AppTheme.caption_normal,
                              )
                        : widget.messages[index] == "exit"
                            ? widget.doneTillIndex == index
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RaisedButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        color: sendButtonColor.withOpacity(0.6),
                                        child: SizedBox(
                                            width: 100,
                                            child: Center(
                                                child: Text("Exit POS"))),
                                        onPressed: () {
                                          _exit();
                                        }),
                                  )
                                : Text(
                                    "Ready for exit",
                                    style: AppTheme.caption_normal,
                                  )
                            : Text(
                                "${widget.messages[index]}",
                                style: AppTheme.caption_normal,
                              ),
              ],
            ),
          );
        },
        indicatorBuilder: (_, index) {
          if (index <= widget.doneTillIndex) {
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
          color: index <= widget.doneTillIndex ? AppTheme.orange_500 : null,
        ),
      ),
    );
  }

  _getExitTime() async {
    int endTime = DateTime.now().millisecondsSinceEpoch +
        int.parse(await WithdrawManagerApi.plasmaExitTime(
                widget.data.burnHash, widget.data.confirmHash) *
            1000);
    setState(() {
      this.endTime = DateTime.fromMillisecondsSinceEpoch(endTime);
    });
  }

  _exit() async {
    GlobalKey<State> _key = GlobalKey<State>();
    Dialogs.showLoadingDialog(context, _key);
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    Transaction trx =
        await WithdrawManagerWeb3.exitPlasma(widget.data.addressRoot);
    if (trx == null) {
      Fluttertoast.showToast(msg: "Something Went Wrong");
      Navigator.of(_key.currentContext, rootNavigator: true).pop();

      return;
    }
    TransactionData data = TransactionData(
        amount: widget.data.amount,
        type: TransactionType.EXITPLASMA,
        to: config.withdrawManagerProxy,
        extraData: [widget.data.burnHash, widget.data.notificationId],
        token: Items(contractTickerSymbol: widget.data.name),
        trx: trx);
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.pushNamed(context, ethereumTransactionConfirmRoute,
        arguments: data);
  }

  _confirm() async {
    GlobalKey<State> _key = GlobalKey<State>();
    Dialogs.showLoadingDialog(context, _key);
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    Transaction trx =
        await WithdrawManagerWeb3.initiateExitPlasma(widget.data.burnHash);
    if (trx == null) {
      Fluttertoast.showToast(msg: "Something Went Wrong");
      Navigator.of(_key.currentContext, rootNavigator: true).pop();

      return;
    }
    TransactionData data = TransactionData(
        amount: widget.data.amount,
        type: TransactionType.CONFIRMPLASMA,
        to: config.erc20PredicatePos,
        extraData: [widget.data.burnHash],
        token: Items(contractTickerSymbol: widget.data.name),
        trx: trx);
    Navigator.of(_key.currentContext, rootNavigator: true).pop();
    Navigator.pushNamed(context, ethereumTransactionConfirmRoute,
        arguments: data);
  }
}

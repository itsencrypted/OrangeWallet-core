import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/withdraw_models/withdraw_data_db.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/withdraw_manager/withdraw_manager_api.dart';

class WithdrawNotificationTile extends StatefulWidget {
  final WithdrawDataDb withdrawDataDb;

  const WithdrawNotificationTile({Key key, this.withdrawDataDb})
      : super(key: key);

  @override
  _WithdrawNotificationTileState createState() =>
      _WithdrawNotificationTileState();
}

class _WithdrawNotificationTileState extends State<WithdrawNotificationTile> {
  var bridge;
  int status = 0;
  bool loading = true;
  DateTime endtime;
  @override
  void initState() {
    bridge = widget.withdrawDataDb.bridge;
    if (bridge == BridgeType.POS.index) {
      WithdrawManagerApi.posStatusCodes(
              widget.withdrawDataDb.burnHash, widget.withdrawDataDb.exitHash)
          .then((value) {
        setState(() {
          status = value;
          loading = false;
        });
      });
      print(status);
    } else {
      WithdrawManagerApi.plasmaStatusCodes(widget.withdrawDataDb.burnHash,
              widget.withdrawDataDb.confirmHash, widget.withdrawDataDb.exitHash)
          .then((value) {
        if (value == -8) {
          WithdrawManagerApi.plasmaExitTime(widget.withdrawDataDb.burnHash,
                  widget.withdrawDataDb.confirmHash)
              .then((time) {
            try {
              int endTime = DateTime.now().millisecondsSinceEpoch +
                  int.parse(time) * 1000;
              this.endtime = DateTime.fromMillisecondsSinceEpoch(endTime);
            } catch (e) {}
          });
          setState(() {
            status = value;
            loading = false;
          });
        } else {
          setState(() {
            status = value;
            loading = false;
          });
        }
        print(status);
      });
    }
    _refreshLoop();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        shape: AppTheme.cardShape,
        elevation: AppTheme.cardElevations,
        child: InkWell(
          child: ListTile(
            leading: Padding(
              padding: EdgeInsets.only(left: AppTheme.paddingHeight12 / 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    loading
                        ? Icons.timer
                        : status == -4
                            ? Icons.pending_actions_outlined
                            : status == -10 || status == -5
                                ? Icons.check_outlined
                                : status == -2 ||
                                        status == -11 ||
                                        status == -7 ||
                                        status == -6
                                    ? Icons.cancel_outlined
                                    : Icons.timer,
                    color: loading
                        ? Colors.yellow
                        : status == -4
                            ? Colors.blue
                            : status == -10 || status == -5
                                ? Colors.green
                                : status == -8
                                    ? Colors.yellow
                                    : status == -9
                                        ? Colors.blue
                                        : status == -2 ||
                                                status == -11 ||
                                                status == -7 ||
                                                status == -6
                                            ? Colors.red
                                            : Colors.yellow,
                    size: AppTheme.tokenIconHeight,
                  ),
                ],
              ),
            ),
            title: Text(
              widget.withdrawDataDb.name,
              style: AppTheme.label_medium,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: loading
                ? Text("....")
                : status == -4
                    ? bridge == 1
                        ? Text("Ready for exit to Ethereum")
                        : Text("Withdraw needs to be confirmed")
                    : status == -10
                        ? Text("Withdraw Successful")
                        : status == -2 || status == -11
                            ? Text("Withdraw Faild")
                            : status == -8
                                ? Text(endtime != null
                                    ? "Token will be ready for exit at ${endtime.day} ${endtime.month} ${endtime.year}  ${endtime.hour}: ${endtime.minute}"
                                    : "Tokens will be soon ready for exit")
                                : status == -9
                                    ? Text("Token is ready for exit")
                                    : Text(
                                        "Please wait withdraw is under progress..."),
          ),
          onTap: () {
            print(bridge);
            if (bridge == 1) {
              Navigator.pushNamed(context, withdrawStatusPosRoute,
                  arguments: widget.withdrawDataDb);
            } else {
              Navigator.pushNamed(context, withdrawStatusPlasmaRoute,
                  arguments: widget.withdrawDataDb);
            }
          },
        ),
      ),
    );
  }

  _refreshLoop() {
    new Timer.periodic(Duration(seconds: 15), (Timer t) {
      if (mounted &&
          status != -4 &&
          status != -10 &&
          status != -2 &&
          status != -11 &&
          status != -5) {
        bridge = widget.withdrawDataDb.bridge;
        if (bridge == BridgeType.POS.index) {
          WithdrawManagerApi.posStatusCodes(widget.withdrawDataDb.burnHash,
                  widget.withdrawDataDb.exitHash)
              .then((value) {
            setState(() {
              status = value;
              loading = false;
            });
          });
        } else {
          WithdrawManagerApi.plasmaStatusCodes(
                  widget.withdrawDataDb.burnHash,
                  widget.withdrawDataDb.confirmHash,
                  widget.withdrawDataDb.exitHash)
              .then((value) {
            if (value == -8) {
              WithdrawManagerApi.plasmaExitTime(widget.withdrawDataDb.burnHash,
                      widget.withdrawDataDb.confirmHash)
                  .then((time) {
                try {
                  int endTime = DateTime.now().millisecondsSinceEpoch +
                      int.parse(time) * 1000;
                  this.endtime = DateTime.fromMillisecondsSinceEpoch(endTime);
                } catch (e) {}
              });
              setState(() {
                status = value;
                loading = false;
              });
            } else {
              setState(() {
                status = value;
                loading = false;
              });
            }
          });
        }
      }
    });
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pollywallet/models/staking_models/unbonding_data_db.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/misc/staking_utils.dart';
import 'package:pollywallet/utils/web3_utils/staking_transactions.dart';
import 'dart:math';

class StakingNotificationTile extends StatefulWidget {
  final UnbondingDataDb unbondingDataDb;

  const StakingNotificationTile({Key key, this.unbondingDataDb})
      : super(key: key);

  @override
  _StakingNotificationTileState createState() =>
      _StakingNotificationTileState();
}

class _StakingNotificationTileState extends State<StakingNotificationTile> {
  BigInt epoch;
  BigInt amount;
  BigInt nonce;
  int unlockTime;
  bool loading = true;
  bool unlockable = false;
  bool claimed = false;
  @override
  void initState() {
    super.initState();
    if (widget.unbondingDataDb.claimed) {
      setState(() {
        claimed = true;
      });
      return;
    }
    StakingTransactions.stakeClaimData(widget.unbondingDataDb.validatorAddress)
        .then((value) {
      epoch = value[0][1];
      amount = value[0][0];
      nonce = value[1];
      setState(() {
        unlockTime = StakingUtils.toFullEpoch(epoch.toInt());
        unlockTime =
            (StakingUtils.toFullEpoch(epoch.toInt()) + pow(2, 13)) * 1000;
        loading = false;
        unlockable = StakingUtils.checkEpoch(epoch.toInt());
        _refreshLoop();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  claimed ? Icons.check_circle_outline : Icons.timer,
                  color: claimed ? Colors.green : Colors.yellow,
                  size: AppTheme.tokenIconHeight,
                ),
              ],
            ),
          ),
          title: Text(
            widget.unbondingDataDb.name,
            style: AppTheme.label_medium,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: loading
              ? Text("....")
              : claimed
                  ? Text("Stake Claimed")
                  : unlockable
                      ? Text("Ready for unlock")
                      : Text("Not ready for unlock"),
        ),
        onTap: () {
          // Navigator.pushNamed(
          //     context, ethereumTransactionStatusRoute,
          //     arguments: pendingTx[index].txHash);
        },
      ),
    );
  }

  _refreshLoop() {
    new Timer.periodic(Duration(seconds: 30), (Timer t) {
      if (mounted && !unlockable) {
        setState(() {
          unlockTime = StakingUtils.toFullEpoch(epoch.toInt());
          unlockTime =
              (StakingUtils.toFullEpoch(epoch.toInt()) + pow(10, 13)) * 1000;
          loading = false;
          unlockable = StakingUtils.checkEpoch(epoch.toInt());
        });
      }
    });
  }
}

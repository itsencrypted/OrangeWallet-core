import 'package:flutter/material.dart';
import 'package:pollywallet/models/staking_models/unbonding_data_db.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/web3_utils/staking_transactions.dart';

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
  BigInt unlockTime;
  @override
  void initState() {
    StakingTransactions.stakeClaimData(widget.unbondingDataDb.validatorAddress)
        .then((value) {
      epoch = value[0][1];
      amount = value[0][0];
      nonce = value[1];
    });
    unlockTime = BigInt.parse(widget.unbondingDataDb.timeString) +
        BigInt.from(10).pow(13);
    unlockTime += BigInt.from(2000);
    unlockTime = unlockTime * BigInt.from(1000);
    super.initState();
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
                  Icons.timer,
                  color: Colors.yellow,
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
          subtitle: DateTime.now().millisecondsSinceEpoch > unlockTime.toInt()
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
}

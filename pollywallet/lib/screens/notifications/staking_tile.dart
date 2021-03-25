import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/covalent_models/covalent_token_list.dart';
import 'package:pollywallet/models/staking_models/unbonding_data_db.dart';
import 'package:pollywallet/models/staking_models/validators.dart';
import 'package:pollywallet/models/transaction_data/transaction_data.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/misc/staking_utils.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';
import 'package:pollywallet/utils/web3_utils/staking_transactions.dart';
import 'package:pollywallet/widgets/loading_indicator.dart';
import 'dart:math';

import 'package:web3dart/web3dart.dart';

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
  bool legacyWithdraw = true;
  bool loading = true;
  bool unlockable = false;
  bool claimed = false;
  DateTime date;
  @override
  void initState() {
    super.initState();
    if (widget.unbondingDataDb.claimed) {
      setState(() {
        claimed = true;
        loading = false;
      });
      return;
    }
    StakingTransactions.stakeClaimData(widget.unbondingDataDb.validatorAddress)
        .then((value) {
      epoch = value[0][1];
      amount = value[0][0];
      nonce = value[1];

      setState(() {
        legacyWithdraw = value[2];
        unlockTime = StakingUtils.toFullEpoch(epoch.toInt());
        unlockTime =
            (StakingUtils.toFullEpoch(epoch.toInt()) + pow(2, 13)) * 1000;
        loading = false;
        date = DateTime.fromMillisecondsSinceEpoch(unlockTime);
        unlockable = StakingUtils.checkEpoch(epoch.toInt());
        _refreshLoop();
      });
    });
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
                    unlockable
                        ? Icons.pending_actions_outlined
                        : claimed
                            ? Icons.check_circle_outline
                            : Icons.timer,
                    color: unlockable
                        ? Colors.blue
                        : claimed
                            ? Colors.green
                            : Colors.yellow,
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
                        ? Text("Tap to claim stake")
                        : Text(
                            "Can be claimed at ${date.day} - ${date.month} - ${date.year}  ${date.hour}:${date.minute}"),
          ),
          onTap: () {
            if (unlockable) {
              _claimStake(
                  ValidatorInfo(
                      contractAddress: widget.unbondingDataDb.validatorAddress,
                      name: widget.unbondingDataDb.name,
                      id: widget.unbondingDataDb.validatorId),
                  Items(contractName: "Matic", contractTickerSymbol: "Matic"),
                  EthConversions.weiToEth(widget.unbondingDataDb.amount, 18)
                      .toString());
            } else {
              Navigator.pushNamed(context, validatorAndDelegationProfileRoute,
                  arguments: widget.unbondingDataDb.validatorId);
            }
          },
        ),
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

  _claimStake(ValidatorInfo validator, Items token, String amount) async {
    TransactionData data;
    Transaction trx;
    GlobalKey<State> key = GlobalKey();
    Dialogs.showLoadingDialog(context, key);
    trx = await StakingTransactions.claimStake(
        validator.contractAddress, nonce, legacyWithdraw);

    data = TransactionData(
        amount: amount,
        validatorData: validator,
        to: validator.contractAddress,
        token: token,
        type: TransactionType.CLAIMSTAKE,
        trx: trx,
        extraData: [widget.unbondingDataDb.notificationId]);

    Navigator.of(context, rootNavigator: true).pop();
    Navigator.pushNamed(context, ethereumTransactionConfirmRoute,
        arguments: data);
  }
}

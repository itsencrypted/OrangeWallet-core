import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/covalent_models/token_history.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';

class TransactionTile extends StatelessWidget {
  final TransferInfo data;
  final String address;
  const TransactionTile({Key key, this.data, this.address}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    bool sent = data.transfers[0].fromAddress == address;
    var value = EthConversions.weiToEth(BigInt.parse(data.value), null)
        .toStringAsFixed(2);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              // isThreeLine: true,
              leading: Image.asset(
                tokenIcon,
                height: 32,
                width: 32,
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(sent ? "- $value" : "+ $value",
                      style: AppTheme.label_medium.copyWith(
                          color: sent ? AppTheme.red_500 : AppTheme.teal_500)),
                  // Text(
                  //   EthConversions.weiToEth(BigInt.parse(value ?? 0), 18)
                  //           .toString() +
                  //       " MATIC",
                  //   style: AppTheme.subtitle,
                  // ),
                ],
              ),
              title: Text(
                sent
                    ? "${data.transfers[data.transfers.length - 1].toAddress}"
                    : "${data.transfers[data.transfers.length - 1].fromAddress}",
                style: AppTheme.label_medium,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                DateFormat.yMMMEd()
                    .add_jm()
                    .format(DateTime.parse(data.blockSignedAt)),
                style: AppTheme.body_small,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Divider(
                color: AppTheme.warmgray_200,
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
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
              isThreeLine: false,
              title: sent ? Text("Sent") : Text("Recieved"),
              subtitle: sent
                  ? Text(
                      "To ${data.transfers[data.transfers.length - 1].toAddress}",
                      overflow: TextOverflow.clip,
                    )
                  : Text(
                      "From ${data.transfers[data.transfers.length - 1].fromAddress}",
                      overflow: TextOverflow.clip,
                    ),
              trailing: sent
                  ? Text(
                      "-${value}",
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    )
                  : Text(
                      "+${value}",
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
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

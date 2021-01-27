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
    var value =
        EthConversions.weiToEth(BigInt.parse(data.value)).toStringAsFixed(2);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              isThreeLine: true,
              leading: data.successful
                  ? Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                    )
                  : Icon(
                      Icons.close,
                      color: Colors.redAccent,
                    ),
              title: sent ? Text("Sent") : Text("Recieved"),
              subtitle: sent
                  ? Text(
                      "To ${data.transfers[data.transfers.length - 1].toAddress}")
                  : Text(
                      "From ${data.transfers[data.transfers.length - 1].fromAddress}"),
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
            Divider(color: AppTheme.darkText)
          ],
        ),
      ),
    );
  }
}

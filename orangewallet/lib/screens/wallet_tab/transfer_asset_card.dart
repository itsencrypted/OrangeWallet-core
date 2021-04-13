import 'package:flutter/material.dart';
import 'package:orangewallet/constants.dart';
import 'package:orangewallet/theme_data.dart';

class TransferAssetCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(AppTheme.cardRadius))),
        borderOnForeground: true,
        elevation: AppTheme.cardElevations,
        color: AppTheme.white,
        child: SizedBox(
          height: 91,
          child: Center(
            child: FlatButton(
              padding: EdgeInsets.all(0),
              onPressed: () {
                Navigator.pushNamed(context, bridgeActionRoute);
              },
              child: ListTile(
                leading: Image.asset("assets/icons/transfer_icon.png"),
                title: Text("Transfer Bridge", style: AppTheme.title),
                subtitle: Text(
                  "Transfer your assets from Ethereum to Matic.",
                  style: AppTheme.subtitle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

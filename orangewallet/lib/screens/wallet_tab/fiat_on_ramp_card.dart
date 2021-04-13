import 'package:flutter/material.dart';
import 'package:orangewallet/constants.dart';
import 'package:orangewallet/theme_data.dart';
import 'package:orangewallet/utils/misc/credential_manager.dart';
import 'package:orangewallet/utils/network/network_config.dart';
import 'package:orangewallet/utils/network/network_manager.dart';

class FiatOnRampCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(AppTheme.cardRadius))),
        borderOnForeground: true,
        elevation: AppTheme.cardElevations,
        child: Container(
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.all(Radius.circular(AppTheme.cardRadius)),
            gradient: LinearGradient(colors: [
              AppTheme.orangeGradientStart,
              AppTheme.orangeGradientEnd
            ], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: SizedBox(
            height: 91,
            child: Center(
              child: FlatButton(
                padding: EdgeInsets.all(0),
                onPressed: () async {
                  var address = await CredentialManager.getAddress();
                  NetworkConfigObject config =
                      await NetworkManager.getNetworkObject();
                  String url = config.transakLink + address;
                  Navigator.pushNamed(context, transakRoute, arguments: url);
                },
                child: ListTile(
                  leading: Image.asset(
                    transakIcon,
                  ),
                  title: Text("Buy Tokens with Bank Cards",
                      style: AppTheme.titleWhite),
                  subtitle: Text(
                    "Directly buy Crypto tokens with Credit/Debit Card",
                    style: AppTheme.body2White,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

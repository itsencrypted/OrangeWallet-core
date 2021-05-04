import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:orangewallet/constants.dart';
import 'package:orangewallet/theme_data.dart';
import 'package:orangewallet/utils/misc/credential_manager.dart';
import 'package:orangewallet/utils/network/network_config.dart';
import 'package:orangewallet/utils/network/network_manager.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

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
                  if (Platform.isIOS) {
                    try {
                      // If the system can show an authorization request dialog
                      if (await AppTrackingTransparency
                              .trackingAuthorizationStatus ==
                          TrackingStatus.notDetermined) {
                        // Show a custom explainer dialog before the system dialog
                        await AppTrackingTransparency
                            .requestTrackingAuthorization();
                        if (await AppTrackingTransparency
                                .trackingAuthorizationStatus ==
                            TrackingStatus.denied) {
                          return;
                        }
                      } else if (await AppTrackingTransparency
                              .trackingAuthorizationStatus ==
                          TrackingStatus.denied) {
                        Fluttertoast.showToast(
                            msg:
                                "You can not use tranak without allowing it to track you. Go to Settings > Orange Wallet > Allow Tracking  ",
                            toastLength: Toast.LENGTH_LONG);
                        return;
                      }
                    } on PlatformException {
                      Fluttertoast.showToast(msg: "Something went wrong");
                      return;
                      // Unexpected exception was thrown
                    }
                  }
                  var address = await CredentialManager.getAddress();
                  NetworkConfigObject config =
                      await NetworkManager.getNetworkObject();
                  String url = config.transakLink + address;
                  print(url);
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

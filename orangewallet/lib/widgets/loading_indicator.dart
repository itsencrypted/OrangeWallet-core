import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:orangewallet/theme_data.dart';

class Dialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  shape: AppTheme.cardShape,
                  backgroundColor: AppTheme.white,
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        SpinKitFadingFour(
                            size: 50, color: AppTheme.primaryColor),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Please Wait....",
                          style: AppTheme.subtitle,
                        )
                      ]),
                    )
                  ]));
        });
  }
}

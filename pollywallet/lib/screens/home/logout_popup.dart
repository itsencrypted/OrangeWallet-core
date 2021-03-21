import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/misc/box.dart';
import 'package:pollywallet/utils/misc/credential_manager.dart';

class PopUpDialogLogout {
  static showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context, false);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Continue"),
      onPressed: () async {
        var mnemonic = await CredentialManager.getMnemonic(context);
        if (mnemonic == null) {
          Navigator.pop(context, false);
          return;
        }
        Clipboard.setData(new ClipboardData(text: mnemonic));
        Fluttertoast.showToast(
            msg: "Your mnemonic is copied to clipboard",
            toastLength: Toast.LENGTH_LONG);
        await BoxUtils.clear();
        Navigator.of(context).pushNamedAndRemoveUntil(
            appLandingRoute, (Route<dynamic> route) => false);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: AppTheme.cardShape,
      title: Text("Alert"),
      content: Text(
        "You will not be able to get access this account without having the mnemonic, make sure to back it up.",
        style: TextStyle(color: Colors.red),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

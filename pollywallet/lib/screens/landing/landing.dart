import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/screens/home/home.dart';
import 'package:pollywallet/screens/login/login.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/misc/box.dart';
import 'package:pollywallet/utils/misc/encryptions.dart';
import 'package:pollywallet/utils/misc/hd_key.dart';
import 'package:pollywallet/widgets/loading_indicator.dart';

class ImportMnemonic extends StatefulWidget {
  ImportMnemonicState createState() => ImportMnemonicState();
}

class ImportMnemonicState extends State<ImportMnemonic> {
  TextEditingController seed = new TextEditingController();
  TextEditingController pin = new TextEditingController();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  BuildContext context;
  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                maxLines: null,
                controller: seed,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (val) =>
                    val.split(" ").length == 12 ? null : 'Invalid Mnemonic',
                decoration: InputDecoration(
                  labelText: "Mnemonic",
                  hintText: "Enter your Mnemonic",
                ),
              ),
              TextFormField(
                maxLines: null,
                maxLength: 4,
                controller: pin,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (val) =>
                    val.length == 4 ? null : 'PIN must be of 4 numbers',
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "PIN",
                  hintText: "Enter a PIN",
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      color: receiveButtonColor.withOpacity(0.6),
                      child: Text("New Mnemonic"),
                      onPressed: _newMnemonic),
                  RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      color: sendButtonColor.withOpacity(0.6),
                      child: Text("Continue"),
                      onPressed: _proceed),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _proceed() async {
    if (seed.text.split(" ").length != 12) {
      Fluttertoast.showToast(
          msg: "Invalid Mnemonic",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);

      return;
    }
    if (pin.text.length != 4) {
      Fluttertoast.showToast(
          msg: "Invalid PIN",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    Dialogs.showLoadingDialog(context, _keyLoader);
    await Future.delayed(Duration(seconds: 1)).then((val) async {
      var pkAddr = await HDKey.generateKey(seed.text);
      var encrypted = await Encryptions.encrypt(seed.text, pkAddr[0], pin.text);
      BoxUtils.setFirstAccount(
          encrypted[0], encrypted[1], pkAddr[1], encrypted[2]);
      BoxUtils.setNetworkConfig(0);
    });

    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    Navigator.pushNamedAndRemoveUntil(
        context, homeRoute, (Route<dynamic> route) => false);
  }

  _newMnemonic() async {
    seed.text = HDKey.generateMnemonic();
  }
}

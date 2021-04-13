import 'package:flutter/material.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:orangewallet/utils/misc/box.dart';
import 'package:orangewallet/utils/misc/disable_keyboard.dart';
import 'package:orangewallet/utils/misc/encryptions.dart';
import 'package:orangewallet/widgets/loading_indicator.dart';

import '../theme_data.dart';

class PinWidget extends StatefulWidget {
  @override
  PinWidgetState createState() => new PinWidgetState();
}

class PinWidgetState extends State<PinWidget> {
  String pin = "";
  bool failed = false;
  final TextEditingController _pinPutController = TextEditingController();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: failed ? Colors.red : AppTheme.primaryColor),
      borderRadius: BorderRadius.circular(15.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundWhite,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              alignment: AlignmentDirectional.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.lock,
                      color: Colors.grey,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Enter 4 digit PIN",
                      style: AppTheme.title,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 200,
                      child: PinPut(
                        focusNode: AlwaysDisabledFocusNode(),
                        obscureText: "*",
                        controller: _pinPutController,
                        fieldsCount: 4,
                        submittedFieldDecoration: _pinPutDecoration.copyWith(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        selectedFieldDecoration: _pinPutDecoration,
                        followingFieldDecoration: _pinPutDecoration.copyWith(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(
                            color: failed
                                ? Colors.red
                                : AppTheme.primaryColor.withOpacity(.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  failed
                      ? Text("Invalid Pin", style: TextStyle(color: Colors.red))
                      : Container()
                ],
              ),
            ),
          ),
          SizedBox(),
          SizedBox(),
          NumericKeyboard(
            onKeyboardTap: _onKeyboardTap,
            textColor: Colors.black,
            leftButtonFn: () {
              setState(() {
                if (pin.length == 0) return;
                pin = pin.substring(0, pin.length - 1);
                _pinPutController.text = pin;
              });
            },
            leftIcon: Icon(
              Icons.backspace,
              color: Colors.black87,
            ),
            rightButtonFn: () {
              _decrypt(args);
            },
            rightIcon: Icon(
              Icons.check,
              color: Colors.black87,
            ),
          ),
          SizedBox()
        ],
      ),
    );
  }

  _onKeyboardTap(String value) {
    if (pin.length >= 4) {
      return;
    }
    setState(() {
      pin = pin + value;
      _pinPutController.text = pin;
    });
  }

  _decrypt(args) async {
    if (pin.length != 4) {
      setState(() {
        failed = true;
      });
      return;
    }
    Dialogs.showLoadingDialog(context, _keyLoader);
    String salt = await BoxUtils.getSalt();
    String key = args;
    String decrypted = await Encryptions.decrypt(key, salt, pin);
    if (decrypted == Encryptions.failed) {
      setState(() {
        failed = true;
        pin = "";
        _pinPutController.text = "";
      });
      if (_keyLoader.currentContext == null) {
      } else {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      }
    } else {
      if (_keyLoader.currentContext == null) {
        Navigator.pop(context, decrypted);
      } else {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      }
      Navigator.pop(context, decrypted);
    }
    return;
  }
}

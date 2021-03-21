import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/misc/box.dart';
import 'package:pollywallet/utils/misc/disable_keyboard.dart';
import 'package:pollywallet/utils/misc/encryptions.dart';
import 'package:pollywallet/utils/misc/hd_key.dart';
import 'package:pollywallet/widgets/loading_indicator.dart';

class LandingSetPinScreen extends StatefulWidget {
  @override
  LandingSetPinScreenState createState() => LandingSetPinScreenState();
}

class LandingSetPinScreenState extends State<LandingSetPinScreen> {
  TextEditingController pin = new TextEditingController();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  String seed;
  bool failed = false;
  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      color: AppTheme.warmgray_100,
      border: Border.all(color: failed ? Colors.red : AppTheme.primaryColor),
      borderRadius: BorderRadius.circular(15.0),
    );
  }

  final FocusNode _pinPutFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    seed = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Set up a PIN",
          style: AppTheme.header_H5.copyWith(color: AppTheme.black),
        ),
      ),
      backgroundColor: AppTheme.backgroundWhite,
      body: Container(
        padding: EdgeInsets.all(AppTheme.paddingHeight12),
        child: Center(
          child: Card(
            shape: AppTheme.cardShape,
            child: Padding(
              padding: EdgeInsets.all(AppTheme.paddingHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'PIN',
                        style: AppTheme.label_medium,
                      ),
                      SizedBox(
                        width: AppTheme.paddingHeight12 / 2,
                      ),
                      Text(
                        '*Must be atleast 4 numbers',
                        style: AppTheme.body_medium,
                      )
                    ],
                  ),
                  SizedBox(
                    height: AppTheme.paddingHeight12 / 3,
                  ),
                  Text(
                    "Set up a PIN to secure your wallet",
                    style: AppTheme.body_small,
                  ),
                  SizedBox(
                    height: AppTheme.paddingHeight12,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 200,
                          child: PinPut(
                            focusNode: _pinPutFocusNode,
                            obscureText: "*",
                            controller: pin,
                            fieldsCount: 4,
                            submittedFieldDecoration:
                                _pinPutDecoration.copyWith(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            selectedFieldDecoration: _pinPutDecoration,
                            followingFieldDecoration:
                                _pinPutDecoration.copyWith(
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
                    ],
                  ),
                  failed
                      ? Text("Invalid Pin", style: TextStyle(color: Colors.red))
                      : Container()
                  // Container(
                  //   decoration: BoxDecoration(
                  //       borderRadius:
                  //           BorderRadius.circular(AppTheme.cardRadius),
                  //       color: AppTheme.warmgray_100,
                  //       shape: BoxShape.rectangle,
                  //       border:
                  //           Border.all(width: 1, color: AppTheme.purple_600)),
                  //   padding: EdgeInsets.symmetric(horizontal: 8),
                  //   child: TextFormField(
                  //     obscureText: true,
                  //     obscuringCharacter: "*",
                  //     maxLines: 1,
                  //     maxLength: 4,
                  //     controller: pin,
                  //     autovalidateMode: AutovalidateMode.onUserInteraction,
                  //     validator: (val) =>
                  //         val.length == 4 ? null : 'PIN must be of 4 numbers',
                  //     keyboardType: TextInputType.number,
                  //     decoration: InputDecoration(
                  //       fillColor: AppTheme.warmgray_100,
                  //       border: InputBorder.none,
                  //       focusedBorder: InputBorder.none,
                  //       labelStyle: AppTheme.label_medium
                  //           .copyWith(color: AppTheme.warmgray_600),
                  //       labelText: "PIN",
                  //       hintText: "Enter a PIN",
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width,
        height: AppTheme.buttonHeight_44,
        margin: EdgeInsets.symmetric(horizontal: AppTheme.paddingHeight12),
        child: TextButton(
          style: TextButton.styleFrom(
              backgroundColor: AppTheme.purple_600,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.buttonRadius))),
          onPressed: _proceed,
          child: Text(
            'Continue',
            style:
                AppTheme.label_medium.copyWith(color: AppTheme.lightgray_700),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  _proceed() async {
    if (pin.text.length != 4) {
      setState(() {
        failed = true;
      });
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
      var pkAddr = await HDKey.generateKey(seed.trim());
      var encrypted =
          await Encryptions.encrypt(seed.trim(), pkAddr[0], pin.text);
      BoxUtils.setFirstAccount(
          encrypted[0], encrypted[1], pkAddr[1], encrypted[2]);
      BoxUtils.setNetworkConfig(0);
    });

    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    Navigator.pushNamedAndRemoveUntil(
        context, homeRoute, (Route<dynamic> route) => false);
  }
}

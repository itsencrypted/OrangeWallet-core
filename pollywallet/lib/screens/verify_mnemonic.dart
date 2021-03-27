import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/misc/box.dart';
import 'package:pollywallet/utils/misc/credential_manager.dart';

class VerifyMnemonic extends StatefulWidget {
  @override
  _VerifyMnemonicState createState() => _VerifyMnemonicState();
}

class _VerifyMnemonicState extends State<VerifyMnemonic> {
  bool showWraning = true;
  bool failed = false;
  TextEditingController seed = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Fluttertoast.showToast(
          msg: "Please verify your mnemonic",
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Verify your Mnemonic"),
        ),
        body: SafeArea(
          child: Column(
            children: [
              showWraning
                  ? Card(
                      color: AppTheme.warningCardColor,
                      shape: AppTheme.cardShape,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: AppTheme.paddingHeight,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Warning',
                                  style: AppTheme.titleWhite,
                                ),
                                IconButton(
                                    icon: Icon(Icons.close),
                                    color: Colors.white,
                                    onPressed: () {
                                      setState(() {
                                        showWraning = false;
                                      });
                                    })
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: AppTheme.paddingHeight,
                                bottom: AppTheme.paddingHeight,
                                right: 10),
                            child: Text(
                              "Do not share your mnemonic with anybody,Store it securely",
                              style: AppTheme.body2White,
                              maxLines: 100,
                            ),
                          )
                        ],
                      ),
                    )
                  : Container(),
              Card(
                shape: AppTheme.cardShape,
                child: Padding(
                  padding: EdgeInsets.all(AppTheme.paddingHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Verify your Mnemonic',
                        style: AppTheme.label_medium,
                      ),
                      SizedBox(
                        height: AppTheme.paddingHeight12 / 3,
                      ),
                      Text(
                        "You just recieved some tokens, Confirm and backup your Mnemonic now.",
                        style: AppTheme.body_small,
                      ),
                      SizedBox(
                        height: AppTheme.paddingHeight12,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppTheme.cardRadius),
                            color: AppTheme.warmgray_100,
                            shape: BoxShape.rectangle,
                            border: Border.all(
                                width: 1, color: AppTheme.purple_600)),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: TextFormField(
                          maxLines: null,
                          controller: seed,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (val) => val.trim().split(" ").length == 12
                              ? null
                              : 'Invalid Mnemonic',
                          decoration: InputDecoration(
                            fillColor: AppTheme.warmgray_100,
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            labelStyle: AppTheme.label_medium
                                .copyWith(color: AppTheme.warmgray_600),
                            labelText: "Mnemonic",
                            hintText: "Enter your Mnemonic",
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: AppTheme.buttonHeight_44,
                          // margin: EdgeInsets.symmetric(
                          //     horizontal: AppTheme.paddingHeight12),
                          child: TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor: AppTheme.purple_600,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.buttonRadius))),
                            onPressed: _proceed,
                            child: Text(
                              'Continue',
                              style: AppTheme.label_medium
                                  .copyWith(color: AppTheme.lightgray_700),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7.0),
                          child: failed
                              ? FlatButton(
                                  onPressed: () async {
                                    final String mnemonic =
                                        await CredentialManager.getMnemonic(
                                            context);
                                    Navigator.of(context).pushNamed(
                                        exportMnemonic,
                                        arguments: mnemonic);
                                  },
                                  child: Text("I lost my Mnemonic"))
                              : Container(),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _proceed() async {
    final String mnemonic = await CredentialManager.getMnemonic(context);
    if (seed.text.trim() == mnemonic) {
      BoxUtils.setNewMnemonicBox(true);
      Navigator.pop(context);
    } else {
      setState(() {
        failed = true;
      });
      Fluttertoast.showToast(msg: "Invalid Mnemonic");
    }
  }
}

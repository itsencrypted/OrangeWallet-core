import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/theme_data.dart';

class ImportWalletScreen extends StatefulWidget {
  @override
  _ImportWalletScreenState createState() => _ImportWalletScreenState();
}

class _ImportWalletScreenState extends State<ImportWalletScreen> {
  TextEditingController seed = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Import Wallet",
          style: AppTheme.header_H5.copyWith(color: AppTheme.black),
        ),
      ),
      backgroundColor: AppTheme.backgroundWhite,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(),
          Card(
            shape: AppTheme.cardShape,
            child: Padding(
              padding: EdgeInsets.all(AppTheme.paddingHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Mnemonic',
                    style: AppTheme.label_medium,
                  ),
                  SizedBox(
                    height: AppTheme.paddingHeight12 / 3,
                  ),
                  Text(
                    "Enter your 12 (or 24) Word recovery phrase to import your existing wallet",
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
                        border:
                            Border.all(width: 1, color: AppTheme.purple_600)),
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
                ],
              ),
            ),
          ),
          SafeArea(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: AppTheme.buttonHeight_44,
              margin:
                  EdgeInsets.symmetric(horizontal: AppTheme.paddingHeight12),
              child: TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: AppTheme.purple_600,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.buttonRadius))),
                onPressed: _proceed,
                child: Text(
                  'Continue',
                  style: AppTheme.label_medium
                      .copyWith(color: AppTheme.lightgray_700),
                ),
              ),
            ),
          )
        ],
      ),
      //floatingActionButton: ,
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  _proceed() async {
    if (seed.text.trim().split(" ").length != 12) {
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

    Navigator.pushNamed(context, landingSetPinRoute, arguments: seed.text);
  }
}

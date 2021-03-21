import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/screens/staking/ui_elements/warning_card.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/misc/hd_key.dart';

class CreateWalletScreen extends StatefulWidget {
  @override
  _CreateWalletScreenState createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  String seed;
  List<String> chipsText = [];
  bool showWarning;
  @override
  void initState() {
    _newMnemonic();
    showWarning = true;
    super.initState();
  }

  _newMnemonic() async {
    seed = HDKey.generateMnemonic();
    chipsText = seed.split(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create Wallet",
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
                  Text(
                    'Mnemonic',
                    style: AppTheme.label_medium,
                  ),
                  SizedBox(
                    height: AppTheme.paddingHeight12 / 3,
                  ),
                  Text(
                    "Write down the exact sequence of these words and store them somewhere safe",
                    style: AppTheme.body_small,
                  ),
                  SizedBox(
                    height: AppTheme.paddingHeight12 / 2,
                  ),
                  Divider(),
                  SizedBox(
                    height: AppTheme.paddingHeight12 / 2,
                  ),
                  Wrap(
                    spacing: AppTheme.paddingHeight / 4,
                    children: _chips(),
                    runSpacing: AppTheme.paddingHeight / 4,
                  ),
                  SizedBox(
                    height: AppTheme.paddingHeight12,
                  ),
                  Container(
                    width: 86,
                    height: AppTheme.buttonHeight_44,
                    child: TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: AppTheme.warmgray_900,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppTheme.buttonRadius))),
                      onPressed: () {
                        Clipboard.setData(new ClipboardData(text: seed));
                        Fluttertoast.showToast(
                          msg: "Mnemonic copied",
                        );
                      },
                      child: Text(
                        'Copy',
                        style: AppTheme.label_medium
                            .copyWith(color: AppTheme.lightgray_700),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (showWarning)
            Container(
              margin: EdgeInsets.all(AppTheme.paddingHeight12 - 2),
              child: WarningCard(
                warningText:
                    "Do not share your mnemonic with anybody, Store it securely",
                onClose: () {
                  setState(() {
                    showWarning = false;
                  });
                },
              ),
            ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: AppTheme.buttonHeight_44,
            margin: EdgeInsets.symmetric(horizontal: AppTheme.paddingHeight12),
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
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  List<Widget> _chips() {
    List<Widget> chips = [];
    chipsText.forEach((element) {
      chips.add(Container(
        child: Text(
          element,
          style: AppTheme.body_small,
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: AppTheme.warmgray_100),
        padding: EdgeInsets.symmetric(
            horizontal: AppTheme.paddingHeight12,
            vertical: AppTheme.paddingHeight12 / 2),
      ));
    });
    return chips;
  }

  _proceed() async {
    if (seed.trim().split(" ").length != 12) {
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

    Navigator.pushNamed(context, landingSetPinRoute, arguments: seed);
  }
}

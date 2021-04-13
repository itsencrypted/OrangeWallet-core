import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:orangewallet/screens/staking/ui_elements/warning_card.dart';
import 'package:orangewallet/theme_data.dart';
import 'package:share/share.dart';

class ExportMnemonic extends StatefulWidget {
  @override
  _ExportMnemonicState createState() => _ExportMnemonicState();
}

class _ExportMnemonicState extends State<ExportMnemonic> {
  String mnemonic;
  List<String> chipsText = [];
  bool showWarning;
  @override
  void initState() {
    showWarning = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    mnemonic = ModalRoute.of(context).settings.arguments as String;
    chipsText = mnemonic.split(' ');
    return Scaffold(
        backgroundColor: AppTheme.backgroundWhite,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundWhite,
          elevation: 0,
          brightness: Brightness.light,
          title: Text("Export Mnemonic"),
        ),
        body: mnemonic == null
            ? Center(
                child: SpinKitFadingFour(
                  size: 40,
                  color: AppTheme.primaryColor,
                ),
              )
            : SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(),
                    Container(
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
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Container(
                                    width: 86,
                                    height: AppTheme.buttonHeight_44,
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                          backgroundColor:
                                              AppTheme.warmgray_900,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppTheme.buttonRadius))),
                                      onPressed: () {
                                        Clipboard.setData(
                                            new ClipboardData(text: mnemonic));
                                        Fluttertoast.showToast(
                                          msg: "Mnemonic copied",
                                        );
                                      },
                                      child: Text(
                                        'Copy',
                                        style: AppTheme.label_medium.copyWith(
                                            color: AppTheme.lightgray_700),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: 97,
                                    height: AppTheme.buttonHeight_44,
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                          backgroundColor:
                                              AppTheme.warmgray_900,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppTheme.buttonRadius))),
                                      onPressed: () {
                                        Share.share(
                                          mnemonic,
                                        );
                                      },
                                      child: Text(
                                        'Export',
                                        style: AppTheme.label_medium.copyWith(
                                            color: AppTheme.lightgray_700),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
                    showWarning
                        ? Container(
                            margin:
                                EdgeInsets.all(AppTheme.paddingHeight12 - 2),
                            child: WarningCard(
                              warningText:
                                  "Do not share your mnemonic with anybody, Store it securely",
                              onClose: () {
                                setState(() {
                                  showWarning = false;
                                });
                              },
                            ),
                          )
                        : Container(),
                  ],
                ),
              ));
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
}

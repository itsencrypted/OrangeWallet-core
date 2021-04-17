import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:orangewallet/theme_data.dart';
import 'package:orangewallet/utils/misc/box.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';

class Receive extends StatefulWidget {
  @override
  _ReceiveState createState() => _ReceiveState();
}

class _ReceiveState extends State<Receive> {
  String address;
  @override
  initState() {
    BoxUtils.getAddress().then((str) {
      setState(() {
        address = str;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundWhite,
        elevation: 0,
        brightness: Brightness.light,
        title: Text("Receive Payment"),
      ),
      body: address == null
          ? Center(
              child: SpinKitFadingFour(
                size: 40,
                color: AppTheme.primaryColor,
              ),
            )
          : SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Card(
                      shape: AppTheme.cardShape,
                      elevation: AppTheme.cardElevations + 1,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Scan QR to send ETH, ERC-20, ERC-721",
                                style: AppTheme.title,
                              ),
                            ),
                            Divider(
                              color: AppTheme.warmgray_200,
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.all(AppTheme.paddingHeight / 2),
                              child: QrImage(
                                data: address,
                                version: QrVersions.auto,
                                size: 200.0,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(AppTheme.paddingHeight20),
                              child: Text(
                                address,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: AppTheme.grey_title,
                              ),
                            ),
                            Divider(
                              color: AppTheme.warmgray_200,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 44,
                                    width: 101,
                                    child: RawMaterialButton(
                                      fillColor: AppTheme.warmGrey_900,
                                      elevation: 1,
                                      child: Text("Copy",
                                          style: AppTheme.body2White),
                                      onPressed: () {
                                        Clipboard.setData(
                                            new ClipboardData(text: address));
                                        Fluttertoast.showToast(
                                          msg: "Address copied",
                                        );
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(100)),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40,
                                  ),
                                  SizedBox(
                                    height: 44,
                                    width: 101,
                                    child: RawMaterialButton(
                                      fillColor: AppTheme.warmGrey_900,
                                      elevation: 1,
                                      child: Text("Share",
                                          style: AppTheme.body2White),
                                      onPressed: () async {
                                        Share.share(
                                            'Hey my wallet address is : $address',
                                            subject:
                                                'This is my wallet address');
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(100)),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

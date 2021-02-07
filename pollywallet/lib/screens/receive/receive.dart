import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/misc/box.dart';
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
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Scan QR to send ETH, ERC-20 pr ERC-721",
                    style: AppTheme.title,
                  ),
                  Padding(
                    padding: EdgeInsets.all(AppTheme.paddingHeight / 2),
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
                      style: AppTheme.title,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(AppTheme.paddingHeight / 2),
                            child: RawMaterialButton(
                              fillColor: AppTheme.primaryColor,
                              elevation: 1,
                              child: Padding(
                                padding:
                                    EdgeInsets.all(AppTheme.paddingHeight20),
                                child: Icon(Icons.file_copy_outlined),
                              ),
                              onPressed: () {
                                Clipboard.setData(
                                    new ClipboardData(text: "your text"));
                                Fluttertoast.showToast(
                                  msg: "Address copied",
                                );
                              },
                              shape: CircleBorder(),
                            ),
                          ),
                          Text(
                            "Copy",
                            style: AppTheme.body1,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(AppTheme.paddingHeight),
                            child: RawMaterialButton(
                              fillColor: AppTheme.primaryColor,
                              elevation: 1,
                              child: Padding(
                                padding:
                                    EdgeInsets.all(AppTheme.paddingHeight20),
                                child: Icon(Icons.share),
                              ),
                              onPressed: () async {
                                //TODO change the sharing data here

                                Share.share(
                                    'Hey my wallet address is : $address',
                                    subject: 'THis is my wallet address');
                              },
                              shape: CircleBorder(),
                            ),
                          ),
                          Text(
                            "Share",
                            style: AppTheme.body1,
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
    );
  }
}

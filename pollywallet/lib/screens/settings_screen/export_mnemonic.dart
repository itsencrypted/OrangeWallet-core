import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/io_client.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:share/share.dart';
import 'package:http/http.dart' as http;

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ExportMnemonic extends StatefulWidget {
  @override
  _ExportMnemonicState createState() => _ExportMnemonicState();
}

class _ExportMnemonicState extends State<ExportMnemonic> {
  String mnemonic;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    mnemonic = ModalRoute.of(context).settings.arguments as String;

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundWhite,
        elevation: 0,
        brightness: Brightness.light,
        title: Text("Receive Payment"),
      ),
      body: mnemonic == null
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
                  Padding(
                    padding: EdgeInsets.all(AppTheme.paddingHeight20),
                    child: Text(
                      mnemonic,
                      maxLines: 5,
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
                                    new ClipboardData(text: mnemonic));
                                Fluttertoast.showToast(
                                  msg: "Mnemonic copied",
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
                                child: Icon(Icons.cloud_upload),
                              ),
                              onPressed: () async {
                                Share.share(
                                  mnemonic,
                                );
                              },
                              shape: CircleBorder(),
                            ),
                          ),
                          Text(
                            "Export",
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

class GoogleHttpClient extends IOClient {
  Map<String, String> _headers;
  GoogleHttpClient(this._headers) : super();

  @override
  Future<IOStreamedResponse> send(http.BaseRequest request) =>
      super.send(request..headers.addAll(_headers));
  @override
  Future<http.Response> head(Object url, {Map<String, String> headers}) =>
      super.head(url, headers: headers..addAll(_headers));
}

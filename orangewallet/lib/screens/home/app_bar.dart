import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:orangewallet/constants.dart';
import 'package:orangewallet/models/send_token_model/send_token_data.dart';
import 'package:orangewallet/screens/home/logout_popup.dart';
import 'package:orangewallet/state_manager/send_token_state/send_token_cubit.dart';
import 'package:orangewallet/theme_data.dart';
import 'package:orangewallet/utils/misc/box.dart';
import 'package:orangewallet/utils/misc/credential_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  _HomeAppBar createState() => _HomeAppBar();
  @override
  final Size preferredSize = Size.fromHeight(70);
}

class _HomeAppBar extends State<HomeAppBar> {
  String address = "";
  int id = 1;
  String fullAddress = "";
  SendTransactionCubit cubit;
  @override
  void initState() {
    CredentialManager.getAddress().then((value) {
      var start = value.substring(0, 4);
      var end = value.substring(value.length - 2);
      setState(() {
        address = start + ".." + end;
        fullAddress = value;
        print(fullAddress);
      });
    });
    BoxUtils.getNetworkConfig().then((value) {
      setState(() {
        id = value;
      });
    });
    _refresh();
    _refreshNetwork();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: false,
      backgroundColor: AppTheme.backgroundWhite,
      leadingWidth: 0,
      title: Padding(
        padding: const EdgeInsets.only(
          left: 2,
        ),
        child: SizedBox(
          width: id == 0 ? 170 : 130,
          child: FlatButton(
            onPressed: () {
              Clipboard.setData(new ClipboardData(text: fullAddress));
              Fluttertoast.showToast(msg: "Address Copied");
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.all(0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              elevation: 0,
              color: AppTheme.somewhatYellow,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: Icon(
                      Icons.account_circle_sharp,
                      color: AppTheme.darkText,
                      size: 35,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.0),
                    child: Text(address, style: AppTheme.body2),
                  ),
                  id == 0
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Container(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 2),
                              child: Text(
                                "TEST",
                                style: AppTheme.body2White,
                              ),
                            ),
                            decoration: BoxDecoration(
                                color: AppTheme.secondaryColor,
                                borderRadius: BorderRadius.circular(6)),
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              child: Image.asset("assets/icons/qr_icon.png",
                  color: AppTheme.darkerText),
              onPressed: () async {
                var qrResult = await BarcodeScanner.scan();
                if (qrResult.rawContent == null || qrResult.rawContent == "") {
                  return;
                }
                RegExp reg = RegExp(r'^0x[0-9a-fA-F]{40}$');
                if (reg.hasMatch(qrResult.rawContent)) {
                  if (qrResult.rawContent.length == 42) {
                    cubit = context.read<SendTransactionCubit>();
                    cubit.setData(SendTokenData(receiver: qrResult.rawContent));
                    Navigator.pushNamed(context, pickTokenRoute);
                  } else {
                    Fluttertoast.showToast(
                      msg: "Invalid QR",
                    );
                  }
                } else {
                  String privateKey =
                      await CredentialManager.getPrivateKey(context);
                  if (privateKey == null) {
                    return;
                  }
                  if (Platform.isAndroid) {
                    Navigator.pushNamed(context, walletConnectAndroidRoute,
                        arguments: [privateKey, qrResult.rawContent]);
                  } else if (Platform.isIOS) {
                    Navigator.pushNamed(context, walletConnectIosRoute,
                        arguments: [privateKey, qrResult.rawContent]);
                  } else {
                    Fluttertoast.showToast(msg: "Unsupported Platform");
                  }
                }
              },
            ),
            TextButton(
              child: Icon(
                Icons.power_settings_new_outlined,
                color: AppTheme.darkerText,
              ),
              onPressed: _logout,
            )
          ],
        )
      ],
    );
  }

  _refresh() async {
    var box = await BoxUtils.getCredentialsListBox();
    var stream = box.watch();
    var bcast = stream.asBroadcastStream();
    bcast.listen((event) {
      CredentialManager.getAddress().then((value) {
        var start = value.substring(0, 4);
        var end = value.substring(value.length - 3);
        setState(() {
          address = start + ".." + end;
        });
      });
    });
  }

  _refreshNetwork() async {
    var configBox = await BoxUtils.getNetworkIdBox();
    var networkBCast = configBox.watch().asBroadcastStream();
    networkBCast.listen((event) async {
      var id = await BoxUtils.getNetworkConfig();
      setState(() {
        this.id = id;
      });
    });
  }

  _logout() {
    PopUpDialogLogout.showAlertDialog(context);
  }
}

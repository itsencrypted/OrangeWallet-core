import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/screens/home/logout_popup.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/misc/box.dart';
import 'package:pollywallet/utils/misc/credential_manager.dart';

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
  @override
  void initState() {
    CredentialManager.getAddress().then((value) {
      var start = value.substring(0, 4);
      var end = value.substring(value.length - 3);
      setState(() {
        address = start + ".." + end;
        fullAddress = value;
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
          left: 4,
        ),
        child: SizedBox(
          width: id == 0 ? 180 : 130,
          child: FlatButton(
            onPressed: () {
              Clipboard.setData(new ClipboardData(text: fullAddress));
              print(fullAddress);
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
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Text(address, style: AppTheme.body2),
                  ),
                  id == 0
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          child: Container(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 2),
                              child: Text("TEST"),
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
        TextButton(
          // child: Image.asset("assets/icons/qr_icon.png",
          //     color: AppTheme.darkerText),
          child: Icon(
            Icons.power_settings_new_outlined,
            color: AppTheme.darkerText,
          ),
          onPressed: _logout,
        )
      ],
    );
  }

  _refresh() async {
    var box = await BoxUtils.getCredentialsListBox();
    var stream = box.watch();
    var bcast = stream.asBroadcastStream();
    bcast.listen((event) {
      print("event");
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
      print("changed network");
      setState(() {
        this.id = id;
      });
    });
  }

  _logout() {
    PopUpDialogLogout.showAlertDialog(context);
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/misc/credential_manager.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  _HomeAppBar createState() => _HomeAppBar();
  @override
  final Size preferredSize = Size.fromHeight(70);
}

class _HomeAppBar extends State<HomeAppBar> {
  String address = "";
  @override
  void initState() {
    CredentialManager.getAddress().then((value) {
      var start = value.substring(0, 4);
      var end = value.substring(value.length - 3);
      setState(() {
        address = start + ".." + end;
      });
    });
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
          width: 130,
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
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
                Text(address, style: AppTheme.subtitle)
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Image.asset("assets/icons/qr_icon.png",
              color: AppTheme.darkerText),
          onPressed: () {},
        )
      ],
    );
  }
}

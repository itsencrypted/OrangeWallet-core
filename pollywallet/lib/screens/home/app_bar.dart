import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pollywallet/theme_data.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  _HomeAppBar createState() => _HomeAppBar();
  @override
  final Size preferredSize = Size.fromHeight(150);
}

class _HomeAppBar extends State<HomeAppBar> {
  @override
  Widget build(BuildContext context) {
    double leadingWidth = double.infinity;
    return AppBar(
      elevation: 0,
      backgroundColor: AppTheme.backgroundWhite,
      leadingWidth: leadingWidth,
      leading: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
        ),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          elevation: 0,
          color: AppTheme.primaryColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Icon(
                  Icons.account_circle_sharp,
                  color: AppTheme.darkText,
                  size: 35,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text("0x23..4gH1",
                    style:
                        TextStyle(color: Theme.of(context).primaryColorDark)),
              )
            ],
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

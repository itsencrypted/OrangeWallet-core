import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pollywallet/theme_data.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget{
  @override
  _HomeAppBar createState() => _HomeAppBar();
  @override
  final Size preferredSize = Size.fromHeight(100);
}
class _HomeAppBar extends State<HomeAppBar>{
  @override
  Widget build(BuildContext context) {
    double leadingWidth = MediaQuery.of(context).size.width *0.6;
    return AppBar(
      elevation: 0,
      backgroundColor: AppTheme.backgroundWhite,
      leadingWidth: leadingWidth,
      leading: Padding(
        padding: const EdgeInsets.all(9),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
             borderRadius: BorderRadius.circular(100),
          ),
          child:  Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_circle_sharp,
                color: AppTheme.dark_grey,
                size: leadingWidth * 0.15,
              ),
              Text("0x23..4gH1", style:TextStyle(color: Theme.of(context).primaryColorDark))
            ],
          ),
        ),
      ),
      actions: [
        FlatButton(
          child: Image.asset("assets/icons/qr_icon.png", color: AppTheme.darkerText),
          onPressed: (){},
        )
      ],
    );

  }

}
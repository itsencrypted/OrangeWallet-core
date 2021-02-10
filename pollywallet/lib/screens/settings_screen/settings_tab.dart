import 'package:flutter/material.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/theme_data.dart';

class SettingsTab extends StatefulWidget {
  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab>
    with AutomaticKeepAliveClientMixin<SettingsTab> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView(children: [
        listTile(
            title: 'Account',
            showTrailingIcon: false,
            onTap: () {
              Navigator.of(context).pushNamed(accountRoute);
            }),
        listTile(
            title: 'Network',
            showTrailingIcon: false,
            onTap: () {
              Navigator.of(context).pushNamed(networkSettingRoute);
            }),
        listTile(
            title: 'Privacy',
            showTrailingIcon: false,
            onTap: () {
              print('Privacy');
            }),
        listTile(
            title: 'Terms of Service',
            showTrailingIcon: false,
            onTap: () {
              print('tos');
            }),
        listTile(
            title: 'Report a bug',
            showTrailingIcon: false,
            onTap: () {
              print('tos');
            }),
      ]),
    );
  }

  Widget listTile(
      {String title,
      String trailingText,
      @required Function onTap,
      bool showTrailingIcon = true}) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppTheme.cardRadius))),
      color: AppTheme.white,
      elevation: AppTheme.cardElevations,
      child: ListTile(
        tileColor: AppTheme.white,
        onTap: onTap,
        leading: Icon(Icons.settings),
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null) Text(trailingText),
            if (showTrailingIcon) Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

import 'package:flutter/material.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/misc/credential_manager.dart';

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
            title: 'Profile',
            trailingText: 'ass...afs',
            onTap: () {
              print('profile');
            }),
        listTile(
            title: 'Contacts',
            trailingText: '23',
            onTap: () {
              print('Contacts');
            }),
        listTile(
            title: 'Currency',
            trailingText: 'USD',
            onTap: () {
              print('currency');
            }),
        listTile(
            title: 'Notification',
            onTap: () {
              print('Notification');
            }),
        listTile(
            title: 'Network',
            showTrailingIcon: false,
            onTap: () {
              Navigator.of(context).pushNamed(networkSettingRoute);
            }),
        listTile(
            title: 'Export Mnenomic',
            showTrailingIcon: false,
            onTap: () async {
              final String mnemonic =
                  await CredentialManager.getMnemonic(context);
              Navigator.of(context)
                  .pushNamed(exportMnemonic, arguments: mnemonic);
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

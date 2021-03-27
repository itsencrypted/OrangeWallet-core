import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Card(
            margin: EdgeInsets.all(AppTheme.paddingHeight12),
            shape: AppTheme.cardShape,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Column(children: [
              listTile(
                  title: 'Account',
                  leading: SvgPicture.asset(accountIconsvg),
                  onTap: () {
                    Navigator.of(context).pushNamed(accountRoute);
                  }),
              Divider(
                thickness: 1,
                height: 1,
              ),
              listTile(
                  title: 'Network',
                  leading: SvgPicture.asset(networkIconsvg),
                  onTap: () {
                    Navigator.of(context).pushNamed(networkSettingRoute);
                  }),
              Divider(
                thickness: 1,
                height: 1,
              ),
              listTile(
                  title: 'Export Mnenomic',
                  leading: SvgPicture.asset(exportIconsvg),
                  onTap: () async {
                    final String mnemonic =
                        await CredentialManager.getMnemonic(context);
                    Navigator.of(context)
                        .pushNamed(exportMnemonic, arguments: mnemonic);
                  }),
              Divider(
                thickness: 1,
                height: 1,
              ),
              listTile(
                  title: 'Privacy',
                  leading: SvgPicture.asset(privacyIconsvg),
                  onTap: () {
                    print('Privacy');
                  }),
              Divider(
                thickness: 1,
                height: 1,
              ),
              listTile(
                  title: 'Terms of Service',
                  leading: SvgPicture.asset(termOfServiceIconsvg),
                  onTap: () {}),
              Divider(
                thickness: 1,
                height: 1,
              ),
              listTile(
                  title: 'Report a bug',
                  leading: SvgPicture.asset(bugsIconsvg),
                  onTap: () {}),
            ]),
          ),
        ],
      ),
    );
  }

  Widget listTile(
      {String title,
      String trailingText,
      @required Function onTap,
      bool showTrailingIcon = true,
      Widget leading}) {
    return ListTile(
      tileColor: AppTheme.white,
      onTap: onTap,
      leading: leading != null ? leading : Icon(Icons.settings),
      title: Text(
        title,
        style: AppTheme.label_medium,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) Text(trailingText),
          if (showTrailingIcon)
            Icon(
              Icons.keyboard_arrow_right,
              color: Colors.black,
            ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

import 'package:flutter/material.dart';
import 'package:orangewallet/constants.dart';
import 'package:orangewallet/models/credential_models/credentials_model.dart';
import 'package:orangewallet/utils/misc/box.dart';

class CredentialManager {
  static Future<String> getPrivateKey(BuildContext context) async {
    CredentialsObject creds = await BoxUtils.getCredentialBox();
    var privateKey = await Navigator.pushNamed(context, pinWidgetRoute,
        arguments: creds.privateKey);
    return privateKey;
  }

  static Future<String> getMnemonic(BuildContext context) async {
    CredentialsObject creds = await BoxUtils.getCredentialBox();

    var mnemonic = await Navigator.pushNamed(context, pinWidgetRoute,
        arguments: creds.mnemonic);

    return mnemonic;
  }

  static Future<String> getAddress() async {
    CredentialsObject creds = await BoxUtils.getCredentialBox();
    var address = creds.address;
    return address;
  }
}

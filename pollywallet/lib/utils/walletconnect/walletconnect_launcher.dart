import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pollywallet/utils/misc/credential_manager.dart';

import '../../constants.dart';

class WalletConnectLauncher {
  static const platform = const MethodChannel(walletconnectChannel);
  static Future<String> launchWalletConnect(BuildContext context) async {
    String address = await CredentialManager.getAddress();
    //String privateKey = await CredentialManager.getPrivateKey(context);
    String uri = "";
    try {
      final String txHash =
          await platform.invokeMethod('launch', [address, "privateKey", uri]);
      return txHash;
    } on PlatformException catch (e) {
      print("Failed to execute: '${e.message}'.");
      return e.message;
    }
  }
}

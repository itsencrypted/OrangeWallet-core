import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/misc/box.dart';
import 'package:pollywallet/utils/misc/credential_manager.dart';
import 'package:pollywallet/utils/network/network_manager.dart';

class WalletConnectIos extends StatefulWidget {
  @override
  _WalletConnectIosState createState() => _WalletConnectIosState();
}

class _WalletConnectIosState extends State<WalletConnectIos> {
  String address;
  String chainId;
  String uri = "Asda";
  String privateKey = "asda";
  bool _loading = true;
  @override
  initState() {
    CredentialManager.getAddress().then((address) =>
        {NetworkManager.getNetworkObject().then((networkObject) => {})});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final String viewType = 'WalletConnectView';
    final List<String> creationParams = [address, privateKey, uri, chainId];

    return Scaffold(
        backgroundColor: AppTheme.backgroundWhite,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundWhite,
          elevation: 0,
          brightness: Brightness.light,
          title: Text("Wallet Connect"),
        ),
        body: _loading
            ? SpinKitFadingFour(size: 50, color: AppTheme.primaryColor)
            : UiKitView(
                viewType: viewType,
                layoutDirection: TextDirection.ltr,
                creationParams: creationParams,
                creationParamsCodec: const StandardMessageCodec(),
              ));
  }
}

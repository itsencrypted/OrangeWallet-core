import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:orangewallet/theme_data.dart';
import 'package:orangewallet/utils/misc/credential_manager.dart';
import 'package:orangewallet/utils/network/network_manager.dart';

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
  List<String> args;
  @override
  initState() {
    CredentialManager.getAddress().then((address) {
      NetworkManager.getNetworkObject().then((value) {
        setState(() {
          this.address = address;
          this.chainId = value.chainId.toString();
          _loading = false;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context).settings.arguments;
    privateKey = args[0];
    uri = args[1];
    final String viewType = 'WalletConnectView';
    final List<String> creationParams = [address, args[0], uri, chainId];

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

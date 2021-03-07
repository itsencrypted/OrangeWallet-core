import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/misc/credential_manager.dart';
import 'package:pollywallet/utils/network/network_manager.dart';

class WalletConnectAndroid extends StatefulWidget {
  @override
  _WalletConnectAndroidState createState() => _WalletConnectAndroidState();
}

class _WalletConnectAndroidState extends State<WalletConnectAndroid> {
  String address;
  String chainId;
  String uri = "";
  String privateKey = "";
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
    final Map<String, dynamic> creationParams = {
      addressString: address,
      privateKeyString: "privateKey",
      wcUri: "uri",
      "chainId": "80001"
    };

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
            : AndroidView(
                viewType: viewType,
                layoutDirection: TextDirection.ltr,
                creationParams: creationParams,
                creationParamsCodec: const StandardMessageCodec(),
              ));
  }
}

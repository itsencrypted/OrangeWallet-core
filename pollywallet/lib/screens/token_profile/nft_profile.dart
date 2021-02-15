import 'package:flutter/material.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/covalent_models/covalent_token_list.dart';
import 'package:pollywallet/models/covalent_models/token_history.dart';
import 'package:pollywallet/screens/token_profile/nft_tile.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/misc/credential_manager.dart';

class NftProfile extends StatefulWidget {
  @override
  _NftProfileState createState() => _NftProfileState();
}

class _NftProfileState extends State<NftProfile> {
  List<NftData> args;
  String address = "";
  List<TransferInfo> txList;
  @override
  void initState() {
    CredentialManager.getAddress().then((val) => address = val);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context).settings.arguments;
    List<Widget> ls = List<Widget>();
    args.forEach((element) {
      ls.add(NftTile(data: element));
    });
    print(ls.length);
    return Scaffold(
        appBar: AppBar(
          title: Text("Token Profile"),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Wrap(
                    alignment: WrapAlignment.start,
                    direction: Axis.horizontal,
                    children: ls,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

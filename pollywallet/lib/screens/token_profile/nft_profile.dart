import 'package:flutter/material.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/covalent_models/covalent_token_list.dart';
import 'package:pollywallet/models/covalent_models/token_history.dart';
import 'package:pollywallet/models/send_token_model/send_token_data.dart';
import 'package:pollywallet/screens/token_profile/nft_tile.dart';
import 'package:pollywallet/state_manager/send_token_state/send_token_cubit.dart';
import 'package:pollywallet/utils/misc/credential_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NftProfile extends StatefulWidget {
  @override
  _NftProfileState createState() => _NftProfileState();
}

class _NftProfileState extends State<NftProfile> {
  Items args;
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
    var nft = args.nftData;
    List<Widget> ls = [];
    args.nftData.forEach((element) {
      ls.add(FlatButton(
          padding: EdgeInsets.all(0),
          onPressed: () {
            var cubit = context.read<SendTransactionCubit>();

            cubit.setData(SendTokenData(token: args));
            Navigator.pushNamed(context, sendNftRoute,
                arguments: element.tokenId);
          },
          child: NftTile(data: element)));
    });
    print(ls.length);
    return Scaffold(
        appBar: AppBar(
          title: Text("Token Profile"),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Wrap(
                  alignment: WrapAlignment.start,
                  direction: Axis.horizontal,
                  children: ls,
                ),
              ],
            ),
          ),
        ));
  }
}

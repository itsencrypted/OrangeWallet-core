import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/credential_models/credentials_model.dart';
import 'package:pollywallet/state_manager/covalent_states/covalent_token_list_cubit_ethereum.dart';
import 'package:pollywallet/state_manager/covalent_states/covalent_token_list_cubit_matic.dart';
import 'package:pollywallet/state_manager/staking_data/delegation_data_state/delegations_data_cubit.dart';
import 'package:pollywallet/state_manager/staking_data/validator_data/validator_data_cubit.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/misc/box.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountSelection extends StatefulWidget {
  @override
  _AccountSelectionState createState() => _AccountSelectionState();
}

class _AccountSelectionState extends State<AccountSelection> {
  List<CredentialsObject> list;
  bool _loading = true;
  int active;
  @override
  void initState() {
    BoxUtils.getCredentialsList().then((list) {
      BoxUtils.getActiveId().then((account) {
        setState(() {
          this.list = list;
          active = account;
          _loading = false;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Accounts"),
        ),
        body: _loading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SpinKitFadingFour(
                      size: 50,
                      color: AppTheme.primaryColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Loading...."),
                    )
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () async {
                              await BoxUtils.setAccount(index);
                              context
                                  .read<CovalentTokensListEthCubit>()
                                  .getTokensList();
                              context
                                  .read<CovalentTokensListMaticCubit>()
                                  .getTokensList();
                              context.read<DelegationsDataCubit>().setData();
                              context.read<ValidatorsdataCubit>().setData();
                              _refresh();
                            },
                            child: Card(
                              shape: AppTheme.cardShape,
                              elevation: AppTheme.cardElevations,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: ListTile(
                                    title: Text("Account $index",
                                        style: AppTheme.title),
                                    subtitle: Text(list[index].address),
                                    trailing: Container(
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.blue),
                                      child: index == active
                                          ? Icon(
                                              Icons.check,
                                              size: 24.0,
                                              color: Colors.white,
                                            )
                                          : Icon(
                                              Icons.circle,
                                              size: 24.0,
                                              color: Colors.white,
                                            ),
                                    )),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    FlatButton(
                        onPressed: () async {
                          await Navigator.pushNamed(
                              context, pinForNewAccountRoute);
                          _refresh();
                        },
                        child: Text(
                          "Add new account",
                          style: TextStyle(color: Colors.blue),
                        ))
                  ],
                ),
              ));
  }

  _refresh() {
    BoxUtils.getCredentialsList().then((list) {
      BoxUtils.getActiveId().then((account) {
        setState(() {
          this.list = list;
          active = account;
        });
      });
    });
  }
}

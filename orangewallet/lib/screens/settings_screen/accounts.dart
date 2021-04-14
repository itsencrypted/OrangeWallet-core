import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:orangewallet/constants.dart';
import 'package:orangewallet/models/credential_models/credentials_model.dart';
import 'package:orangewallet/state_manager/covalent_states/covalent_token_list_cubit_ethereum.dart';
import 'package:orangewallet/state_manager/covalent_states/covalent_token_list_cubit_matic.dart';
import 'package:orangewallet/state_manager/staking_data/delegation_data_state/delegations_data_cubit.dart';
import 'package:orangewallet/state_manager/staking_data/validator_data/validator_data_cubit.dart';
import 'package:orangewallet/theme_data.dart';
import 'package:orangewallet/utils/misc/box.dart';
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
                child: Padding(
                  padding: EdgeInsets.all(AppTheme.paddingHeight12),
                  child: Card(
                    shape: AppTheme.cardShape,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
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
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(
                                          AppTheme.paddingHeight),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      SvgPicture.asset(
                                                          accountIconsvg),
                                                      SizedBox(
                                                        width: AppTheme
                                                            .paddingHeight,
                                                      ),
                                                      Text("Account $index",
                                                          style: AppTheme.title)
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        AppTheme.paddingHeight,
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.60,
                                                    child: Text(
                                                      list[index].address,
                                                      style:
                                                          AppTheme.body_small,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                width: AppTheme.paddingHeight,
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius
                                                        .circular(AppTheme
                                                                .cardRadiusBig /
                                                            2),
                                                    color: index == active
                                                        ? AppTheme.orange_500
                                                        : AppTheme.white),
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
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Divider(
                                      thickness: 1,
                                      height: 1,
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 0.0, bottom: 15),
                          child: TextButton(
                              style: TextButton.styleFrom(
                                  padding:
                                      EdgeInsets.all(AppTheme.paddingHeight12),
                                  backgroundColor: AppTheme.orange_500,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(100))),
                              onPressed: () async {
                                await Navigator.pushNamed(
                                    context, pinForNewAccountRoute);
                                _refresh();
                              },
                              child: Text("Add new account",
                                  style: AppTheme.label_medium
                                      .copyWith(color: AppTheme.white))),
                        )
                      ],
                    ),
                  ),
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

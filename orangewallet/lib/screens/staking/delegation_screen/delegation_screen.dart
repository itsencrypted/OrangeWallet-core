import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:orangewallet/models/staking_models/validators.dart';
import 'package:orangewallet/screens/staking/delegation_screen/ui_elements/delegation_card.dart';
import 'package:orangewallet/state_manager/covalent_states/covalent_token_list_cubit_matic.dart';
import 'package:orangewallet/state_manager/staking_data/delegation_data_state/delegations_data_cubit.dart';
import 'package:orangewallet/state_manager/staking_data/validator_data/validator_data_cubit.dart';
import 'package:orangewallet/theme_data.dart';
import 'package:orangewallet/utils/web3_utils/eth_conversions.dart';

class DelegationScreen extends StatefulWidget {
  @override
  _DelegationScreenState createState() => _DelegationScreenState();
}

class _DelegationScreenState extends State<DelegationScreen> {
  TextEditingController controller = TextEditingController();
  SearchBar searchBar;
  String searchStr = "";
  bool showSearch = false;
  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
        title: new Text('All Delegations'),
        actions: [searchBar.getSearchAction(context)]);
  }

  _DelegationScreenState() {
    searchBar = new SearchBar(
        inBar: showSearch,
        buildDefaultAppBar: buildAppBar,
        setState: setState,
        hintText: "Token Name",
        controller: controller,
        showClearButton: true,
        onSubmitted: onSubmitted,
        onCleared: onClear,
        onClosed: onClose);
  }

  @override
  void initState() {
    controller.addListener(_search);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      var tokenListCubit = context.read<CovalentTokensListMaticCubit>();
      var validatorListCubit = context.read<ValidatorsdataCubit>();
      var delegatorListCubit = context.read<DelegationsDataCubit>();

      tokenListCubit.getTokensList();
      _refreshLoop(tokenListCubit, delegatorListCubit, validatorListCubit);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.backgroundWhite,
        appBar: searchBar.build(context),
        body: BlocBuilder<CovalentTokensListMaticCubit,
            CovalentTokensListMaticState>(
          builder: (context, tokenState) {
            return BlocBuilder<DelegationsDataCubit, DelegationsDataState>(
                builder: (context, delegationState) {
              return BlocBuilder<ValidatorsdataCubit, ValidatorsDataState>(
                  builder: (context, validatorState) {
                if (validatorState is ValidatorsDataStateLoading ||
                    validatorState is ValidatorsDataStateInitial ||
                    delegationState is DelegationsDataStateInitial ||
                    delegationState is DelegationsDataStateLoading ||
                    tokenState is CovalentTokensListMaticLoading) {
                  return Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SpinKitFadingFour(
                          size: 50,
                          color: AppTheme.primaryColor,
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text("Loading .."),
                        ),
                      ],
                    ),
                  );
                } else if (delegationState is DelegationsDataStateFinal &&
                    validatorState is ValidatorsDataStateFinal &&
                    tokenState is CovalentTokensListMaticLoaded) {
                  return Container(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        ValidatorInfo validator = validatorState.data.result
                            .where((element) =>
                                element.id.toString() ==
                                delegationState
                                    .data.result[index].bondedValidator)
                            .toList()
                            .first;
                        double qoute = tokenState.covalentTokenList.data.items
                            .where((element) =>
                                element.contractTickerSymbol.toLowerCase() ==
                                "matic")
                            .toList()
                            .first
                            .quoteRate;
                        BigInt reward = validator.reward;
                        if (!_searchCond(validator)) {
                          return Container();
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: DelegationCard(
                              id: validator.id,
                              title: validator.name,
                              subtitle:
                                  '${validator.uptimePercent.toString()}% Checkpoints Signed',
                              commission:
                                  validator.commissionPercent.toString(),
                              iconURL:
                                  'https://cdn3.iconfinder.com/data/icons/unicons-vector-icons-pack/32/external-256.png',
                              maticStake: EthConversions.weiToEth(
                                      delegationState.data.result[index].stake,
                                      18)
                                  .toStringAsFixed(3),
                              stakeInUsd: (qoute *
                                      EthConversions.weiToEth(
                                          delegationState
                                              .data.result[index].stake,
                                          18))
                                  .toStringAsFixed(3),
                              maticRewards: EthConversions.weiToEth(reward, 18)
                                  .toString(),
                              rewardInUsd:
                                  (qoute * EthConversions.weiToEth(reward, 18))
                                      .toStringAsFixed(3)),
                        );
                      },
                      itemCount: delegationState.data.result.length,
                    ),
                  );
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                            icon: Icon(Icons.refresh),
                            color: AppTheme.grey,
                            onPressed: () {
                              context.read<DelegationsDataCubit>().setData();
                              context.read<ValidatorsdataCubit>().setData();
                            }),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Something Went wrong."),
                        ),
                      ],
                    ),
                  );
                }
              });
            });
          },
        ));
  }

  void onSubmitted(String value) {}
  void onClear() {
    setState(() {
      searchStr = "";

      controller.text = "";
    });
  }

  _search() {
    setState(() {
      searchStr = controller.text;
    });
  }

  void onClose() {
    setState(() {
      searchStr = "";
      controller.text = "";
      showSearch = false;
    });
  }

  bool _searchCond(ValidatorInfo validator) {
    var name = validator.name;

    return name.toLowerCase().contains(searchStr.toLowerCase());
  }

  _refreshLoop(CovalentTokensListMaticCubit cubit, DelegationsDataCubit dCubit,
      ValidatorsdataCubit vCubit) {
    new Timer.periodic(Duration(seconds: 30), (Timer t) {
      if (mounted) {
        cubit.refresh();
        dCubit.refresh();
        vCubit.refresh();
      }
    });
  }
}

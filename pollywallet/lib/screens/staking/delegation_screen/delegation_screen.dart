import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pollywallet/models/staking_models/validators.dart';
import 'package:pollywallet/screens/staking/delegation_screen/ui_elements/delegation_card.dart';
import 'package:pollywallet/state_manager/covalent_states/covalent_token_list_cubit_matic.dart';
import 'package:pollywallet/state_manager/deposit_data_state/deposit_data_cubit.dart';
import 'package:pollywallet/state_manager/staking_data/delegation_data_state/delegations_data_cubit.dart';
import 'package:pollywallet/state_manager/staking_data/validator_data/validator_data_cubit.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';

class DelegationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.backgroundWhite,
        appBar: AppBar(
          elevation: 0,
          title: Text(
            'All Delegations',
            style: AppTheme.listTileTitle,
          ),
          actions: [IconButton(icon: Icon(Icons.search), onPressed: () {})],
        ),
        body: BlocBuilder<CovalentTokensListMaticCubit,
            CovalentTokensListMaticState>(
          builder: (context, covalentMaticState) {
            return BlocBuilder<DelegationsDataCubit, DelegationsDataState>(
                builder: (context, delegationState) {
              return BlocBuilder<ValidatorsdataCubit, ValidatorsDataState>(
                  builder: (context, validatorState) {
                if (validatorState is ValidatorsDataStateLoading ||
                    validatorState is ValidatorsDataStateInitial ||
                    delegationState is DelegationsDataStateInitial ||
                    delegationState is DelegationsDataStateLoading) {
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
                    covalentMaticState is CovalentTokensListMaticLoaded) {
                  return Container(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        ValidatorInfo validator = validatorState.data.result
                            .where((element) =>
                                element.id ==
                                delegationState
                                    .data.result[index].bondedValidator)
                            .toList()
                            .first;
                        double qoute = covalentMaticState
                            .covalentTokenList.data.items
                            .where((element) =>
                                element.contractTickerSymbol.toLowerCase() ==
                                "matic")
                            .toList()
                            .first
                            .quoteRate;
                        return DelegationCard(
                            id: validator.id,
                            title: validator.name,
                            subtitle:
                                '${validator.uptimePercent.toString()}% Checkpoints Signed',
                            commission: validator.commissionPercent.toString(),
                            iconURL:
                                'https://cdn3.iconfinder.com/data/icons/unicons-vector-icons-pack/32/external-256.png',
                            maticStake: EthConversions.weiToEth(
                                    delegationState.stake, 18)
                                .toString(),
                            stakeInUsd: (qoute *
                                    EthConversions.weiToEth(
                                        delegationState.stake, 18))
                                .toStringAsFixed(2),
                            maticRewards: EthConversions.weiToEth(
                                    delegationState.rewards, 18)
                                .toString(),
                            rewardInUsd: (qoute *
                                    EthConversions.weiToEth(
                                        delegationState.rewards, 18))
                                .toStringAsFixed(2));
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
}

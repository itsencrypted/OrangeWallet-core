import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/covalent_models/covalent_token_list.dart';
import 'package:pollywallet/models/staking_models/delegator_details.dart';
import 'package:pollywallet/models/staking_models/validators.dart';
import 'package:pollywallet/models/transaction_data/transaction_data.dart';
import 'package:pollywallet/state_manager/covalent_states/covalent_token_list_cubit_ethereum.dart';
import 'package:pollywallet/state_manager/covalent_states/covalent_token_list_cubit_matic.dart';
import 'package:pollywallet/state_manager/staking_data/delegation_data_state/delegations_data_cubit.dart';
import 'package:pollywallet/state_manager/staking_data/validator_data/validator_data_cubit.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/fiat_crypto_conversions.dart';
import 'package:pollywallet/utils/network/network_config.dart';
import 'package:pollywallet/utils/network/network_manager.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';
import 'package:pollywallet/utils/web3_utils/ethereum_transactions.dart';
import 'package:pollywallet/utils/web3_utils/staking_transactions.dart';
import 'package:pollywallet/widgets/loading_indicator.dart';
import 'package:web3dart/web3dart.dart';

class StakeWithdrawAmount extends StatefulWidget {
  @override
  _StakeWithdrawAmountState createState() => _StakeWithdrawAmountState();
}

class _StakeWithdrawAmountState extends State<StakeWithdrawAmount> {
  double balance = 0;
  TextEditingController _amount = TextEditingController();
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      var tokenListCubit = context.read<CovalentTokensListMaticCubit>();
      var validatorListCubit = context.read<ValidatorsdataCubit>();
      var delegatorListCubit = context.read<DelegationsDataCubit>();
      var ethListCubit = context.read<CovalentTokensListEthCubit>();

      tokenListCubit.getTokensList();
      _refreshLoop(
          tokenListCubit, ethListCubit, delegatorListCubit, validatorListCubit);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var id = ModalRoute.of(context).settings.arguments;
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            'Withdraw Amount',
            style: AppTheme.listTileTitle,
          ),
        ),
        body:
            BlocBuilder<CovalentTokensListEthCubit, CovalentTokensListEthState>(
          builder: (context, covalentEthState) {
            return BlocBuilder<CovalentTokensListMaticCubit,
                CovalentTokensListMaticState>(
              builder: (context, covalentMaticState) {
                return BlocBuilder<DelegationsDataCubit, DelegationsDataState>(
                    builder: (context, delegationState) {
                  return BlocBuilder<ValidatorsdataCubit, ValidatorsDataState>(
                      builder: (context, validatorState) {
                    if (validatorState is ValidatorsDataStateLoading ||
                        validatorState is ValidatorsDataStateInitial ||
                        delegationState is DelegationsDataStateInitial ||
                        delegationState is DelegationsDataStateLoading ||
                        covalentMaticState is CovalentTokensListMaticLoading ||
                        covalentEthState is CovalentTokensListMaticLoading) {
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
                        covalentMaticState is CovalentTokensListMaticLoaded &&
                        covalentEthState is CovalentTokensListEthLoaded) {
                      if (covalentEthState.covalentTokenList.data.items
                              .where((element) =>
                                  element.contractTickerSymbol.toLowerCase() ==
                                  "matic")
                              .toList()
                              .length >
                          0) {}

                      var matic = covalentMaticState
                          .covalentTokenList.data.items
                          .where((element) =>
                              element.contractTickerSymbol.toLowerCase() ==
                              "matic")
                          .first;
                      print("id");
                      print(validatorState.data.result
                          .where((element) => element.id == id)
                          .toList()[0]
                          .contractAddress);
                      ValidatorInfo validator = validatorState.data.result
                          .where((element) => element.id == id)
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
                      DelegatorInfo delegatorInfo;
                      var len = delegationState.data.result
                          .where((element) => element.bondedValidator == id)
                          .toList()
                          .length;
                      if (len > 0) {
                        delegatorInfo = delegationState.data.result
                            .where((element) => element.bondedValidator == id)
                            .toList()
                            .first;
                        balance =
                            EthConversions.weiToEth(delegatorInfo.stake, 18);
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            validator.name,
                            style: AppTheme.title,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: TextFormField(
                                  controller: _amount,
                                  keyboardAppearance: Brightness.dark,
                                  textAlign: TextAlign.center,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (val) =>
                                      (val == "" || val == null) ||
                                              (double.tryParse(val) == null ||
                                                  (double.tryParse(val) < 0 ||
                                                      double.tryParse(val) >
                                                          balance))
                                          ? "Invalid Amount"
                                          : null,
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  style: AppTheme.bigLabel,
                                  decoration: InputDecoration(
                                    hintText: "Amount",
                                    hintStyle: AppTheme.body1,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                              Text(
                                "\$" +
                                    FiatCryptoConversions.cryptoToFiat(
                                            double.parse(_amount.text == ""
                                                ? "0"
                                                : _amount.text),
                                            matic.quoteRate)
                                        .toString(),
                                style: AppTheme.bigLabel,
                              )
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SafeArea(
                                child: ListTile(
                                  leading: FlatButton(
                                    onPressed: () {
                                      _amount.text = balance.toStringAsFixed(2);
                                    },
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    child: ClipOval(
                                        child: Material(
                                      color: AppTheme.secondaryColor
                                          .withOpacity(0.3),
                                      child: SizedBox(
                                          height: 56,
                                          width: 56,
                                          child: Center(
                                            child: Text(
                                              "Max",
                                              style: AppTheme.title,
                                            ),
                                          )),
                                    )),
                                  ),
                                  title: Text(
                                    "Matic on Stake",
                                    style: AppTheme.subtitle,
                                  ),
                                  subtitle: Text(
                                    balance.toStringAsFixed(2) +
                                        " " +
                                        matic.contractName,
                                    style: AppTheme.title,
                                  ),
                                  trailing: FlatButton(
                                    onPressed: () {
                                      //print(validator.contractAddress);
                                      _undelegate(
                                          validator.contractAddress,
                                          delegatorInfo,
                                          covalentMaticState
                                              .covalentTokenList.data.items
                                              .where((element) =>
                                                  element.contractName
                                                      .toLowerCase() ==
                                                  "matic")
                                              .first);
                                    },
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    child: ClipOval(
                                        child: Material(
                                      color: AppTheme.primaryColor,
                                      child: SizedBox(
                                          height: 56,
                                          width: 56,
                                          child: Center(
                                            child: Icon(Icons.check,
                                                color: AppTheme.white),
                                          )),
                                    )),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
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
                                  context
                                      .read<DelegationsDataCubit>()
                                      .setData();
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
            );
          },
        ));
  }

  _undelegate(String validatorContracts, DelegatorInfo delegatorInfo,
      Items token) async {
    if (double.tryParse(_amount.text) == null ||
        double.tryParse(_amount.text) < 0 ||
        double.tryParse(_amount.text) > balance) {
      Fluttertoast.showToast(
          msg: "Invalid amount", toastLength: Toast.LENGTH_LONG);
      return;
    }
    print(validatorContracts);
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context, false);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Continue"),
      onPressed: () {
        Navigator.pop(context, true);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      shape: AppTheme.cardShape,
      content: Text(
          "You haven't given sufficient approval, would you like to approve now?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    GlobalKey<State> _key = new GlobalKey<State>();
    Dialogs.showLoadingDialog(context, _key);
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    Transaction trx;
    TransactionData transactionData;
    BigInt approval = await EthereumTransactions.allowance(
        config.stakeManagerProxy, config.maticToken);
    var wei = EthConversions.ethToWei(_amount.text);
    if (approval < wei) {
      bool appr = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
      if (appr) {
        trx = await EthereumTransactions.approveErc20(
          config.maticToken,
          validatorContracts,
        );
        transactionData = TransactionData(
            to: config.maticToken,
            amount: "0",
            trx: trx,
            token: token,
            type: TransactionType.APPROVE);
      } else {
        Navigator.of(context, rootNavigator: true).pop();
        return;
      }
    } else {
      trx = await StakingTransactions.sellVoucher(
          _amount.text, validatorContracts);
      transactionData = TransactionData(
          to: validatorContracts,
          amount: _amount.text,
          trx: trx,
          token: token,
          type: TransactionType.STAKE);
    }
    Navigator.of(context, rootNavigator: true).pop();

    Navigator.pushNamed(context, ethereumTransactionConfirmRoute,
        arguments: transactionData);
  }

  _refreshLoop(
      CovalentTokensListMaticCubit cubit,
      CovalentTokensListEthCubit ethCubit,
      DelegationsDataCubit dCubit,
      ValidatorsdataCubit vCubit) {
    new Timer.periodic(Duration(seconds: 30), (Timer t) {
      if (mounted) {
        cubit.refresh();
        ethCubit.refresh();
        dCubit.refresh();
        vCubit.refresh();
      }
    });
  }
}

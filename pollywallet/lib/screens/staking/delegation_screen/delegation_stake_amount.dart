import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/staking_models/delegator_details.dart';
import 'package:pollywallet/models/staking_models/validators.dart';
import 'package:pollywallet/models/tansaction_data/transaction_data.dart';
import 'package:pollywallet/models/transaction_models/transaction_information.dart';
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

class DelegationAmount extends StatefulWidget {
  @override
  _DelegationAmountState createState() => _DelegationAmountState();
}

class _DelegationAmountState extends State<DelegationAmount> {
  double balance = 0;
  TextEditingController _amount = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var id = ModalRoute.of(context).settings.arguments;
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            'Amount to Delegate',
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
                        covalentMaticState is CovalentTokensListMaticLoaded &&
                        covalentEthState is CovalentTokensListEthLoaded) {
                      if (covalentEthState.covalentTokenList.data.items
                              .where((element) =>
                                  element.contractTickerSymbol.toLowerCase() ==
                                  "matic")
                              .toList()
                              .length >
                          0) {
                        balance = EthConversions.weiToEth(
                            BigInt.parse(covalentEthState
                                .covalentTokenList.data.items
                                .where((element) =>
                                    element.contractTickerSymbol
                                        .toLowerCase() ==
                                    "matic")
                                .first
                                .balance),
                            18);
                      }

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
                                  validator: (val) => (val == "" ||
                                              val == null) ||
                                          (double.tryParse(val) == null ||
                                              (double.tryParse(val) < 1 ||
                                                  double.tryParse(val) >
                                                      balance))
                                      ? "Stake atleast 1 Matic and less than your balance"
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
                                      _amount.text = balance.toString();
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
                                    "Balance",
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
                                      _delegate(validator.contractAddress);
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

  _delegate(String spender) async {
    if (double.tryParse(_amount.text) == null ||
        double.tryParse(_amount.text) < 1 ||
        double.tryParse(_amount.text) > balance) {
      Fluttertoast.showToast(
          msg: "Invalid amount", toastLength: Toast.LENGTH_LONG);
      return;
    }
    print(spender);
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
    print(approval);
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
          spender,
        );
        transactionData = TransactionData(
            to: config.maticToken,
            amount: "0",
            trx: trx,
            type: TransactionType.APPROVE);
      } else {
        Navigator.of(context, rootNavigator: true).pop();
        return;
      }
    } else {
      trx = await StakingTransactions.buyVoucher(_amount.text, spender);
      transactionData = TransactionData(
          to: spender,
          amount: _amount.text,
          trx: trx,
          type: TransactionType.STAKE);
    }
    Navigator.of(context, rootNavigator: true).pop();

    Navigator.pushNamed(context, ethereumTransactionConfirmRoute,
        arguments: transactionData);
  }
}

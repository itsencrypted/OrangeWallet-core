import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/covalent_models/token_history.dart';
import 'package:pollywallet/screens/token_profile/transaction_tile.dart';
import 'package:pollywallet/state_manager/covalent_states/covalent_token_list_cubit_matic.dart';
import 'package:pollywallet/state_manager/send_token_state/send_token_cubit.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/api_wrapper/covalent_api_wrapper.dart';
import 'package:pollywallet/utils/misc/credential_manager.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';

class CoinProfile extends StatefulWidget {
  @override
  _CoinProfileState createState() => _CoinProfileState();
}

class _CoinProfileState extends State<CoinProfile> {
  String address = "";
  List<TransferInfo> txList;
  var future;
  var futureSet = false;
  @override
  void initState() {
    CredentialManager.getAddress().then((val) => address = val);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      var tokenListCubit = context.read<CovalentTokensListMaticCubit>();

      _refreshLoop(tokenListCubit);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Token Profile"),
      ),
      body: BlocBuilder<SendTransactionCubit, SendTransactionState>(
        builder: (BuildContext context, state) {
          return BlocBuilder<CovalentTokensListMaticCubit,
              CovalentTokensListMaticState>(builder: (context, tokenState) {
            if (state is SendTransactionFinal &&
                tokenState is CovalentTokensListMaticLoaded) {
              var token = tokenState.covalentTokenList.data.items
                  .where((element) =>
                      state.data.token.contractAddress ==
                      element.contractAddress)
                  .first;
              if (!futureSet) {
                future = CovalentApiWrapper.maticTokenTransfers(
                    token.contractAddress);
                futureSet = true;
              }

              var balance = EthConversions.weiToEth(
                  BigInt.parse(token.balance.toString()),
                  state.data.token.contractDecimals);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Container(
                              height: 256,
                              width: MediaQuery.of(context).size.width * 0.83,
                              decoration: BoxDecoration(
                                  color: AppTheme.warmGrey,
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(AppTheme.cardRadius))),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: 265,
                            child: Card(
                              shape: AppTheme.cardShape,
                              elevation: AppTheme.cardElevations + 0.2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: FadeInImage.assetNetwork(
                                        placeholder: tokenIcon,
                                        image: token.logoUrl,
                                        width: AppTheme.tokenIconSizeBig,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 1, bottom: 0),
                                      child: Text(
                                        "$balance ${token.contractTickerSymbol}",
                                        style: AppTheme.headline,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "${token.quote.toStringAsFixed(2)} USD",
                                        style: AppTheme.headline_grey,
                                      ),
                                    ),
                                    Divider(
                                      color: AppTheme.borderColorGreyish,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        SizedBox(
                                          width: 101,
                                          height: 44,
                                          child: TextButton(
                                            style: ButtonStyle(shape:
                                                MaterialStateProperty
                                                    .resolveWith<
                                                        OutlinedBorder>((_) {
                                              return RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100));
                                            }), backgroundColor:
                                                MaterialStateProperty
                                                    .resolveWith<Color>(
                                              (Set<MaterialState> states) {
                                                if (states.contains(
                                                    MaterialState.pressed))
                                                  return sendButtonColor
                                                      .withOpacity(0.5);
                                                return sendButtonColor
                                                    .withOpacity(1);
                                                ; // Use the component's default.
                                              },
                                            )),
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                  context, payAmountRoute);
                                            },
                                            child: Container(
                                                child: Center(
                                                    child: Text(
                                              "Send",
                                              style: AppTheme.buttonText,
                                            ))),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 101,
                                          height: 44,
                                          child: TextButton(
                                            style: ButtonStyle(shape:
                                                MaterialStateProperty
                                                    .resolveWith<
                                                        OutlinedBorder>((_) {
                                              return RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100));
                                            }), backgroundColor:
                                                MaterialStateProperty
                                                    .resolveWith<Color>(
                                              (Set<MaterialState> states) {
                                                if (states.contains(
                                                    MaterialState.pressed))
                                                  return receiveButtonColor
                                                      .withOpacity(0.5);
                                                return receiveButtonColor
                                                    .withOpacity(1);
                                                ; // Use the component's default.
                                              },
                                            )),
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                  context, bridgeActionRoute);
                                            },
                                            child: Container(
                                                width: double.infinity,
                                                child: Center(
                                                    child: Text("Bridge",
                                                        style: AppTheme
                                                            .buttonText))),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      FutureBuilder(
                        future: future,
                        builder: (context, result) {
                          if (result.connectionState ==
                              ConnectionState.waiting) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SpinKitFadingFour(
                                    size: 50, color: AppTheme.primaryColor),
                                Text(
                                  "Loading...",
                                  style: AppTheme.subtitle,
                                )
                              ],
                            );
                          } else if (result.connectionState ==
                              ConnectionState.done) {
                            var tx = result.data.data.transferInfo;
                            return tx.length != 0
                                ? Card(
                                    shape: AppTheme.cardShape,
                                    color: AppTheme.white,
                                    elevation: AppTheme.cardElevations,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: ExpansionTile(
                                        title: Text("Transaction History"),
                                        trailing: Icon(Icons.arrow_forward),
                                        children: [
                                          Text("All transactions",
                                              style: AppTheme.subtitle),
                                          Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height -
                                                550,
                                            child: ListView.builder(
                                              itemCount: result.data.data
                                                  .transferInfo.length,
                                              itemBuilder: (context, index) {
                                                return TransactionTile(
                                                  data: tx[index],
                                                  address:
                                                      result.data.data.address,
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("No Transactions"),
                                  );
                          } else {
                            return Center(
                              child: Text("Something went wrong"),
                            );
                          }
                        },
                      )
                    ],
                  ),
                ),
              );
            } else {
              return Center(child: Text("Something went Wrong"));
            }
          });
        },
      ),
    );
  }

  _refreshLoop(CovalentTokensListMaticCubit maticCubit) {
    new Timer.periodic(Duration(seconds: 30), (Timer t) {
      if (mounted) {
        maticCubit.refresh();
      }
    });
  }
}

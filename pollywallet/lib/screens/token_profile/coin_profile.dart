import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/covalent_models/token_history.dart';
import 'package:pollywallet/screens/token_profile/transaction_tile.dart';
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
  @override
  void initState() {
    CredentialManager.getAddress().then((val) => address = val);
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
          if (state is SendTransactionFinal) {
            var balance = EthConversions.weiToEth(
                BigInt.parse(state.data.token.balance.toString()));
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50, bottom: 5),
                    child: Text(
                      "$balance",
                      style: AppTheme.display1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "\$${state.data.token.quote}",
                      style: AppTheme.headline,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "${state.data.token.contractName} balance",
                      style: AppTheme.subtitle,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 100,
                        child: TextButton(
                          style: ButtonStyle(shape:
                              MaterialStateProperty.resolveWith<OutlinedBorder>(
                                  (_) {
                            return RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100));
                          }), backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed))
                                return receiveButtonColor.withOpacity(0.5);
                              return receiveButtonColor.withOpacity(0.7);
                              ; // Use the component's default.
                            },
                          )),
                          onPressed: () {},
                          child: Container(
                              width: double.infinity,
                              child: Center(
                                  child: Text("Deposit",
                                      style: AppTheme.buttonText))),
                        ),
                      ),
                      TextButton(
                        style: ButtonStyle(shape:
                            MaterialStateProperty.resolveWith<OutlinedBorder>(
                                (_) {
                          return RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100));
                        }), backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed))
                              return sendButtonColor.withOpacity(0.5);
                            return sendButtonColor.withOpacity(0.7);
                            ; // Use the component's default.
                          },
                        )),
                        onPressed: () {
                          Navigator.pushNamed(context, payAmountRoute);
                        },
                        child: Container(
                            child: Center(
                                child: Text(
                          "Send",
                          style: AppTheme.buttonText,
                        ))),
                      ),
                      SizedBox(
                        width: 100,
                        child: TextButton(
                          style: ButtonStyle(shape:
                              MaterialStateProperty.resolveWith<OutlinedBorder>(
                                  (_) {
                            return RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100));
                          }), backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed))
                                return receiveButtonColor.withOpacity(0.5);
                              return receiveButtonColor.withOpacity(0.7);
                              ; // Use the component's default.
                            },
                          )),
                          onPressed: () {},
                          child: Container(
                              width: double.infinity,
                              child: Center(
                                  child: Text("Withdraw",
                                      style: AppTheme.buttonText))),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  FutureBuilder(
                    future: CovalentApiWrapper.maticTokenTransfers(
                        state.data.token.contractAddress),
                    builder: (context, result) {
                      if (result.connectionState == ConnectionState.waiting) {
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
                        return Card(
                          shape: AppTheme.cardShape,
                          color: AppTheme.white,
                          elevation: AppTheme.cardElevations,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: ExpansionTile(
                              title: Text("Transaction History"),
                              trailing: Icon(Icons.arrow_forward),
                              children: [
                                Text(
                                    tx.length == 0
                                        ? "All transactions"
                                        : "No transactions",
                                    style: AppTheme.subtitle),
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.45,
                                  child: ListView.builder(
                                    itemCount:
                                        result.data.data.transferInfo.length,
                                    itemBuilder: (context, index) {
                                      return TransactionTile(
                                        data: tx[index],
                                        address: result.data.data.address,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
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
            );
          } else {
            return Center(child: Text("Something went Wrong"));
          }
        },
      ),
    );
  }
}

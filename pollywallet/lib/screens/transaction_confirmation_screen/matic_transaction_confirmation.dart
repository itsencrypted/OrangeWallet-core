import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/transaction_data/transaction_data.dart';
import 'package:pollywallet/screens/token_profile/transaction_tile.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/misc/box.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';
import 'package:pollywallet/utils/web3_utils/matic_transactions.dart';
import 'package:pollywallet/widgets/loading_indicator.dart';
import 'package:pollywallet/widgets/matic_to_eth_indicator.dart';
import 'package:slide_to_confirm/slide_to_confirm.dart';

class MaticTransactionConfirm extends StatefulWidget {
  @override
  _MaticTransactionConfirmState createState() =>
      _MaticTransactionConfirmState();
}

class _MaticTransactionConfirmState extends State<MaticTransactionConfirm> {
  TransactionData args;
  bool _loading = true;
  var gasPrice;
  int network;
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      args = ModalRoute.of(context).settings.arguments;
      print(args.to);
      print(args.amount);
      print(args.type);
      BoxUtils.getNetworkConfig().then((network) {
        MaticTransactions.getGasPrice().then((value) {
          setState(() {
            gasPrice = value;
            _loading = false;
            this.network = network;
          });
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: _loading
              ? Text("Confirm transaction")
              : Text(TransactionData.txTypeString[args.type.index]),
        ),
        body: _loading
            ? SpinKitFadingFour(
                size: 50,
                color: AppTheme.primaryColor,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                  ),
                  Column(
                    children: [
                      (args.type == TransactionType.BURNPLASMA ||
                              args.type == TransactionType.BURNPOS ||
                              args.type == TransactionType.EXITPLASMA ||
                              args.type == TransactionType.EXITPOS ||
                              args.type == TransactionType.CONFIRMPLASMA)
                          ? Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.09),
                              child: MaticToEthIndicator(),
                            )
                          : Container(),
                      Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Container(
                              height: 243,
                              width: MediaQuery.of(context).size.width * 0.7,
                              decoration: BoxDecoration(
                                  color: AppTheme.warmGrey,
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(AppTheme.cardRadius))),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Card(
                              shape: AppTheme.cardShape,
                              //elevation: AppTheme.cardElevations,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: 233,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    SizedBox(),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          double.tryParse(args.amount)
                                                  .toStringAsFixed(3) +
                                              " ${args.token.contractTickerSymbol}",
                                          style: AppTheme.boldThemeColoredText,
                                        ),
                                        Text(
                                          " ${args.token.quoteRate * double.parse(args.amount)} USD",
                                          style: AppTheme.balanceSub,
                                        )
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Divider(color: AppTheme.grey),
                                        SizedBox(),
                                        Text(network == 0
                                            ? "Matic Testnet"
                                            : "Matic Mainnet"),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 8, 0, 0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Image.asset(boltIcon),
                                              ),
                                              Text(
                                                "${EthConversions.weiToGwei(gasPrice)} Gwei Matic Gas Price",
                                                style: AppTheme.body2,
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          args.type == TransactionType.SEND
                              ? Positioned(
                                  top: 0,
                                  //left: MediaQuery.of(context).size.width * 0.25,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(40)),
                                          elevation: 0,
                                          color: AppTheme.somewhatYellow,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(0),
                                                child: Icon(
                                                  Icons.account_circle_sharp,
                                                  color: AppTheme.darkText,
                                                  size: 35,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 100,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 2.0),
                                                  child: Text(
                                                    args.to,
                                                    style: AppTheme.body2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container()
                        ],
                      ),
                    ],
                  ),
                  SafeArea(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SafeArea(
                          child: ConfirmationSlider(
                              backgroundShape: BorderRadius.all(
                                  Radius.circular(AppTheme.cardRadius)),
                              foregroundShape: BorderRadius.all(
                                  Radius.circular(AppTheme.cardRadius)),
                              foregroundColor: AppTheme.primaryColor,
                              onConfirmation: () => _sendTx()))
                    ],
                  ))
                ],
              ));
  }

  _sendTx() async {
    final GlobalKey<State> _keyLoader = new GlobalKey<State>();
    Dialogs.showLoadingDialog(context, _keyLoader);
    String hash =
        await MaticTransactions.sendTransaction(args.trx, args, context);
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    if (hash == null || hash == "failed") {
      return;
    }
    Navigator.pop(context);
    Navigator.popAndPushNamed(context, sendingStatusRoute,
        arguments: [hash, false]);
  }
}

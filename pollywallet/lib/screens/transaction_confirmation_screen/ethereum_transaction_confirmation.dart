import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:menu_button/menu_button.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/transaction_data/transaction_data.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/misc/box.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';
import 'package:pollywallet/utils/web3_utils/ethereum_transactions.dart';
import 'package:pollywallet/widgets/eth_to_matic_indicator.dart';
import 'package:pollywallet/widgets/loading_indicator.dart';
import 'package:slide_to_confirm/slide_to_confirm.dart';

class EthTransactionConfirmation extends StatefulWidget {
  @override
  _EthTransactionConfirmationState createState() =>
      _EthTransactionConfirmationState();
}

class _EthTransactionConfirmationState
    extends State<EthTransactionConfirmation> {
  TransactionData args;
  bool _loading = true;
  BigInt gasPrice;
  BigInt fast;
  BigInt slow;
  BigInt normal;
  BigInt selectedGas;
  var network = 0;
  var items = <String>[];
  int speed = 1; //0 - slow, 1 - normal, 2- fast
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (args.gas != null) {
        BoxUtils.getNetworkConfig().then((network) {
          setState(() {
            this.network = network;
            gasPrice = args.gas +
                BigInt.two * BigInt.from((args.gas ~/ BigInt.from(10)).toInt());
            fast =
                gasPrice + BigInt.from((gasPrice ~/ BigInt.from(10)).toInt());
            slow =
                gasPrice - BigInt.from((gasPrice ~/ BigInt.from(10)).toInt());
            normal = gasPrice;
            items.add(normal.toString());
            items.add(slow.toString());
            items.add(fast.toString());
            _loading = false;
          });
        });
      } else {
        EthereumTransactions.getGasPrice().then((value) {
          BoxUtils.getNetworkConfig().then((network) {
            setState(() {
              this.network = network;
              gasPrice = value;
              fast =
                  gasPrice + BigInt.from((gasPrice ~/ BigInt.from(10)).toInt());
              slow =
                  gasPrice - BigInt.from((gasPrice ~/ BigInt.from(10)).toInt());
              normal = gasPrice;
              items.add(normal.toString());
              items.add(slow.toString());
              items.add(fast.toString());

              _loading = false;
            });
          });
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(items);
    args = ModalRoute.of(context).settings.arguments;
    if (args.trx == null) {
      Navigator.pop(context);
    }
    return Scaffold(
        appBar: AppBar(
          title: _loading
              ? Text("Confirm transaction")
              : Text(TransactionData.txTypeString[args.type.index]),
        ),
        body: _loading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SpinKitFadingFour(
                    size: 50,
                    color: AppTheme.primaryColor,
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                    ),
                    Column(
                      children: [
                        (args.type == TransactionType.DEPOSITPLASMA ||
                                args.type == TransactionType.DEPOSITPOS)
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.09),
                                child: EthToMaticIndicator(),
                              )
                            : Container(),
                        Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Container(
                                height: 273,
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  height: 263,
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
                                            style:
                                                AppTheme.boldThemeColoredText,
                                            textAlign: TextAlign.center,
                                          ),
                                          args.token != null &&
                                                  args.token.quoteRate != null
                                              ? Text(
                                                  " ${args.token.quoteRate * double.parse(args.amount)} USD",
                                                  style: AppTheme.balanceSub,
                                                )
                                              : Container()
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Divider(color: AppTheme.grey),
                                          SizedBox(),
                                          Text(network == 0
                                              ? "Goerli Testnet"
                                              : "Ethereum Mainnet"),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 8, 0, 0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  child: Image.asset(boltIcon),
                                                ),
                                                MenuButton(
                                                    divider: Divider(
                                                      color: AppTheme.white,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(EthConversions.weiToGwei(
                                                                      BigInt.parse(
                                                                          gasPrice
                                                                              .toString()))
                                                                  .toString() +
                                                              " Gwei Gas Price"),
                                                        ),
                                                        Icon(Icons
                                                            .arrow_drop_down_circle_outlined),
                                                      ],
                                                    ),
                                                    items: items,
                                                    itemBuilder:
                                                        (String value) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(EthConversions
                                                                    .weiToGwei(
                                                                        BigInt.parse(
                                                                            value))
                                                                .toString() +
                                                            " Gwei"),
                                                      );
                                                    },
                                                    onMenuButtonToggle:
                                                        (bool isToggle) {
                                                      print(isToggle);
                                                    },
                                                    toggledChild: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        children: [
                                                          Text(EthConversions.weiToGwei(
                                                                      BigInt.parse(
                                                                          gasPrice
                                                                              .toString()))
                                                                  .toString() +
                                                              " Gwei Gas Price"),
                                                          Icon(Icons
                                                              .arrow_drop_down_circle_outlined),
                                                        ],
                                                      ),
                                                    ),
                                                    onItemSelected:
                                                        (String value) {
                                                      setState(() {
                                                        gasPrice =
                                                            BigInt.parse(value);
                                                      });
                                                    }),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        args.gas != null
                            ? ListTile(
                                leading: ClipOval(
                                  clipBehavior: Clip.antiAlias,
                                  child: Container(
                                    child: Text("!",
                                        style: TextStyle(
                                            fontSize: 50,
                                            color: AppTheme.black,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                title: Text("Note"),
                                subtitle: Text(
                                    "If your previous transaction goes throug it will keep on waiting feel free to navigate away on confirmation screen."),
                                isThreeLine: true,
                              )
                            : Container(),
                        Row(
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
                        ),
                      ],
                    )),
                  ]));
  }

  _sendTx() async {
    args = ModalRoute.of(context).settings.arguments;
    print(args.amount);
    final GlobalKey<State> _keyLoader = new GlobalKey<State>();
    Dialogs.showLoadingDialog(context, _keyLoader);
    String hash = await EthereumTransactions.sendTransaction(
        args.trx, selectedGas, args.type, args, context);
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    if (hash == null || hash == "failed") {
      return;
    }
    Navigator.pop(context);
    Navigator.popAndPushNamed(context, sendingStatusRoute,
        arguments: [hash, true]);
  }
}
// Text(
//                                               "${EthConversions.weiToGwei(gasPrice)} Gwei Matic Gas Price",
//                                               style: AppTheme.body2,
//                                             ),
// Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Network:",
//                         style: AppTheme.title,
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text("Ethereum", style: AppTheme.subtitle),
//                       ),
//                       Text(
//                         "To:",
//                         style: AppTheme.title,
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           args.to,
//                           style: AppTheme.subtitle,
//                         ),
//                       ),
//                       Text(
//                         "Amount:",
//                         style: AppTheme.title,
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           args.amount,
//                           style: AppTheme.subtitle,
//                         ),
//                       ),
//                       Text(
//                         "Type:",
//                         style: AppTheme.title,
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           TransactionData.txTypeString[args.type.index],
//                           style: AppTheme.subtitle,
//                         ),
//                       ),
//                       Text(
//                         args.gas != null
//                             ? "Select higher gas"
//                             : "Select speed:",
//                         style: AppTheme.title,
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 8.0, horizontal: 0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             FlatButton(
//                                 onPressed: () {
//                                   setState(() {
//                                     speed = 0;
//                                     selectedGas = slow;
//                                   });
//                                 },
//                                 child: Card(
//                                   shape: AppTheme.cardShape,
//                                   elevation: AppTheme.cardElevations,
//                                   color: speed == 0
//                                       ? AppTheme.secondaryColor
//                                       : Colors.grey,
//                                   child: SizedBox(
//                                     width: cardWidth,
//                                     child: Center(
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(8.0),
//                                         child: Text(
//                                           args.gas != null
//                                               ? "fast\n${EthConversions.weiToGwei(slow)} Gwei"
//                                               : "Slow\n${EthConversions.weiToGwei(slow)} Gwei",
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 )),
//                             FlatButton(
//                                 onPressed: () {
//                                   setState(() {
//                                     speed = 1;
//                                     selectedGas = normal;
//                                   });
//                                 },
//                                 child: Card(
//                                   shape: AppTheme.cardShape,
//                                   elevation: AppTheme.cardElevations,
//                                   color: speed == 1
//                                       ? AppTheme.secondaryColor
//                                       : Colors.grey,
//                                   child: SizedBox(
//                                     width: cardWidth,
//                                     child: Center(
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(8.0),
//                                         child: Text(
//                                           args.gas != null
//                                               ? "Faster\n${EthConversions.weiToGwei(normal)} Gwei"
//                                               : "Normal\n${EthConversions.weiToGwei(normal)} Gwei",
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 )),
//                             FlatButton(
//                                 onPressed: () {
//                                   setState(() {
//                                     speed = 2;
//                                     selectedGas = fast;
//                                   });
//                                 },
//                                 child: Card(
//                                   shape: AppTheme.cardShape,
//                                   elevation: AppTheme.cardElevations,
//                                   color: speed == 2
//                                       ? AppTheme.secondaryColor
//                                       : Colors.grey,
//                                   child: SizedBox(
//                                     width: cardWidth,
//                                     child: Center(
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(8.0),
//                                         child: Text(
//                                           args.gas != null
//                                               ? "Fastest\n${EthConversions.weiToGwei(fast)} Gwei"
//                                               : "Fast\n${EthConversions.weiToGwei(fast)} Gwei",
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 )),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

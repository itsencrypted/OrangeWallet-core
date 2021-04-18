import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:orangewallet/constants.dart';
import 'package:orangewallet/state_manager/covalent_states/covalent_token_list_cubit_ethereum.dart';
import 'package:orangewallet/theme_data.dart';
import 'package:orangewallet/utils/fiat_crypto_conversions.dart';
import 'package:orangewallet/utils/misc/box.dart';
import 'package:orangewallet/utils/network/network_config.dart';
import 'package:orangewallet/utils/network/network_manager.dart';
import 'package:orangewallet/utils/web3_utils/eth_conversions.dart';
import 'package:orangewallet/widgets/transaction_details_timeline.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';

class TransactionStatusEthereum extends StatefulWidget {
  @override
  _TransactionStatusEthereumState createState() =>
      _TransactionStatusEthereumState();
}

class _TransactionStatusEthereumState extends State<TransactionStatusEthereum> {
  TransactionReceipt receipt;
  String txHash;
  String from;
  String to;
  String gas;
  double value = 0;
  bool loading = true;
  StreamSubscription streamSubscription;
  //int status = 0; //0=no status, 1= merged, 2= failed
  bool unmerged = false;
  bool speedupStuck = false;
  String blockExplorer = "";
  bool show = false;
  bool failed = false;
  bool transactionPending = true;
  int index = 1;
  final List<String> processes = [
    'Initialized',
    'Transaction Pending',
    'Transaction Confirmed',
  ];
  List<String> messages = [
    'Your transaction has been sent',
    'Transaction is waiting to be merged',
    'Transaction merged',
  ];

  @override
  void initState() {
    NetworkManager.getNetworkObject().then((config) {
      blockExplorer = config.blockExplorerEth;
    });

    SchedulerBinding.instance.addPostFrameCallback((_) {
      final String txHash = ModalRoute.of(context).settings.arguments;
      print(txHash);
      this.txHash = txHash;
      txStatus(txHash);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Details"),
          actions: [
            IconButton(
                icon: Icon(Icons.ios_share),
                onPressed: () {
                  Share.share(
                    blockExplorer + "/tx/" + txHash,
                  );
                })
          ],
        ),
        body: loading
            ? Center(
                child: SpinKitFadingFour(
                  color: AppTheme.primaryColor,
                  size: 50,
                ),
              )
            : unmerged
                ? Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipOval(
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                          child: Text("!",
                              style: TextStyle(
                                  fontSize: 50,
                                  color: AppTheme.black,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Text("Another transaction with same nonce got merged."),
                    ],
                  ))
                : BlocBuilder<CovalentTokensListEthCubit,
                        CovalentTokensListEthState>(
                    builder: (BuildContext context,
                        CovalentTokensListEthState state) {
                    var ethQouteRate = 0.0;
                    if (state is CovalentTokensListEthLoaded) {
                      var list = state.covalentTokenList.data.items.where(
                          (element) =>
                              element.contractTickerSymbol.toLowerCase() ==
                              "eth");
                      if (list.isNotEmpty) {
                        ethQouteRate = list.first.quoteRate;
                        print(ethQouteRate);
                      }
                    }
                    return SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(AppTheme.paddingHeight / 2),
                        child: Column(
                          children: [
                            getTopContainer(ethQouteRate),
                            getStatusCard(),
                            Card(
                              shape: AppTheme.cardShape,
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          AppTheme.cardRadius),
                                      color: AppTheme.stackingGrey,
                                    ),
                                    margin:
                                        EdgeInsets.all(AppTheme.paddingHeight),
                                    height: 110,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        detailsArea(
                                          title: gas.toString() + " ETH",
                                          subtitle: 'Transaction Fee',
                                          topWidget: SvgPicture.asset(
                                              transactionFeesvg),
                                        ),
                                        detailsArea(
                                            title: 'Ethereum Network',
                                            subtitle: 'Netowrk',
                                            topWidget: SvgPicture.asset(
                                                settingsIconsvg))
                                      ],
                                    ),
                                  ),
                                  getListTile(
                                      image: Image.asset(
                                        tokenIcon,
                                        height: AppTheme.tokenIconHeight,
                                      ),
                                      title: "From",
                                      subtitle: from
                                      // trailing: IconButton(
                                      //     icon: Icon(
                                      //       Icons.file_copy,
                                      //       color: Colors.black,
                                      //     ),
                                      //     onPressed: () {}),
                                      ),
                                  getListTile(
                                    image: Image.asset(
                                      tokenIcon,
                                      height: AppTheme.tokenIconHeight,
                                    ),
                                    title: 'To',
                                    subtitle: to,
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.file_copy,
                                        // color: Colors.black,
                                      ),
                                      onPressed: () {
                                        Clipboard.setData(
                                            new ClipboardData(text: txHash));
                                      },
                                    ),
                                  ),
                                  Divider(
                                    color: Colors.grey,
                                  ),
                                  getListTile(
                                    image: CircleAvatar(
                                      backgroundColor: AppTheme.warmgray_800,
                                      child: SvgPicture.asset(
                                        locksvg,
                                      ),
                                      radius: AppTheme.tokenIconHeight / 2,
                                    ),
                                    title: 'Transaction Hash',
                                    subtitle: txHash,
                                    trailing: IconButton(
                                      icon: Icon(Icons.open_in_browser),
                                      onPressed: _launchURL,
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }));
  }

  Widget getTopContainer(double qouteRate) {
    var fiat = 0.0;
    if (qouteRate != 0) {
      print(value);
      fiat = FiatCryptoConversions.cryptoToFiat(value, qouteRate);
    }
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppTheme.paddingHeight20 * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.all(AppTheme.paddingHeight / 4),
              decoration: BoxDecoration(
                  color: failed
                      ? Colors.red
                      : unmerged
                          ? Colors.orangeAccent
                          : index == 1
                              ? Colors.orangeAccent
                              : Colors.green,
                  borderRadius:
                      BorderRadius.circular(AppTheme.cardRadiusSmall)),
              child: Text(
                failed
                    ? 'Unsucessful'
                    : unmerged
                        ? "Unsucessful1"
                        : index == 1
                            ? "Pending"
                            : "Successful",
                style: AppTheme.body2White,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppTheme.paddingHeight / 2),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  value == 0
                      ? Container()
                      : Image.asset(
                          ethIcon,
                          height: AppTheme.tokenIconHeight,
                        ),
                  // SizedBox(
                  //   width: AppTheme.paddingHeight,
                  // ),
                  Text(
                    value == 0
                        ? "Contract Interaction"
                        : " ${value.toString()} ETH",
                    style: value == 0 ? AppTheme.display2 : AppTheme.display1,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  fiat != 0
                      ? Text(
                          value == 0
                              ? "Contract Interaction"
                              : " ${fiat.toStringAsPrecision(3)} USD",
                          style: AppTheme.body_medium_grey,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Container(),
                  // SizedBox(
                  //   width: AppTheme.paddingHeight20 * 2,
                  // ),
                ],
              ),
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.all(AppTheme.paddingHeight / 2),
          //   child: Text(
          //     '\$${box?.first?.amount}',
          //     style: AppTheme.subtitle,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget getStatusCard() {
    return Card(
      shape: AppTheme.cardShape,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: AppTheme.paddingHeight,
              left: AppTheme.paddingHeight,
              right: AppTheme.paddingHeight,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                failed
                    ? Icon(
                        Icons.cancel,
                        color: AppTheme.red_500,
                      )
                    : transactionPending
                        ? Icon(
                            Icons.timer,
                            color: AppTheme.yellow_500,
                          )
                        : Icon(
                            Icons.check,
                            color: Colors.teal[500],
                          ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: AppTheme.paddingHeight / 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        failed
                            ? Text(
                                "Transaction Failed",
                                style: AppTheme.header_H5,
                              )
                            : unmerged
                                ? Text(
                                    "Transaction with same nonce merged",
                                    style: AppTheme.header_H5,
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        transactionPending
                                            ? 'Sending Transaction'
                                            : "Transaction Successful",
                                        style: AppTheme.header_H5,
                                      ),
                                      Text(
                                        transactionPending
                                            ? 'Transaction may take a few moments to complete.'
                                            : "Transaction Finished Successfully",
                                        maxLines: 4,
                                        style: AppTheme.body2,
                                      ),
                                    ],
                                  ),
                        (failed || unmerged)
                            ? Container()
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    transactionPending
                                        ? "Pending"
                                        : "Sucessful",
                                    style: AppTheme.body2,
                                  ),
                                  IconButton(
                                      icon: Icon(
                                          Icons.keyboard_arrow_down_outlined),
                                      onPressed: () {
                                        setState(() {
                                          show = !show;
                                        });
                                      }),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (show)
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(
                  color: Colors.grey,
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: AppTheme.paddingHeight),
                  child: TransactionDetailsTimeline(
                    details: processes,
                    messages: index == 1
                        ? [
                            'Your transaction has been sent',
                            'sup',
                            'Transaction merged',
                          ]
                        : messages,
                    txHash: txHash,
                    doneTillIndex: index,
                  ),
                )
              ],
            )
        ],
      ),
    );
  }

  Widget getListTile(
      {Widget image, String title, String subtitle, Widget trailing}) {
    return ListTile(
        leading: image,
        title: Text(
          title,
          style: AppTheme.subtitle,
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.label_medium,
        ),
        trailing: trailing);
  }

  Widget detailsArea({String title, String subtitle, Widget topWidget}) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          topWidget,
          SizedBox(
            height: 8,
          ),
          Text(
            '$title',
            style: AppTheme.balanceMain,
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            '$subtitle',
            style: AppTheme.balanceSub
                .copyWith(color: AppTheme.balanceSub.color.withOpacity(0.6)),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    try {
      streamSubscription.cancel();
    } catch (e) {}

    super.dispose();
  }

  Future<void> txStatus(String txHash) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client =
        Web3Client(config.ethEndpoint, http.Client(), socketConnector: () {
      return IOWebSocketChannel.connect(config.ethWebsocket).cast<String>();
    });
    print(txHash);
    final client2 = Web3Client(config.ethEndpoint, http.Client());
    var txFuture = client2.getTransactionReceipt(txHash);
    TransactionInformation tbh;
    try {
      tbh = await client2.getTransactionByHash(txHash);
    } catch (e) {
      BoxUtils.removePendingTx(txHash);
      setState(() {
        unmerged = true;
        loading = false;
      });
      return;
    }
    var tx;
    if (tbh != null) {
      setState(() {
        gas = EthConversions.weiToEthUnTrimmed(
                (tbh.gasPrice.getInWei * BigInt.from(tbh.gas)), 18)
            .toString();
        to = tbh.to.toString();
        from = tbh.from.toString();
        value = EthConversions.weiToEthUnTrimmed(tbh.value.getInWei, 18);
        loading = false;
      });
      tx = await txFuture;
    } else if (tx != null) {
      setState(() {
        to = tx.to.toString();
        from = tx.from.toString();
        gas = EthConversions.weiToEthUnTrimmed(tx.gasUsed, 18).toString();
        loading = false;
      });
    }
    tx = await txFuture;
    print(tx);
    if (tx != null) {
      setState(() {
        if (tx.status) {
          transactionPending = false;
          index = 2;
          receipt = tx;
        } else {
          receipt = tx;
          index = 2;
          failed = true;
          transactionPending = true;
        }
      });
      return;
    }

    streamSubscription = client.addedBlocks().listen(null);
    streamSubscription.onData((data) async {
      var tx = await client2.getTransactionReceipt(txHash);
      print(tx);
      try {
        await client2.getTransactionByHash(txHash);
      } catch (e) {
        BoxUtils.removePendingTx(txHash);
        setState(() {
          unmerged = true;
        });
      }
      if (tx != null) {
        setState(() {
          if (tx.status) {
            receipt = tx;
            index = 2;
            transactionPending = false;
          } else {
            receipt = tx;
            failed = true;
            transactionPending = false;
          }
        });
        streamSubscription.cancel();
      }
    });
  }

  _launchURL() async {
    var url = blockExplorer + "/tx/" + txHash;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

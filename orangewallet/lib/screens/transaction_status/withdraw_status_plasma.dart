import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:orangewallet/constants.dart';
import 'package:orangewallet/models/withdraw_models/withdraw_data_db.dart';
import 'package:orangewallet/screens/transaction_status/ui_elements/plasma_timeline.dart';
import 'package:orangewallet/screens/transaction_status/ui_elements/pos_timeline.dart';
import 'package:orangewallet/theme_data.dart';
import 'package:orangewallet/utils/misc/box.dart';
import 'package:orangewallet/utils/misc/credential_manager.dart';
import 'package:orangewallet/utils/network/network_manager.dart';
import 'package:orangewallet/utils/withdraw_manager/withdraw_manager_api.dart';

import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class WithdrawStatusPlasma extends StatefulWidget {
  @override
  _WithdrawStatusPlasmaState createState() => _WithdrawStatusPlasmaState();
}

class _WithdrawStatusPlasmaState extends State<WithdrawStatusPlasma> {
  WithdrawDataDb data;
  bool show = true;
  bool failed = false;
  int statusCode = 0;
  bool transactionPending = false;
  String fromAddress = "";
  bool loading = true;
  String blockExplorer = "";
  var index = 0;
  final List<String> processes = [
    'Initialized',
    'Burnt',
    'Checkpointed',
    'Confirm',
    'Challenge period',
    'Ready for Exit',
    'Exiting',
    'Exited',
  ];
  final List<String> messages = [
    'Withdraw has been initialized',
    'Tokens burnt',
    'Burn has been Checkpointed',
    'confirm',
    'Waiting for challenge period to be over',
    'exit',
    'Exit in progress',
    'Withdraw succesful',
  ];
  @override
  void initState() {
    NetworkManager.getNetworkObject().then((config) {
      blockExplorer = config.blockExplorerEth;
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      data = ModalRoute.of(context).settings.arguments;

      setState(() {
        if (data.exited == null || data.exited == false) {
          transactionPending = true;
        } else {
          transactionPending = true;
        }
      });

      WithdrawManagerApi.plasmaStatusCodes(
              data.burnHash, data.confirmHash, data.exitHash)
          .then((value) {
        print("value");
        print(value);
        setState(() {
          statusCode = value;
          if (statusCode == -10) {
            transactionPending = false;
          } else {
            transactionPending = true;
          }
          if (statusCode > -3) {
            index = 0;
          } else if (statusCode > -4) {
            index = 1;
          } else if (statusCode > -9) {
            index = 3;
          }
          if (statusCode == -3) {
            index = 1;
          } else if (statusCode == -4) {
            index = 3;
          } else if (statusCode == -10) {
            index = 7;
          } else if (statusCode == -5) {
            index = 4;
          } else if (statusCode == -6) {
            index = 5;
            failed = true;
          } else if (statusCode == -7) {
            index = 4;
            failed = true;
          } else if (statusCode == -8) {
            index = 4;
          } else if (statusCode == -9) {
            index = 5;
          } else if (statusCode == -12) {
            index = 6;
          }
          if (statusCode == -2 || statusCode == -6) {
            failed = true;
            show = false;
          }
          if (statusCode == -10) {
            BoxUtils.markWithdrawComplete(burnTxHash: data.burnHash);
          }
          if (statusCode == -11) {
            failed = true;
            show = false;
          }
          loading = false;
        });
      });
      if (transactionPending) {
        _refreshLoop(data.burnHash);
      }
    });
    CredentialManager.getAddress().then((value) {
      setState(() {
        fromAddress = value;
      });
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
                  blockExplorer + "/tx/" + data.burnHash,
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
          : data == null
              ? Center(
                  child: SpinKitFadingFour(
                    size: 50,
                    color: AppTheme.primaryColor,
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(AppTheme.paddingHeight / 2),
                    child: Column(
                      children: [
                        getTopContainer(),
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
                                margin: EdgeInsets.all(AppTheme.paddingHeight),
                                height: 110,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    detailsArea(
                                      title: data.fee == null
                                          ? ""
                                          : data.fee + " ETH",
                                      subtitle: 'Transaction Fee',
                                      topWidget:
                                          SvgPicture.asset(transactionFeesvg),
                                    ),
                                    detailsArea(
                                        title: 'Ethereum Network',
                                        subtitle: 'Netowrk',
                                        topWidget:
                                            SvgPicture.asset(settingsIconsvg))
                                  ],
                                ),
                              ),
                              getListTile(
                                image: Image.asset(
                                  tokenIcon,
                                  height: AppTheme.tokenIconHeight,
                                ),
                                title: 'From',
                                subtitle: fromAddress,
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
                                subtitle: "Ethereum Network",
                                // trailing: IconButton(
                                //     icon: Icon(
                                //       Icons.file_copy,
                                //       color: Colors.black,
                                //     ),
                                //     onPressed: () {}),
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
                                subtitle: data.burnHash,
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.open_in_browser,
                                    color: Colors.black,
                                  ),
                                  onPressed: _launchURL,
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget getTopContainer() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppTheme.paddingHeight20 * 2),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.all(AppTheme.paddingHeight / 4),
              decoration: BoxDecoration(
                  color: failed
                      ? Colors.red
                      : transactionPending
                          ? Colors.amber
                          : Colors.green,
                  borderRadius:
                      BorderRadius.circular(AppTheme.cardRadiusSmall)),
              child: Text(
                failed
                    ? "Transaction Failed"
                    : transactionPending
                        ? "Withdraw in progress"
                        : "Withdraw Successful",
                style: AppTheme.body2White,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppTheme.paddingHeight / 2),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                // Image.asset(
                //   tokenIcon,
                //   height: AppTheme.tokenIconHeight,
                // ),
                SizedBox(
                  width: AppTheme.paddingHeight,
                ),
                Text(
                  "${data.amount} ${data.name}",
                  style: AppTheme.display2,
                  overflow: TextOverflow.fade,
                ),
                // SizedBox(
                //   width: AppTheme.paddingHeight20 * 2,
                // ),
              ],
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.all(AppTheme.paddingHeight / 2),
          //   child: Text(
          //     '\$${int.parse(data.amount)*data.}',
          //     style: AppTheme.subtitle,
          //     overflow: TextOverflow.fade,
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
                      mainAxisAlignment: failed
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      children: [
                        Text(
                          failed
                              ? "Failed"
                              : transactionPending
                                  ? 'Processing withdraw'
                                  : "Withdraw Successful",
                          style: AppTheme.header_H5,
                        ),
                        Text(
                          failed
                              ? "Transaction Failed"
                              : transactionPending
                                  ? 'Withdraw process will  take some time to complete.'
                                  : "Withdraw Finished Successfully",
                          maxLines: 4,
                          style: AppTheme.body2,
                        ),
                        failed
                            ? Container()
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    statusCode == null
                                        ? ""
                                        : messages[index] == "exit"
                                            ? "Ready for exit"
                                            : '${messages[index]}',
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
                  child: PlasmaTimeline(
                    details: processes,
                    doneTillIndex: index,
                    messages: messages,
                    data: data,
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
          style: AppTheme.label_medium,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
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

  _refreshLoop(String txhash) {
    new Timer.periodic(Duration(seconds: 15), (Timer t) {
      if (mounted && (statusCode != -10)) {
        WithdrawManagerApi.plasmaStatusCodes(
                data.burnHash, data.confirmHash, data.exitHash)
            .then((value) {
          print(value);
          statusCode = value;
          if (statusCode == -10) {
            transactionPending = false;
          } else {
            transactionPending = true;
          }
          if (statusCode > -3) {
            index = 0;
          } else if (statusCode > -4) {
            index = 1;
          } else if (statusCode > -9) {
            index = 3;
          }
          if (statusCode == -3) {
            index = 1;
          } else if (statusCode == -4) {
            index = 2;
          } else if (statusCode == -10) {
            index = 5;
          } else if (statusCode == -5) {
            index = 3;
          } else if (statusCode == -6) {
            index = 4;
            failed = true;
          } else if (statusCode == -7) {
            index = 4;
            failed = true;
          } else if (statusCode == -8) {
            index = 3;
          } else if (statusCode == -9) {
            index = 4;
          } else if (statusCode == -12) {
            index = 5;
          }
          if (statusCode == -2 || statusCode == -6) {
            failed = true;
            show = false;
          }
          if (statusCode == -10) {
            BoxUtils.markWithdrawComplete(burnTxHash: data.burnHash);
          }
          if (statusCode == -11) {
            failed = true;
            show = false;
          }
          loading = false;
        });
      }
    });
  }

  _launchURL() async {
    var url = blockExplorer + "/tx/" + data.burnHash;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

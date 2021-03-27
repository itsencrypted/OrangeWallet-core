import 'package:flutter/material.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/theme_data.dart';

class SelectBridge extends StatelessWidget {
  const SelectBridge({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String nextRoute = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Transfer Mode"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Choose Transfer Mode"),
            ),
            FlatButton(
              onPressed: () {
                Navigator.popAndPushNamed(context, nextRoute, arguments: 1);
              },
              padding: EdgeInsets.all(0),
              child: Card(
                shape: AppTheme.cardShape,
                elevation: AppTheme.cardElevations,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, top: 22, bottom: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                posMeterIcon,
                                color: AppTheme.warmGrey_900,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  "POS Bridge",
                                  style: AppTheme.header_H4_Black,
                                ),
                              )
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: Text(
                          "Provides flexibility and faster withdrawals with POS system security",
                          style: AppTheme.subtitle,
                        ),
                      ),
                      Divider(
                        color: AppTheme.warmgray_100,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timer,
                            color: AppTheme.warmGrey_900,
                          ),
                          RichText(
                              text: TextSpan(
                                  text: " ~30 minutes",
                                  style: AppTheme.subtitle_primary_color,
                                  children: [
                                TextSpan(
                                  text: " for withdraw process",
                                  style: AppTheme.subtitle,
                                )
                              ]))
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            FlatButton(
              onPressed: () {
                Navigator.popAndPushNamed(context, nextRoute, arguments: 2);
              },
              padding: EdgeInsets.all(0),
              child: Card(
                shape: AppTheme.cardShape,
                elevation: AppTheme.cardElevations,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, top: 22, bottom: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                plasmaLockIcon,
                                color: AppTheme.warmGrey_900,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  "Plasma Bridge",
                                  style: AppTheme.header_H4_Black,
                                ),
                              )
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: Text(
                          "Provides increased security guarantees with Plasma exit mechanism.",
                          style: AppTheme.subtitle,
                        ),
                      ),
                      Divider(
                        color: AppTheme.warmgray_100,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timer,
                            color: AppTheme.warmGrey_900,
                          ),
                          RichText(
                              text: TextSpan(
                                  text: " ~7 Days",
                                  style: AppTheme.subtitle_primary_color,
                                  children: [
                                TextSpan(
                                  text: " for withdraw process",
                                  style: AppTheme.subtitle,
                                )
                              ]))
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

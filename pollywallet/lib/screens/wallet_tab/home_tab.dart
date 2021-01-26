import 'package:flutter/material.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/theme_data.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab>
    with AutomaticKeepAliveClientMixin<HomeTab> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "\$256.24",
                  style: AppTheme.display1,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    balanceString,
                    style: AppTheme.subtitle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 110,
                          child: TextButton(
                            style: ButtonStyle(shape: MaterialStateProperty
                                .resolveWith<OutlinedBorder>((_) {
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
                            onPressed: () {},
                            child: Container(
                                width: double.infinity,
                                child: Center(
                                    child: Text(
                                  "Send",
                                  style: AppTheme.buttonText,
                                ))),
                          ),
                        ),
                        SizedBox(
                          width: 110,
                          child: TextButton(
                            style: ButtonStyle(shape: MaterialStateProperty
                                .resolveWith<OutlinedBorder>((_) {
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
                                    child: Text("Receive",
                                        style: AppTheme.buttonText))),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

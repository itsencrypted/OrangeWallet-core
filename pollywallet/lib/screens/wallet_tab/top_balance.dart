import 'package:flutter/material.dart';
import 'package:pollywallet/utils/misc/credential_manager.dart';
import 'package:pollywallet/utils/network/network_config.dart';
import 'package:pollywallet/utils/network/network_manager.dart';

import '../../constants.dart';
import '../../theme_data.dart';

class TopBalance extends StatelessWidget {
  final balance;
  TopBalance(this.balance);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "\$$balance",
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
                            onPressed: () async {
                              var address =
                                  await CredentialManager.getAddress();
                              NetworkConfigObject config =
                                  await NetworkManager.getNetworkObject();
                              String url = config.transakLink + address;
                              Navigator.pushNamed(context, transakRoute,
                                  arguments: url);
                            },
                            child: Container(
                                width: double.infinity,
                                child: Center(
                                    child: Text(
                                  "Buy",
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
}

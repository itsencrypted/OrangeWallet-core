import 'package:flutter/material.dart';
import 'package:orangewallet/models/send_token_model/send_token_data.dart';
import 'package:orangewallet/state_manager/send_token_state/send_token_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 98,
                          height: 44,
                          child: TextButton(
                            style: ButtonStyle(shape: MaterialStateProperty
                                .resolveWith<OutlinedBorder>((_) {
                              return RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100));
                            }), backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed))
                                  return AppTheme.secondaryColor
                                      .withOpacity(0.2);
                                return AppTheme.secondaryColor.withOpacity(1);
                                ; // Use the component's default.
                              },
                            )),
                            onPressed: () {
                              Navigator.of(context).pushNamed(receivePageRoute);
                            },
                            child: Container(
                                width: double.infinity,
                                child: Center(
                                    child: Text("Receive",
                                        style: AppTheme.buttonTextSecondary))),
                          ),
                        ),
                        SizedBox(
                          width: 98,
                          height: 44,
                          child: TextButton(
                            style: ButtonStyle(shape: MaterialStateProperty
                                .resolveWith<OutlinedBorder>((_) {
                              return RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100));
                            }), backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed))
                                  return AppTheme.primaryColor.withOpacity(0.5);
                                return AppTheme.primaryColor.withOpacity(1);
                                ; // Use the component's default.
                              },
                            )),
                            onPressed: () {
                              var cubit = context.read<SendTransactionCubit>();
                              cubit.setData(SendTokenData());
                              Navigator.pushNamed(
                                context,
                                pickTokenRoute,
                              );
                            },
                            child: Container(
                                width: double.infinity,
                                child: Center(
                                    child: Text(
                                  "Send",
                                  style: AppTheme.buttonText,
                                ))),
                          ),
                        ),
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

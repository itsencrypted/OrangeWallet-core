import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/covalent_models/covalent_token_list.dart';
import 'package:pollywallet/models/deposit_models/deposit_model.dart';
import 'package:pollywallet/state_manager/deposit_data_state/deposit_data_cubit.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pollywallet/utils/web3_utils/ethereum_transactions.dart';
import 'package:pollywallet/widgets/loading_indicator.dart';

class TokenListTileBridge extends StatelessWidget {
  final Items tokenData;
  final int action; //0 deposit, 1 withdraw
  const TokenListTileBridge({Key key, this.tokenData, this.action})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var amount = EthConversions.weiToEth(
            BigInt.parse(tokenData.balance), tokenData.contractDecimals)
        .toString();
    DepositDataCubit data = context.read<DepositDataCubit>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Center(
        child: FlatButton(
          onPressed: () async {
            if (action == 0) {
              GlobalKey<State> _key = GlobalKey<State>();
              Dialogs.showLoadingDialog(context, _key);
              Future posFuture = EthereumTransactions.checkPosMapping(
                  tokenData.contractAddress);
              Future plasmaFuture = EthereumTransactions.checkPlasmaMapping(
                  tokenData.contractAddress);

              bool pos = await posFuture;
              bool plasma = await plasmaFuture;
              Navigator.of(_key.currentContext, rootNavigator: true).pop();
              int status = 0;
              if (pos) {
                status++;
              }
              if (plasma) {
                status++;
              }
              if (status == 0) {
                Fluttertoast.showToast(msg: "No bridge available");
                return;
              }
              DepositModel model = DepositModel(token: tokenData);
              data.setData(model);
              Navigator.pushNamed(context, depositAmountRoute,
                  arguments: status);
            }
          },
          child: Column(
            children: [
              ListTile(
                leading: FadeInImage.assetNetwork(
                  placeholder: tokenIcon,
                  image: tokenData.logoUrl,
                  width: AppTheme.tokenIconHeight,
                ),
                title: Text(tokenData.contractName, style: AppTheme.title),
                subtitle: Text(tokenData.contractTickerSymbol,
                    style: AppTheme.subtitle),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "\$${tokenData.quote}",
                      style: AppTheme.balanceMain,
                    ),
                    Text(
                      amount,
                      style: AppTheme.balanceSub,
                    ),
                  ],
                ),
              ),
              Divider(
                color: AppTheme.darkText,
              )
            ],
          ),
        ),
      ),
    );
  }
}
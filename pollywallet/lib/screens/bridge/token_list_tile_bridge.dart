import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/covalent_models/covalent_token_list.dart';
import 'package:pollywallet/models/deposit_models/deposit_model.dart';
import 'package:pollywallet/models/withdraw_models/withdraw_burn_data.dart';
import 'package:pollywallet/state_manager/deposit_data_state/deposit_data_cubit.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pollywallet/utils/web3_utils/ethereum_transactions.dart';
import 'package:pollywallet/widgets/loading_indicator.dart';
import 'package:pollywallet/state_manager/withdraw_burn_state/withdraw_burn_data_cubit.dart';

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
    DepositDataCubit depositData = context.read<DepositDataCubit>();
    WithdrawBurnDataCubit withdrawBurnData =
        context.read<WithdrawBurnDataCubit>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Card(
          shape: AppTheme.cardShape,
          elevation: AppTheme.cardElevations,
          color: AppTheme.white,
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
                  status = 1;
                }
                if (plasma) {
                  status == 1 ? status = 3 : status = 2;
                }
                if (tokenData.contractAddress.toLowerCase() ==
                    ethAddress.toLowerCase()) {
                  status = 3;
                }
                if (status == 0) {
                  Fluttertoast.showToast(msg: "No bridge available");
                  return;
                }
                DepositModel model = DepositModel(token: tokenData);
                depositData.setData(model);
                if (tokenData.nftData == null) {
                  if (status == 3) {
                    Navigator.pushNamed(context, selectBridgeRoute,
                        arguments: depositAmountRoute);
                    return;
                  }
                  Navigator.pushNamed(context, depositAmountRoute,
                      arguments: status);
                } else if (tokenData.nftData.first.tokenBalance != null) {
                  if (int.parse(tokenData.nftData.first.tokenBalance) > 0) {
                    if (status == 3) {
                      Navigator.pushNamed(context, selectBridgeRoute,
                          arguments: erc1155DepositRoute);
                      return;
                    }
                    Navigator.pushNamed(context, erc1155DepositRoute,
                        arguments: status);
                  } else {
                    Fluttertoast.showToast(msg: "Insufficient amount");
                  }
                } else {
                  if (status == 3) {
                    Navigator.pushNamed(context, selectBridgeRoute,
                        arguments: nftDepoitSelectRoute);
                    return;
                  }
                  Navigator.pushNamed(context, nftDepoitSelectRoute,
                      arguments: status);
                }
              } else {
                GlobalKey<State> _key = GlobalKey<State>();
                Dialogs.showLoadingDialog(context, _key);
                Future posFuture = EthereumTransactions.childToRootPos(
                    tokenData.contractAddress);
                Future plasmaFuture = EthereumTransactions.childToRootPlasma(
                    tokenData.contractAddress);

                bool pos = await posFuture;
                bool plasma = await plasmaFuture;
                Navigator.of(_key.currentContext, rootNavigator: true).pop();
                int status = 0;
                if (pos) {
                  status = 1;
                }
                if (plasma) {
                  status == 1 ? status = 3 : status = 2;
                }

                if (tokenData.contractAddress.toLowerCase() ==
                    ethAddress.toLowerCase()) {
                  status = 3;
                }
                if (status == 0) {
                  Fluttertoast.showToast(msg: "No bridge available");
                  return;
                }
                WithdrawBurnDataModel model =
                    WithdrawBurnDataModel(token: tokenData);
                withdrawBurnData.setData(model);
                if (tokenData.nftData == null) {
                  Navigator.pushNamed(context, withdrawAmountRoute,
                      arguments: status);
                } else if (tokenData.nftData.first.tokenBalance == null) {
                  Navigator.pushNamed(context, burnNftRoute, arguments: status);
                } else {
                  Navigator.pushNamed(context, erc1155BurnRoute,
                      arguments: status);
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
              child: ListTile(
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
            ),
          ),
        ),
      ),
    );
  }
}

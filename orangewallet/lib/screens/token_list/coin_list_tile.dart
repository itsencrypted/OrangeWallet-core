import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:orangewallet/constants.dart';
import 'package:orangewallet/models/covalent_models/covalent_token_list.dart';
import 'package:orangewallet/models/send_token_model/send_token_data.dart';
import 'package:orangewallet/state_manager/send_token_state/send_token_cubit.dart';
import 'package:orangewallet/theme_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orangewallet/utils/web3_utils/eth_conversions.dart';

class CoinListTileWithCard extends StatelessWidget {
  final Items tokenData;
  const CoinListTileWithCard({Key key, this.tokenData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var amount = EthConversions.weiToEth(
            BigInt.parse(tokenData.balance), tokenData.contractDecimals)
        .toString();
    SendTransactionCubit data = context.read<SendTransactionCubit>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Center(
        child: Card(
          color: AppTheme.white,
          shape: AppTheme.cardShape,
          elevation: AppTheme.cardElevations,
          child: FlatButton(
            onPressed: () {
              data.setData(SendTokenData(token: tokenData));
              Navigator.pushNamed(context, coinProfileRoute);
            },
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
                    "\$${tokenData.quote.toStringAsFixed(2)}",
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
    );
  }
}

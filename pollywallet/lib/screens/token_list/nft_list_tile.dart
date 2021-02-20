import 'package:flutter/material.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/covalent_models/covalent_token_list.dart';
import 'package:pollywallet/state_manager/send_token_state/send_token_cubit.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';

class NftTileCard extends StatelessWidget {
  final Items tokenData;
  const NftTileCard({Key key, this.tokenData}) : super(key: key);

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
          shape: AppTheme.cardShape,
          elevation: AppTheme.cardElevations,
          child: FlatButton(
            onPressed: () {
              Navigator.pushNamed(context, nftTokenProfile,
                  arguments: tokenData);
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
    );
  }
}

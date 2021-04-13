import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:orangewallet/constants.dart';
import 'package:orangewallet/state_manager/covalent_states/covalent_token_list_cubit_ethereum.dart';
import 'package:orangewallet/state_manager/covalent_states/covalent_token_list_cubit_matic.dart';
import 'package:orangewallet/state_manager/staking_data/delegation_data_state/delegations_data_cubit.dart';
import 'package:orangewallet/state_manager/staking_data/validator_data/validator_data_cubit.dart';
import 'package:orangewallet/theme_data.dart';
import 'package:orangewallet/utils/misc/box.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NetworkSetting extends StatefulWidget {
  @override
  _NetworkSettingState createState() => _NetworkSettingState();
}

class _NetworkSettingState extends State<NetworkSetting> {
  int value;
  @override
  initState() {
    BoxUtils.getNetworkConfig().then((val) {
      setState(() {
        value = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundWhite,
        elevation: 0,
        brightness: Brightness.light,
        title: Text("Network"),
      ),
      body: Container(
        padding: EdgeInsets.all(AppTheme.paddingHeight12),
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            networkCard(
                title: "Mainnet",
                body1: 'Ethereum network',
                body2: 'Matic network',
                val: 1),
            SizedBox(
              height: AppTheme.paddingHeight / 2,
            ),
            networkCard(
                title: "Testnet",
                body1: 'Goerli testnet',
                body2: 'Matic testnet',
                val: 0),
          ],
        ),
      ),
    );
  }

  Widget networkCard({String title, String body1, String body2, int val}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          value = val;
          BoxUtils.setNetworkConfig(value);
          context.read<CovalentTokensListEthCubit>().getTokensList();
          context.read<CovalentTokensListMaticCubit>().getTokensList();
          context.read<DelegationsDataCubit>().setData();
          context.read<ValidatorsdataCubit>().setData();
        });
      },
      child: Card(
        shape: AppTheme.cardShape,
        elevation: AppTheme.cardElevations,
        child: Padding(
          padding: EdgeInsets.all(AppTheme.paddingHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgPicture.asset(networkIconsvg),
                          SizedBox(
                            width: AppTheme.paddingHeight,
                          ),
                          Text(title ?? 'Mainnet', style: AppTheme.title)
                        ],
                      ),
                      SizedBox(
                        height: AppTheme.paddingHeight,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Text(
                          body1 ?? 'Ethereum network',
                          style: AppTheme.body_small,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: AppTheme.paddingHeight,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Text(
                          body2 ?? 'Matic network',
                          style: AppTheme.body_small,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: AppTheme.paddingHeight,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(AppTheme.cardRadiusBig / 2),
                        color: value == val
                            ? AppTheme.orange_500
                            : AppTheme.white),
                    child: value == val
                        ? Icon(
                            Icons.check,
                            size: 24.0,
                            color: Colors.white,
                          )
                        : Icon(
                            Icons.circle,
                            size: 24.0,
                            color: Colors.white,
                          ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

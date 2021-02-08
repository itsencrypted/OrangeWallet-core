import 'package:flutter/material.dart';
import 'package:pollywallet/state_manager/covalent_states/covalent_token_list_cubit_ethereum.dart';
import 'package:pollywallet/state_manager/covalent_states/covalent_token_list_cubit_matic.dart';
import 'package:pollywallet/state_manager/staking_data/delegation_data_state/delegations_data_cubit.dart';
import 'package:pollywallet/state_manager/staking_data/validator_data/validator_data_cubit.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/misc/box.dart';
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
        child: Padding(
          padding: EdgeInsets.all(AppTheme.paddingHeight / 2),
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
                  body1: 'Ropstern testnet',
                  body2: 'Matic testnet',
                  val: 0),
            ],
          ),
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
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(AppTheme.cardRadius))),
        color: AppTheme.white,
        elevation: AppTheme.cardElevations,
        child: Container(
          padding: EdgeInsets.all(AppTheme.paddingHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title ?? 'Mainnet',
                    style: AppTheme.title,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.blue),
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
              ),
              Divider(),
              SizedBox(
                height: AppTheme.paddingHeight / 2,
              ),
              Text(
                body1 ?? 'Ethereum network',
                style: AppTheme.body1,
              ),
              SizedBox(
                height: AppTheme.paddingHeight,
              ),
              Text(
                body2 ?? 'Matic network',
                style: AppTheme.body1,
              )
            ],
          ),
        ),
      ),
    );
  }
}

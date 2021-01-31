import 'package:flutter/material.dart';
import 'package:pollywallet/screens/staking/delegation_screen/ui_elements/delegation_card.dart';
import 'package:pollywallet/theme_data.dart';

class DelegationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.stackingGrey,
        title: Text(
          'All Validators',
          style: AppTheme.listTileTitle,
        ),
        actions: [IconButton(icon: Icon(Icons.search), onPressed: () {})],
      ),
      body: Container(
        child: ListView.builder(
          itemBuilder: (context, index) {
            return DelegationCard(
                title: 'Decentral.Gaming',
                subtitle: '98.72% Checkpoints Signed',
                commission: '10',
                iconURL:
                    'https://cdn3.iconfinder.com/data/icons/unicons-vector-icons-pack/32/external-256.png',
                maticWalletBalance: '12434124',
                etcWalletBalance: '123',
                maticStake: '12431242',
                stakeInETH: '421',
                maticRewards: '21412',
                rewardInETH: '31');
          },
          itemCount: 10,
        ),
      ),
    );
  }
}

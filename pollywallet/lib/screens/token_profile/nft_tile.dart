import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pollywallet/models/covalent_models/covalent_token_list.dart';
import 'package:pollywallet/theme_data.dart';

class NftTile extends StatelessWidget {
  final NftData data;

  const NftTile({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height * 0.4,
      child: Card(
        shape: AppTheme.cardShape,
        elevation: AppTheme.cardElevations / 2,
        child: Column(
          children: [
            Image.network(data.externalData.image),
            ListTile(
              title: Text(data.externalData.name),
              subtitle: Text(
                data.externalData.description,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }
}

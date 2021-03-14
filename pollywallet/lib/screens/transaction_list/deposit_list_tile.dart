import 'package:flutter/material.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/deposit_models/deposit_transaction_db.dart';
import 'package:pollywallet/theme_data.dart';

class DepositListStatusTile extends StatefulWidget {
  final DepositTransaction data;
  DepositListStatusTile({this.data});
  @override
  _DepositListStatusTileState createState() => _DepositListStatusTileState();
}

class _DepositListStatusTileState extends State<DepositListStatusTile> {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        Navigator.pushNamed(context, depositStatusRoute,
            arguments: widget.data);
      },
      padding: EdgeInsets.all(0),
      child: Card(
        shape: AppTheme.cardShape,
        elevation: AppTheme.cardElevations,
        child: ListTile(
          leading: widget.data.imageUrl == null
              ? FadeInImage.assetNetwork(
                  placeholder: tokenIcon,
                  image: tokenIcon,
                  width: AppTheme.tokenIconHeight,
                )
              : FadeInImage.assetNetwork(
                  placeholder: tokenIcon,
                  image: widget.data.imageUrl,
                  width: AppTheme.tokenIconHeight,
                ),
          title: Text(
            widget.data.name,
            style: AppTheme.title,
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(widget.data.amount), Text(widget.data.ticker)],
          ),
          subtitle: Text(DateTime.parse(widget.data.timeString)
              .toLocal()
              .toString()
              .split(".")[0]),
        ),
      ),
    );
  }
}

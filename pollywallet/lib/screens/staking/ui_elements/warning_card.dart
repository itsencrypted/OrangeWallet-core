import 'package:flutter/material.dart';
import 'package:pollywallet/theme_data.dart';

class WarningCard extends StatelessWidget {
  final Function onClose;
  final String warningText;
  WarningCard({this.onClose, this.warningText});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.warningCardColor,
      shape: AppTheme.cardShape,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: AppTheme.paddingHeight,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Warning',
                  style: AppTheme.titleWhite,
                ),
                IconButton(
                    icon: Icon(Icons.close),
                    color: Colors.white,
                    onPressed: onClose)
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: AppTheme.paddingHeight,
                bottom: AppTheme.paddingHeight,
                right: 10),
            child: Text(
              warningText,
              style: AppTheme.body2White,
              maxLines: 100,
            ),
          )
        ],
      ),
    );
  }
}

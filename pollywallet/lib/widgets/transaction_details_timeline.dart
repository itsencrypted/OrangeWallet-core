import 'package:flutter/material.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:timelines/timelines.dart';

class TransactionDetailsTimeline extends StatelessWidget {
  final List<String> details;
  final int doneTillIndex;
  TransactionDetailsTimeline({this.details, this.doneTillIndex});
  @override
  Widget build(BuildContext context) {
    return FixedTimeline.tileBuilder(
      mainAxisSize: MainAxisSize.min,
      theme: TimelineThemeData(
        direction: Axis.vertical,
        nodePosition: 0,
        color: AppTheme.warmgray_200,
        indicatorTheme: IndicatorThemeData(
          position: 0,
          size: 20.0,
        ),
        connectorTheme: ConnectorThemeData(
          thickness: 2.5,
        ),
      ),
      builder: TimelineTileBuilder.connected(
        connectionDirection: ConnectionDirection.before,
        itemCount: details.length,
        contentsBuilder: (_, index) {
          return Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  details[index],
                  style: AppTheme.label_xsmall,
                ),
                Text(
                  "messages: here",
                  style: AppTheme.caption_normal,
                ),
              ],
            ),
          );
        },
        indicatorBuilder: (_, index) {
          if (index <= doneTillIndex) {
            return DotIndicator(
              color: AppTheme.purple_600,
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 12.0,
              ),
            );
          } else {
            return OutlinedDotIndicator(
              borderWidth: 2.5,
            );
          }
        },
        connectorBuilder: (_, index, ___) => SolidLineConnector(
          color: index <= doneTillIndex ? AppTheme.purple_600 : null,
        ),
      ),
    );
  }
}

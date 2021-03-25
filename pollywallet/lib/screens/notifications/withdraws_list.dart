import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pollywallet/models/withdraw_models/withdraw_data_db.dart';
import 'package:pollywallet/screens/notifications/withdraw_tile.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/misc/box.dart';

class WithdrawList extends StatefulWidget {
  @override
  _WithdrawListState createState() => _WithdrawListState();
}

class _WithdrawListState extends State<WithdrawList>
    with AutomaticKeepAliveClientMixin<WithdrawList> {
  List<WithdrawDataDb> box;
  @override
  void initState() {
    BoxUtils.getWithdrawList().then((box) {
      setState(() {
        box.sort((a, b) {
          return DateTime.fromMillisecondsSinceEpoch(
                  int.parse(b.timeString) * 1000)
              .compareTo(DateTime.fromMillisecondsSinceEpoch(
                  int.parse(a.timeString) * 1000));
        });
        this.box = box;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return box == null
        ? SpinKitFadingFour(
            size: 50,
            color: AppTheme.primaryColor,
          )
        : box.length == 0
            ? Center(
                child: Text("No withdraw notifications so far."),
              )
            : RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    return WithdrawNotificationTile(
                      withdrawDataDb: box[index],
                    );
                  },
                ),
              );
  }

  @override
  bool get wantKeepAlive => true;
  Future<void> _refresh() async {
    await BoxUtils.getWithdrawList().then((box) {
      setState(() {
        box.sort((a, b) {
          return DateTime.parse(b.timeString)
              .compareTo(DateTime.parse(a.timeString));
        });
        this.box = box;
      });
    });
  }
}

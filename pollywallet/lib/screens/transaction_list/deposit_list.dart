import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pollywallet/models/deposit_models/deposit_transaction_db.dart';
import 'package:pollywallet/screens/transaction_list/deposit_list_tile.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/misc/box.dart';

class DepositStatusList extends StatefulWidget {
  @override
  _DepositStatusListState createState() => _DepositStatusListState();
}

class _DepositStatusListState extends State<DepositStatusList>
    with AutomaticKeepAliveClientMixin<DepositStatusList> {
  List<DepositTransaction> box;
  @override
  void initState() {
    BoxUtils.getDepositTransactionsList().then((box) {
      setState(() {
        box.sort((a, b) {
          return DateTime.parse(b.timeString)
              .compareTo(DateTime.parse(a.timeString));
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
        : RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, index) {
                return DepositListStatusTile(
                  data: box[index],
                );
              },
            ),
          );
  }

  @override
  bool get wantKeepAlive => true;
  Future<void> _refresh() async {
    await BoxUtils.getDepositTransactionsList().then((box) {
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

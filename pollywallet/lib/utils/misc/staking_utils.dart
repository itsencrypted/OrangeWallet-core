import 'dart:math';

class StakingUtils {
  static int toFullEpoch(int halfEpoch) {
    String currentEpoch =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    String halfEpochStr = halfEpoch.toString();
    var len = halfEpochStr.length;
    String trimmed = currentEpoch.substring(0, currentEpoch.length - len);
    return int.parse(trimmed + halfEpochStr);
  }

  static bool checkEpoch(int halfEpoch) {
    var unlockTime =
        (StakingUtils.toFullEpoch(halfEpoch.toInt()) + pow(2, 13)) * 1000;
    print(unlockTime);
    print(DateTime.now().millisecondsSinceEpoch);
    return DateTime.now().millisecondsSinceEpoch > unlockTime.toInt();
  }
}

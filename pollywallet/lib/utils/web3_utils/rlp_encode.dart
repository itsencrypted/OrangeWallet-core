import 'dart:typed_data';

import 'package:web3dart/contracts.dart';

class RlpEncode {
  static Uint8List encode(BigInt amount) {
    var baz = ContractFunction('', [
      FunctionParameter('', UintType(length: 256)),
    ]);

    var ls = baz.encodeCall([amount]);

    var rt = ls.sublist(4, ls.length);

    // String hex = HEX.encode(rt);
    // var str = "0x" + hex.substring(2);
    // print(str);
    return rt;
  }
}

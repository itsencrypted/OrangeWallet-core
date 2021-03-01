import 'dart:typed_data';

import 'package:hex/hex.dart';
import 'package:web3dart/contracts.dart';
import 'package:web3dart/crypto.dart';

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

  // static Uint8List encode1155params(BigInt id, BigInt amount, String bytes) {
  //   var baz = ContractFunction('', [
  //     FunctionParameter('', UintType(length: 256)),
  //   ]);
  //   var byteEncode = ContractFunction('', [
  //     FunctionParameter('', DynamicBytes()),
  //   ]);

  //   var ls = baz.encodeCall([amount]);
  //   var idEncode = baz.encodeCall([id]);

  //   var rt = ls.sublist(4, ls.length);
  //   var idTrimmed = ls.sublist(4, idEncode.length);
  //   var bytesEncoded = byteEncode.encodeCall([bytes]);

  //   // String hex = HEX.encode(rt);
  //   // var str = "0x" + hex.substring(2);
  //   // print(str);
  //   return rt;
  // }

  static Uint8List encodeHex(String payload) {
    // BigInt bi = hexToInt(payload);
    // var baz = ContractFunction('', [
    //   FunctionParameter('', UintType(length: 256)),
    // ]);
    // var ls = baz.encodeCall([bi]);
    var rt = hexToBytes(payload);

    // String hex = HEX.encode(rt);
    // var str = "0x" + hex.substring(2);
    // print(str);
    return rt;
  }

  static Uint8List erc1155Params(
      List<BigInt> tokenIdList, List<BigInt> amountList) {
    var baz = ContractFunction('', [
      FunctionParameter('', DynamicLengthArray(type: UintType())),
      FunctionParameter('', DynamicLengthArray(type: UintType())),
      FunctionParameter('', DynamicBytes())
    ]);
    //baz.encodeCall([1]);

    var ls = baz.encodeCall([tokenIdList, amountList, Uint8List(0)]);

    var rt = ls.sublist(4, ls.length);

    // String hex = HEX.encode(rt);
    // var str = "0x" + hex.substring(2);
    // print(str);
    return rt;
  }
}

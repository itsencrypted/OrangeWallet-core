import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:hex/hex.dart';
import 'package:web3dart/web3dart.dart';
class HDKey {
  static Future<List<String>> generateKey(String mnemonic)async {
    String seed = bip39.mnemonicToSeedHex(mnemonic);
    final root = bip32.BIP32.fromSeed(HEX.decode(seed));
    final child1 = root.derivePath("m/44'/60'/0'/0/0");
    final privateKey = HEX.encode(child1.privateKey);
    final private = EthPrivateKey.fromHex(privateKey);
    final address = await private.extractAddress();
    print(address);
    return [privateKey, address.hex];
  }
  static String generateMnemonic(){
    var mnemonic = bip39.generateMnemonic();
    return mnemonic;
  }
}
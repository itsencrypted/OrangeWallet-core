part of 'covalent_token_list_cubit_ethereum.dart';

@immutable
abstract class CovalentTokensListEthState {
  const CovalentTokensListEthState();
}

class CovalentTokensListEthInitial extends CovalentTokensListEthState {
  const CovalentTokensListEthInitial();
}

class CovalentTokensListEthLoading extends CovalentTokensListEthState {
  const CovalentTokensListEthLoading();
}

class CovalentTokensListEthLoaded extends CovalentTokensListEthState {
  final CovalentTokenList covalentTokenList;
  const CovalentTokensListEthLoaded(this.covalentTokenList);
  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is CovalentTokensListEthLoaded &&
        o.covalentTokenList.data.items.length ==
            covalentTokenList.data.items.length &&
        _checkEquality(o.covalentTokenList, covalentTokenList);
  }

  @override
  int get hashCode => covalentTokenList.hashCode;
  _checkEquality(CovalentTokenList o1, CovalentTokenList o2) {
    print("equality");
    for (int i = 0; i < o1.data.items.length; i++) {
      var element1 = o1.data.items[i];
      var ls = o2.data.items.where(
          (element2) => element1.contractAddress == element2.contractAddress);
      if (ls.isNotEmpty) {
        if (ls.first.balance != element1.balance) {
          return false;
        }
      }
    }

    return true;
  }
}

class CovalentTokensListEthError extends CovalentTokensListEthState {
  final String message;
  const CovalentTokensListEthError(this.message);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is CovalentTokensListEthError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

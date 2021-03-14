part of 'covalent_token_list_cubit_matic.dart';

@immutable
abstract class CovalentTokensListMaticState {
  const CovalentTokensListMaticState();
}

class CovalentTokensListMaticInitial extends CovalentTokensListMaticState {
  const CovalentTokensListMaticInitial();
}

class CovalentTokensListMaticLoading extends CovalentTokensListMaticState {
  const CovalentTokensListMaticLoading();
}

class CovalentTokensListMaticLoaded extends CovalentTokensListMaticState {
  final CovalentTokenList covalentTokenList;
  const CovalentTokensListMaticLoaded(this.covalentTokenList);
  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is CovalentTokensListMaticLoaded &&
        o.covalentTokenList.data.items.length ==
            covalentTokenList.data.items.length &&
        _checkEquality(o.covalentTokenList, covalentTokenList);
  }

  @override
  int get hashCode => covalentTokenList.hashCode;
  _checkEquality(CovalentTokenList o1, CovalentTokenList o2) {
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

class CovalentTokensListMaticError extends CovalentTokensListMaticState {
  final String message;
  const CovalentTokensListMaticError(this.message);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is CovalentTokensListMaticError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

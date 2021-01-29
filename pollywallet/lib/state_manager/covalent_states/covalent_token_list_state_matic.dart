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
        o.covalentTokenList.data.items[0].quote ==
            covalentTokenList.data.items[0].quote;
  }

  @override
  int get hashCode => covalentTokenList.hashCode;
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

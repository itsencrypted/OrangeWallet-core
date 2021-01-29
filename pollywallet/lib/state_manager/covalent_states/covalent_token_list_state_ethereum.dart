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
        o.covalentTokenList.data.items[0].quote ==
            covalentTokenList.data.items[0].quote;
  }

  @override
  int get hashCode => covalentTokenList.hashCode;
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

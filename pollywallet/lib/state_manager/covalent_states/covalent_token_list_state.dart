part of 'covalent_token_list_cubit.dart';

@immutable
abstract class CovalentTokensListState {
  const CovalentTokensListState();
}

class CovalentTokensListInitial extends CovalentTokensListState {
  const CovalentTokensListInitial();
}

class CovalentTokensListLoading extends CovalentTokensListState {
  const CovalentTokensListLoading();
}

class CovalentTokensListLoaded extends CovalentTokensListState {
  final CovalentTokenList covalentTokenList;
  const CovalentTokensListLoaded(this.covalentTokenList);
  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is CovalentTokensListLoaded &&
        o.covalentTokenList.data.items[0].quote ==
            covalentTokenList.data.items[0].quote;
  }

  @override
  int get hashCode => covalentTokenList.hashCode;
}

class CovalentTokensListError extends CovalentTokensListState {
  final String message;
  const CovalentTokensListError(this.message);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is CovalentTokensListError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

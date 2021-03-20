part of 'validator_data_cubit.dart';

abstract class ValidatorsDataState {
  const ValidatorsDataState();
}

class ValidatorsDataStateInitial extends ValidatorsDataState {
  const ValidatorsDataStateInitial();
}

class ValidatorsDataStateLoading extends ValidatorsDataState {
  const ValidatorsDataStateLoading();
}

class ValidatorsDataStateFinal extends ValidatorsDataState {
  final Validators data;
  final BigInt rewards;
  const ValidatorsDataStateFinal({this.data, this.rewards});
  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ValidatorsDataStateFinal &&
        o.data.result.length == data.result.length &&
        o.rewards == rewards &&
        _checkEquality(o, this);
  }

  @override
  int get hashCode => data.hashCode;
  _checkEquality(ValidatorsDataStateFinal o1, ValidatorsDataStateFinal o2) {
    for (int i = 0; i < o1.data.result.length; i++) {
      var element1 = o1.data.result[i];
      var ls = o2.data.result.where(
          (element2) => element1.contractAddress == element2.contractAddress);
      if (ls.isNotEmpty) {
        if (ls.first.updatedAt != element1.updatedAt) {
          return false;
        }
      }
    }

    return true;
  }
}

class ValidatorsDataStateError extends ValidatorsDataState {
  final String message;
  const ValidatorsDataStateError(this.message);
  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ValidatorsDataStateError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

part of 'validator_data_cubit.dart';

abstract class ValidatorsDataState {
  const ValidatorsDataState();
}

class ValidatorsDataStateInitial extends ValidatorsDataState {
  const ValidatorsDataStateInitial();
}

class ValidatorsDataStateFinal extends ValidatorsDataState {
  final Validators data;

  const ValidatorsDataStateFinal(this.data);
  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ValidatorsDataStateFinal && o.data == data;
  }

  @override
  int get hashCode => data.hashCode;
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

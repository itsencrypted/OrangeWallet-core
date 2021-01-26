part of 'deposit_data_cubit.dart';

abstract class DepositDataState {
  const DepositDataState();
}

class DepositDataInitial extends DepositDataState {
  const DepositDataInitial();
}

class DepositDataFinal extends DepositDataState {
  final DepositModel data;
  const DepositDataFinal(this.data);
  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is DepositDataFinal && o.data == data;
  }

  @override
  int get hashCode => data.hashCode;
}

class DepositDataError extends DepositDataState {
  final String message;
  const DepositDataError(this.message);
  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is DepositDataError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

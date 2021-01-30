part of 'withdraw_burn_data_cubit.dart';

abstract class WithdrawBurnDataState {
  const WithdrawBurnDataState();
}

class WithdrawBurnDataInitial extends WithdrawBurnDataState {
  const WithdrawBurnDataInitial();
}

class WithdrawBurnDataFinal extends WithdrawBurnDataState {
  final WithdrawBurnDataModel data;
  const WithdrawBurnDataFinal(this.data);
  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is WithdrawBurnDataFinal && o.data == data;
  }

  @override
  int get hashCode => data.hashCode;
}

class WithdrawBurnDataError extends WithdrawBurnDataState {
  final String message;
  const WithdrawBurnDataError(this.message);
  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is WithdrawBurnDataError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

import 'package:bloc/bloc.dart';
import 'package:orangewallet/models/withdraw_models/withdraw_burn_data.dart';

part 'withdraw_burn_data_state.dart';

class WithdrawBurnDataCubit extends Cubit<WithdrawBurnDataState> {
  WithdrawBurnDataCubit() : super(WithdrawBurnDataInitial());
  void setData(WithdrawBurnDataModel data) {
    emit(WithdrawBurnDataFinal(data));
    if (data == null) {
      emit(WithdrawBurnDataError("Something went wrong"));
    }
  }
}

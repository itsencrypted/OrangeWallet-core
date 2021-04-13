import 'package:bloc/bloc.dart';
import 'package:orangewallet/models/deposit_models/deposit_model.dart';

part 'deposit_data_state.dart';

class DepositDataCubit extends Cubit<DepositDataState> {
  DepositDataCubit() : super(DepositDataInitial());
  void setData(DepositModel data) {
    emit(DepositDataFinal(data));
    if (data == null) {
      emit(DepositDataError("Something went wrong"));
    }
  }
}

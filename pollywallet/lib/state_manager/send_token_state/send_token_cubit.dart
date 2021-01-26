import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pollywallet/models/send_token_model/send_token_data.dart';

part 'send_token_state.dart';

class SendTransactionCubit extends Cubit<SendTransactionState> {
  SendTransactionCubit() : super(SendTransactionInitial());
  void setData(SendTokenData data) {
    emit(SendTransactionFinal(data));
    if (data == null) {
      emit(SendTransactionError("Something went wrong"));
    }
  }
}

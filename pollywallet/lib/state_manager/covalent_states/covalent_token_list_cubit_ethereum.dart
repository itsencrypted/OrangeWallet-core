import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pollywallet/models/covalent_models/covalent_token_list.dart';
import 'package:pollywallet/utils/api_wrapper/covalent_api_wrapper.dart';

part 'covalent_token_list_state_ethereum.dart';

class CovalentTokensListEthCubit extends Cubit<CovalentTokensListEthState> {
  CovalentTokensListEthCubit() : super(CovalentTokensListEthInitial());
  Future<void> getTokensList() async {
    try {
      emit(CovalentTokensListEthLoading());
      final list = await CovalentApiWrapper.tokenEthList();

      emit(CovalentTokensListEthLoaded(list));
    } on Exception {
      emit(CovalentTokensListEthError("Something Went wrong"));
    }
  }

  Future<void> refresh() async {
    try {
      final list = await CovalentApiWrapper.tokenEthList();
      emit(CovalentTokensListEthLoading());

      emit(CovalentTokensListEthLoaded(list));
    } on Exception {
      emit(CovalentTokensListEthError("Something Went wrong"));
    }
  }
}

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pollywallet/models/covalent_models/covalent_token_list.dart';
import 'package:pollywallet/utils/api_wrapper/covalent_api_wrapper.dart';

part 'covalent_token_list_state.dart';

class CovalentTokensListCubit extends Cubit<CovalentTokensListState> {
  CovalentTokensListCubit() : super(CovalentTokensListInitial());
  Future<void> getTokensList(int id) async {
    // 0 - matic
    // 1 - ethereum
    if (id == 0) {
      try {
        emit(CovalentTokensListLoading());
        final list = await CovalentApiWrapper.tokensMaticList();
        emit(CovalentTokensListLoaded(list));
      } on Exception {
        emit(CovalentTokensListError("Something Went wrong"));
      }
    } else {
      try {
        emit(CovalentTokensListLoading());
        final list = await CovalentApiWrapper.tokenEthList();
        emit(CovalentTokensListLoaded(list));
      } on Exception {
        emit(CovalentTokensListError("Something Went wrong"));
      }
    }
  }
}

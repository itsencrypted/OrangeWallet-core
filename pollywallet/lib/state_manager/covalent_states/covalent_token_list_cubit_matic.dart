import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pollywallet/models/covalent_models/covalent_token_list.dart';
import 'package:pollywallet/utils/api_wrapper/covalent_api_wrapper.dart';

part 'covalent_token_list_state_matic.dart';

class CovalentTokensListMaticCubit extends Cubit<CovalentTokensListMaticState> {
  CovalentTokensListMaticCubit() : super(CovalentTokensListMaticInitial());
  Future<void> getTokensList() async {
    try {
      emit(CovalentTokensListMaticLoading());
      final list = await CovalentApiWrapper.tokensMaticList();
      list.data.items.removeWhere(
          (element) => element.type == "nft" && element.balance == "0");
      emit(CovalentTokensListMaticLoaded(list));
    } catch (e) {
      print(e.toString());
      emit(CovalentTokensListMaticError("Something Went wrong"));
    }
  }

  Future<void> refresh() async {
    try {
      final list = await CovalentApiWrapper.tokensMaticList();
      list.data.items.removeWhere(
          (element) => element.type == "nft" && element.balance == "0");
      emit(CovalentTokensListMaticLoading());
      emit(CovalentTokensListMaticLoaded(list));
    } on Exception {
      emit(CovalentTokensListMaticError("Something Went wrong"));
    }
  }
}

import 'package:bloc/bloc.dart';
import 'package:pollywallet/models/staking_models/delegator_details.dart';
import 'package:pollywallet/models/staking_models/delegators.dart';
import 'package:pollywallet/models/staking_models/validators.dart';
import 'package:pollywallet/models/withdraw_models/withdraw_burn_data.dart';
import 'package:pollywallet/utils/api_wrapper/staking_api.dart';
import 'package:pollywallet/utils/misc/credential_manager.dart';

part 'validator_data_state.dart';

class ValidatorsdataCubit extends Cubit<ValidatorsDataState> {
  ValidatorsdataCubit() : super(ValidatorsDataStateInitial());
  void setData() async {
    try {
      Validators info = await StakingApiWrapper.validatorsList();
      emit(ValidatorsDataStateFinal(info));
    } catch (e) {
      print(e.toString());
      emit(ValidatorsDataStateError(e.toString()));
    }
  }
}

import 'package:bloc/bloc.dart';
import 'package:pollywallet/models/staking_models/validators.dart';
import 'package:pollywallet/utils/api_wrapper/staking_api.dart';
import 'package:pollywallet/utils/web3_utils/ethereum_transactions.dart';
import 'package:pollywallet/utils/web3_utils/staking_transactions.dart';

part 'validator_data_state.dart';

class ValidatorsdataCubit extends Cubit<ValidatorsDataState> {
  ValidatorsdataCubit() : super(ValidatorsDataStateInitial());
  void setData() async {
    try {
      emit(ValidatorsDataStateLoading());
      Validators info = await StakingApiWrapper.validatorsList();
      BigInt rewards = BigInt.zero;
      List<Future> rewardsFuture = <Future>[];
      for (int i = 0; i < info.result.length; i++) {
        rewardsFuture.add(StakingTransactions.getStakingReward(
            info.result[i].contractAddress));
      }
      for (int i = 0; i < rewardsFuture.length; i++) {
        info.result[i].reward = await rewardsFuture[i];
        rewards += info.result[i].reward;
      }
      emit(ValidatorsDataStateFinal(data: info, rewards: rewards));
    } catch (e) {
      print(e.toString());
      emit(ValidatorsDataStateError(e.toString()));
    }
  }

  refresh() async {
    try {
      Validators info = await StakingApiWrapper.validatorsList();
      BigInt rewards = BigInt.zero;
      List<Future> rewardsFuture = <Future>[];
      for (int i = 0; i < info.result.length; i++) {
        rewardsFuture.add(StakingTransactions.getStakingReward(
            info.result[i].contractAddress));
      }
      for (int i = 0; i < rewardsFuture.length; i++) {
        info.result[i].reward = await rewardsFuture[i];
        rewards += info.result[i].reward;
      }
      emit(ValidatorsDataStateFinal(data: info, rewards: rewards));
    } catch (e) {
      print(e.toString());
      emit(ValidatorsDataStateError(e.toString()));
    }
  }
}

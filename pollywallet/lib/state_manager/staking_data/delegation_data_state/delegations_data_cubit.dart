import 'package:bloc/bloc.dart';
import 'package:pollywallet/models/staking_models/delegator_details.dart';
import 'package:pollywallet/utils/api_wrapper/staking_api.dart';
import 'package:pollywallet/utils/misc/credential_manager.dart';

part 'delegations_data_state.dart';

class DelegationsDataCubit extends Cubit<DelegationsDataState> {
  DelegationsDataCubit() : super(DelegationsDataStateInitial());
  void setData() async {
    try {
      emit(DelegationsDataStateLoading());
      String address = await CredentialManager.getAddress();
      DelegationsPerAddress info =
          await StakingApiWrapper.delegationDetails(address);
      BigInt totalStake = BigInt.zero;
      BigInt totalShares = BigInt.zero;
      BigInt claimedRewards = BigInt.zero;
      info.result.forEach((element) {
        totalStake = totalStake + element.stake;
        totalShares = totalShares + element.shares;
        claimedRewards = claimedRewards + element.claimedReward;
      });
      BigInt rewards = totalShares - totalStake - claimedRewards;
      emit(DelegationsDataStateFinal(
          info, totalShares, totalStake, rewards, claimedRewards));
    } catch (e) {
      print(e.toString());
      emit(DelegationsDataStateError(e.toString()));
    }
  }

  refresh() async {
    try {
      String address = await CredentialManager.getAddress();
      DelegationsPerAddress info =
          await StakingApiWrapper.delegationDetails(address);
      BigInt totalStake = BigInt.zero;
      BigInt totalShares = BigInt.zero;
      BigInt claimedRewards = BigInt.zero;
      info.result.forEach((element) {
        totalStake = totalStake + element.stake;
        totalShares = totalShares + element.shares;
        claimedRewards = claimedRewards + element.claimedReward;
      });
      BigInt rewards = totalShares - totalStake - claimedRewards;
      emit(DelegationsDataStateFinal(
          info, totalShares, totalStake, rewards, claimedRewards));
    } catch (e) {
      print(e.toString());
      emit(DelegationsDataStateError(e.toString()));
    }
  }
}

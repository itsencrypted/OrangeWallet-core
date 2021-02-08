part of 'delegations_data_cubit.dart';

abstract class DelegationsDataState {
  const DelegationsDataState();
}

class DelegationsDataStateInitial extends DelegationsDataState {
  const DelegationsDataStateInitial();
}

class DelegationsDataStateLoading extends DelegationsDataState {
  const DelegationsDataStateLoading();
}

class DelegationsDataStateFinal extends DelegationsDataState {
  final DelegationsPerAddress data;
  final BigInt stake;
  final BigInt rewards;
  final BigInt claimedRewards;
  final BigInt shares;
  const DelegationsDataStateFinal(
      this.data, this.shares, this.stake, this.rewards, this.claimedRewards);
  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is DelegationsDataStateFinal && o.data == data;
  }

  @override
  int get hashCode => data.hashCode;
}

class DelegationsDataStateError extends DelegationsDataState {
  final String message;
  const DelegationsDataStateError(this.message);
  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is DelegationsDataStateError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

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

    return o is DelegationsDataStateFinal &&
        o.data.result.length == data.result.length &&
        _checkEquality(o, this);
  }

  @override
  int get hashCode => data.hashCode;
  _checkEquality(DelegationsDataStateFinal o1, DelegationsDataStateFinal o2) {
    for (int i = 0; i < o1.data.result.length; i++) {
      var element1 = o1.data.result[i];
      var ls = o2.data.result
          .where((element2) => element1.address == element2.address);
      if (ls.isNotEmpty) {
        if (ls.first.shares != element1.shares ||
            ls.first.stake != element1.stake) {
          return false;
        }
      }
    }

    return true;
  }
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

part of 'send_token_cubit.dart';

@immutable
abstract class SendTransactionState {
  const SendTransactionState();
}

class SendTransactionInitial extends SendTransactionState {
  const SendTransactionInitial();
}

class SendTransactionFinal extends SendTransactionState {
  final SendTokenData data;
  const SendTransactionFinal(this.data);
  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
   
    return o is SendTransactionFinal &&
        (o.data.token == null ? 0 : o.data.token.balance) ==
            (data.token == null ? 0 : data.token.balance) &&
        data.amount == o.data.amount;
  }

  @override
  int get hashCode => data.hashCode;
}

class SendTransactionError extends SendTransactionState {
  final String message;
  const SendTransactionError(this.message);
  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is SendTransactionError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

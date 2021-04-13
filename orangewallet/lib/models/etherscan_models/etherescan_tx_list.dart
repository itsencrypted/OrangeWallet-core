class EtherScanTxList {
  String status;
  String message;
  List<Result> result;

  EtherScanTxList({this.status, this.message, this.result});

  EtherScanTxList.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['result'] != null) {
      result = new List<Result>();
      json['result'].forEach((v) {
        result.add(new Result.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.result != null) {
      data['result'] = this.result.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Result {
  String blockNumber;
  String blockHash;
  String timeStamp;
  String hash;
  String nonce;
  String transactionIndex;
  String from;
  String to;
  String value;
  String gas;
  String gasPrice;
  String input;
  String contractAddress;
  String cumulativeGasUsed;
  String txreceiptStatus;
  String gasUsed;
  String confirmations;
  String isError;

  Result(
      {this.blockNumber,
      this.blockHash,
      this.timeStamp,
      this.hash,
      this.nonce,
      this.transactionIndex,
      this.from,
      this.to,
      this.value,
      this.gas,
      this.gasPrice,
      this.input,
      this.contractAddress,
      this.cumulativeGasUsed,
      this.txreceiptStatus,
      this.gasUsed,
      this.confirmations,
      this.isError});

  Result.fromJson(Map<String, dynamic> json) {
    blockNumber = json['blockNumber'];
    blockHash = json['blockHash'];
    timeStamp = json['timeStamp'];
    hash = json['hash'];
    nonce = json['nonce'];
    transactionIndex = json['transactionIndex'];
    from = json['from'];
    to = json['to'];
    value = json['value'];
    gas = json['gas'];
    gasPrice = json['gasPrice'];
    input = json['input'];
    contractAddress = json['contractAddress'];
    cumulativeGasUsed = json['cumulativeGasUsed'];
    txreceiptStatus = json['txreceipt_status'];
    gasUsed = json['gasUsed'];
    confirmations = json['confirmations'];
    isError = json['isError'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['blockNumber'] = this.blockNumber;
    data['blockHash'] = this.blockHash;
    data['timeStamp'] = this.timeStamp;
    data['hash'] = this.hash;
    data['nonce'] = this.nonce;
    data['transactionIndex'] = this.transactionIndex;
    data['from'] = this.from;
    data['to'] = this.to;
    data['value'] = this.value;
    data['gas'] = this.gas;
    data['gasPrice'] = this.gasPrice;
    data['input'] = this.input;
    data['contractAddress'] = this.contractAddress;
    data['cumulativeGasUsed'] = this.cumulativeGasUsed;
    data['txreceipt_status'] = this.txreceiptStatus;
    data['gasUsed'] = this.gasUsed;
    data['confirmations'] = this.confirmations;
    data['isError'] = this.isError;
    return data;
  }
}

class MaticTransactionListModel {
  Data data;

  MaticTransactionListModel({this.data});

  MaticTransactionListModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class Data {
  String address;
  String updatedAt;
  String nextUpdateAt;
  String quoteCurrency;
  int chainId;
  List<TransactionItem> items;

  Data(
      {this.address,
      this.updatedAt,
      this.nextUpdateAt,
      this.quoteCurrency,
      this.chainId,
      this.items});

  Data.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    updatedAt = json['updated_at'];
    nextUpdateAt = json['next_update_at'];
    quoteCurrency = json['quote_currency'];
    chainId = json['chain_id'];
    if (json['items'] != null) {
      items = new List<TransactionItem>();
      json['items'].forEach((v) {
        items.add(new TransactionItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['updated_at'] = this.updatedAt;
    data['next_update_at'] = this.nextUpdateAt;
    data['quote_currency'] = this.quoteCurrency;
    data['chain_id'] = this.chainId;
    if (this.items != null) {
      data['items'] = this.items.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TransactionItem {
  String blockSignedAt;
  String txHash;
  int txOffset;
  bool successful;
  String fromAddress;
  String fromAddressLabel;
  String toAddress;
  String toAddressLabel;
  String value;
  double valueQuote;
  int gasOffered;
  int gasSpent;
  int gasPrice;
  double gasQuote;
  double gasQuoteRate;
  List<LogEvents> logEvents;

  TransactionItem(
      {this.blockSignedAt,
      this.txHash,
      this.txOffset,
      this.successful,
      this.fromAddress,
      this.fromAddressLabel,
      this.toAddress,
      this.toAddressLabel,
      this.value,
      this.valueQuote,
      this.gasOffered,
      this.gasSpent,
      this.gasPrice,
      this.gasQuote,
      this.gasQuoteRate,
      this.logEvents});

  TransactionItem.fromJson(Map<String, dynamic> json) {
    blockSignedAt = json['block_signed_at'];
    txHash = json['tx_hash'];
    txOffset = json['tx_offset'];
    successful = json['successful'];
    fromAddress = json['from_address'];
    fromAddressLabel = json['from_address_label'];
    toAddress = json['to_address'];
    toAddressLabel = json['to_address_label'];
    value = json['value'];
    valueQuote = json['value_quote'];
    gasOffered = json['gas_offered'];
    gasSpent = json['gas_spent'];
    gasPrice = json['gas_price'];
    gasQuote = json['gas_quote'];
    gasQuoteRate = json['gas_quote_rate'];
    if (json['log_events'] != null) {
      logEvents = new List<LogEvents>();
      json['log_events'].forEach((v) {
        logEvents.add(new LogEvents.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['block_signed_at'] = this.blockSignedAt;
    data['tx_hash'] = this.txHash;
    data['tx_offset'] = this.txOffset;
    data['successful'] = this.successful;
    data['from_address'] = this.fromAddress;
    data['from_address_label'] = this.fromAddressLabel;
    data['to_address'] = this.toAddress;
    data['to_address_label'] = this.toAddressLabel;
    data['value'] = this.value;
    data['value_quote'] = this.valueQuote;
    data['gas_offered'] = this.gasOffered;
    data['gas_spent'] = this.gasSpent;
    data['gas_price'] = this.gasPrice;
    data['gas_quote'] = this.gasQuote;
    data['gas_quote_rate'] = this.gasQuoteRate;
    if (this.logEvents != null) {
      data['log_events'] = this.logEvents.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LogEvents {
  String blockSignedAt;
  int blockHeight;
  int txOffset;
  int logOffset;
  String txHash;
  List<String> rawLogTopics;

  LogEvents(
      {this.blockSignedAt,
      this.blockHeight,
      this.txOffset,
      this.logOffset,
      this.txHash,
      this.rawLogTopics});

  LogEvents.fromJson(Map<String, dynamic> json) {
    blockSignedAt = json['block_signed_at'];
    blockHeight = json['block_height'];
    txOffset = json['tx_offset'];
    logOffset = json['log_offset'];
    txHash = json['tx_hash'];
    rawLogTopics = json['raw_log_topics'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['block_signed_at'] = this.blockSignedAt;
    data['block_height'] = this.blockHeight;
    data['tx_offset'] = this.txOffset;
    data['log_offset'] = this.logOffset;
    data['tx_hash'] = this.txHash;
    data['raw_log_topics'] = this.rawLogTopics;
    return data;
  }
}

class TokenHistory {
  Data data;
  bool error;
  Null errorMessage;
  Null errorCode;

  TokenHistory({this.data, this.error, this.errorMessage, this.errorCode});

  TokenHistory.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    error = json['error'];
    errorMessage = json['error_message'];
    errorCode = json['error_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    data['error'] = this.error;
    data['error_message'] = this.errorMessage;
    data['error_code'] = this.errorCode;
    return data;
  }
}

class Data {
  String address;
  String updatedAt;
  String nextUpdateAt;
  String quoteCurrency;
  int chainId;
  List<TransferInfo> transferInfo;
  Pagination pagination;

  Data(
      {this.address,
      this.updatedAt,
      this.nextUpdateAt,
      this.quoteCurrency,
      this.chainId,
      this.transferInfo,
      this.pagination});

  Data.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    updatedAt = json['updated_at'];
    nextUpdateAt = json['next_update_at'];
    quoteCurrency = json['quote_currency'];
    chainId = json['chain_id'];
    if (json['items'] != null) {
      transferInfo = new List<TransferInfo>();
      json['items'].forEach((v) {
        transferInfo.add(new TransferInfo.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['updated_at'] = this.updatedAt;
    data['next_update_at'] = this.nextUpdateAt;
    data['quote_currency'] = this.quoteCurrency;
    data['chain_id'] = this.chainId;
    if (this.transferInfo != null) {
      data['items'] = this.transferInfo.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination.toJson();
    }
    return data;
  }
}

class TransferInfo {
  String blockSignedAt;
  String txHash;
  int txOffset;
  bool successful;
  String fromAddress;
  Null fromAddressLabel;
  String toAddress;
  Null toAddressLabel;
  String value;
  Null valueQuote;
  int gasOffered;
  int gasSpent;
  int gasPrice;
  double gasQuote;
  double gasQuoteRate;
  List<Transfers> transfers;

  TransferInfo(
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
      this.transfers});

  TransferInfo.fromJson(Map<String, dynamic> json) {
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
    if (json['transfers'] != null) {
      transfers = new List<Transfers>();
      json['transfers'].forEach((v) {
        transfers.add(new Transfers.fromJson(v));
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
    if (this.transfers != null) {
      data['transfers'] = this.transfers.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Transfers {
  String blockSignedAt;
  String txHash;
  String fromAddress;
  Null fromAddressLabel;
  String toAddress;
  Null toAddressLabel;
  int contractDecimals;
  String contractName;
  String contractTickerSymbol;
  String contractAddress;
  String logoUrl;
  String transferType;
  String delta;
  Null balance;
  Null quoteRate;
  Null deltaQuote;
  Null balanceQuote;

  Transfers(
      {this.blockSignedAt,
      this.txHash,
      this.fromAddress,
      this.fromAddressLabel,
      this.toAddress,
      this.toAddressLabel,
      this.contractDecimals,
      this.contractName,
      this.contractTickerSymbol,
      this.contractAddress,
      this.logoUrl,
      this.transferType,
      this.delta,
      this.balance,
      this.quoteRate,
      this.deltaQuote,
      this.balanceQuote});

  Transfers.fromJson(Map<String, dynamic> json) {
    blockSignedAt = json['block_signed_at'];
    txHash = json['tx_hash'];
    fromAddress = json['from_address'];
    fromAddressLabel = json['from_address_label'];
    toAddress = json['to_address'];
    toAddressLabel = json['to_address_label'];
    contractDecimals = json['contract_decimals'];
    contractName = json['contract_name'];
    contractTickerSymbol = json['contract_ticker_symbol'];
    contractAddress = json['contract_address'];
    logoUrl = json['logo_url'];
    transferType = json['transfer_type'];
    delta = json['delta'];
    balance = json['balance'];
    quoteRate = json['quote_rate'];
    deltaQuote = json['delta_quote'];
    balanceQuote = json['balance_quote'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['block_signed_at'] = this.blockSignedAt;
    data['tx_hash'] = this.txHash;
    data['from_address'] = this.fromAddress;
    data['from_address_label'] = this.fromAddressLabel;
    data['to_address'] = this.toAddress;
    data['to_address_label'] = this.toAddressLabel;
    data['contract_decimals'] = this.contractDecimals;
    data['contract_name'] = this.contractName;
    data['contract_ticker_symbol'] = this.contractTickerSymbol;
    data['contract_address'] = this.contractAddress;
    data['logo_url'] = this.logoUrl;
    data['transfer_type'] = this.transferType;
    data['delta'] = this.delta;
    data['balance'] = this.balance;
    data['quote_rate'] = this.quoteRate;
    data['delta_quote'] = this.deltaQuote;
    data['balance_quote'] = this.balanceQuote;
    return data;
  }
}

class Pagination {
  bool hasMore;
  int pageNumber;
  int pageSize;
  int totalCount;

  Pagination({this.hasMore, this.pageNumber, this.pageSize, this.totalCount});

  Pagination.fromJson(Map<String, dynamic> json) {
    hasMore = json['has_more'];
    pageNumber = json['page_number'];
    pageSize = json['page_size'];
    totalCount = json['total_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['has_more'] = this.hasMore;
    data['page_number'] = this.pageNumber;
    data['page_size'] = this.pageSize;
    data['total_count'] = this.totalCount;
    return data;
  }
}

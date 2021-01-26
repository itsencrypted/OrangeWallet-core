class CovalentTokenList {
  Data data;
  bool error;
  Null errorMessage;
  Null errorCode;

  CovalentTokenList({this.data, this.error, this.errorMessage, this.errorCode});

  CovalentTokenList.fromJson(Map<String, dynamic> json) {
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
  List<Items> items;
  Null pagination;

  Data(
      {this.address,
        this.updatedAt,
        this.nextUpdateAt,
        this.quoteCurrency,
        this.chainId,
        this.items,
        this.pagination});

  Data.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    updatedAt = json['updated_at'];
    nextUpdateAt = json['next_update_at'];
    quoteCurrency = json['quote_currency'];
    chainId = json['chain_id'];
    if (json['items'] != null) {
      items = new List<Items>();
      json['items'].forEach((v) {
        items.add(new Items.fromJson(v));
      });
    }
    pagination = json['pagination'];
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
    data['pagination'] = this.pagination;
    return data;
  }
}

class Items {
  int contractDecimals;
  String contractName;
  String contractTickerSymbol;
  String contractAddress;
  String logoUrl;
  String type;
  String balance;
  double quoteRate;
  double quote;
  Null nftData;

  Items(
      {this.contractDecimals,
        this.contractName,
        this.contractTickerSymbol,
        this.contractAddress,
        this.logoUrl,
        this.type,
        this.balance,
        this.quoteRate,
        this.quote,
        this.nftData});

  Items.fromJson(Map<String, dynamic> json) {
    contractDecimals = json['contract_decimals'];
    contractName = json['contract_name'];
    contractTickerSymbol = json['contract_ticker_symbol'];
    contractAddress = json['contract_address'];
    logoUrl = json['logo_url'];
    type = json['type'];
    balance = json['balance'];
    quoteRate = json['quote_rate'];
    quote = json['quote'];
    nftData = json['nft_data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['contract_decimals'] = this.contractDecimals;
    data['contract_name'] = this.contractName;
    data['contract_ticker_symbol'] = this.contractTickerSymbol;
    data['contract_address'] = this.contractAddress;
    data['logo_url'] = this.logoUrl;
    data['type'] = this.type;
    data['balance'] = this.balance;
    data['quote_rate'] = this.quoteRate;
    data['quote'] = this.quote;
    data['nft_data'] = this.nftData;
    return data;
  }
}
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:orangewallet/constants.dart';

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
  List<NftData> nftData;

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
    contractDecimals =
        json['contract_decimals'] == null ? 1 : json['contract_decimals'];
    contractName =
        json['contract_name'] == null ? "N/A" : json['contract_name'];
    contractTickerSymbol = json['contract_ticker_symbol'] == null
        ? "NA"
        : json['contract_ticker_symbol'];
    contractAddress = json['contract_address'];

    logoUrl = json['logo_url'] != null ? json['logo_url'] : tokenIconUrl;
    type = json['type'];
    balance = json['balance'];
    quoteRate = json['quote_rate'] != null ? json['quote_rate'] : 0.0;
    quote = json['quote'];
    if (json['nft_data'] != null) {
      nftData = new List<NftData>();
      json['nft_data'].forEach((v) {
        nftData.add(new NftData.fromJson(v, contractName));
      });
    }
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
    if (this.nftData != null) {
      data['nft_data'] = this.nftData.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NftData {
  String tokenId;
  String tokenBalance;
  String tokenUrl;
  List<String> supportsErc;
  BigInt tokenPriceWei;
  double tokenQuoteRateEth;
  ExternalData externalData;
  String owner;
  NftData(
      {this.tokenId,
      this.tokenBalance,
      this.tokenUrl,
      this.supportsErc,
      this.tokenPriceWei,
      this.tokenQuoteRateEth,
      this.externalData,
      this.owner});

  NftData.fromJson(Map<String, dynamic> json, String name) {
    tokenId = json['token_id'].toString();
    tokenBalance = json['token_balance'];
    tokenUrl = json['token_url'].toString();
    if (json['external_data'] == null) {
      try {
        _getExternalData(json['token_url'], name).then((data) {
          externalData = data;
        });
      } catch (e) {
        externalData = null;
      }
    } else {
      externalData = json['external_data'] != null
          ? new ExternalData.fromJson(json['external_data'])
          : ExternalData(
              name: name,
              image:
                  "https://media.giphy.com/media/3o6ZtrFrmbFtt0Jvs4/giphy.gif",
              description: "");
    }

    owner = json['owner'].toString();
    supportsErc = json['supports_erc'].cast<String>();
    tokenPriceWei = BigInt.tryParse(json['token_price_wei'].toString());
    tokenQuoteRateEth =
        double.tryParse(json['token_quote_rate_eth'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token_id'] = this.tokenId;
    data['token_balance'] = this.tokenBalance;
    data['token_url'] = this.tokenUrl;
    if (this.externalData != null) {
      data['external_data'] = this.externalData.toJson();
    }
    data['owner'] = this.owner;
    return data;
  }

  Future<ExternalData> _getExternalData(String url, String name) async {
    if (url == null || url == "") {
      return ExternalData(
          name: name,
          image: "https://media.giphy.com/media/3o6ZtrFrmbFtt0Jvs4/giphy.gif",
          description: "");
    }
    try {
      var resp = await http.get(url);
      Map json = jsonDecode(resp.body);
      var list = json.keys.toList();
      RegExp imageRegex = RegExp(
        r".*image.*",
        caseSensitive: false,
        multiLine: false,
      );
      RegExp descriptionRegex = RegExp(
        r".*description.*",
        caseSensitive: false,
        multiLine: false,
      );
      RegExp nameRegex = RegExp(
        r".*name.*",
        caseSensitive: false,
        multiLine: false,
      );
      var nameKey = list.where((element) => nameRegex.hasMatch(element)).first;
      var descriptionKey =
          list.where((element) => descriptionRegex.hasMatch(element)).first;
      var imageKey =
          list.where((element) => imageRegex.hasMatch(element)).first;
      bool _validURL = Uri.parse(json[imageKey]).isAbsolute;
      if (_validURL) {
        return ExternalData(
            name: json[nameKey],
            description: json[descriptionKey],
            image: json[imageKey]);
      } else {
        if (name == null) {
          return ExternalData(
              name: "Name Missing",
              image:
                  "https://media.giphy.com/media/3o6ZtrFrmbFtt0Jvs4/giphy.gif",
              description: "");
        } else {
          return ExternalData(
              name: name,
              image:
                  "https://media.giphy.com/media/3o6ZtrFrmbFtt0Jvs4/giphy.gif",
              description: "");
        }
      }
    } catch (e) {
      if (name == null) {
        return ExternalData(
            name: "Name Missing",
            image: "https://media.giphy.com/media/3o6ZtrFrmbFtt0Jvs4/giphy.gif",
            description: "");
      } else {
        return ExternalData(
            name: name,
            image: "https://media.giphy.com/media/3o6ZtrFrmbFtt0Jvs4/giphy.gif",
            description: "");
      }
    }
  }
}

class ExternalData {
  String name;
  String description;
  String image;
  String externalUrl;
  List<Attributes> attributes;

  ExternalData(
      {this.name,
      this.description,
      this.image,
      this.externalUrl,
      this.attributes});

  ExternalData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    description = json['description'];
    image = json['image'];
    externalUrl = json['external_url'];
    if (json['attributes'] != null) {
      attributes = new List<Attributes>();
      json['attributes'].forEach((v) {
        attributes.add(new Attributes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['description'] = this.description;
    data['image'] = this.image;
    data['external_url'] = this.externalUrl;
    if (this.attributes != null) {
      data['attributes'] = this.attributes.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Attributes {
  String traitType;
  String value;
  String displayType;

  Attributes({this.traitType, this.value, this.displayType});

  Attributes.fromJson(Map<String, dynamic> json) {
    traitType = json['trait_type'];
    value = json['value'].toString();
    displayType = json['display_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['trait_type'] = this.traitType;
    data['value'] = this.value;
    data['display_type'] = this.displayType;
    return data;
  }
}

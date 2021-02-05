class MaticStakingRatio {
  Result result;
  String status;

  MaticStakingRatio({this.result, this.status});

  MaticStakingRatio.fromJson(Map<String, dynamic> json) {
    result =
        json['result'] != null ? new Result.fromJson(json['result']) : null;
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.result != null) {
      data['result'] = this.result.toJson();
    }
    data['status'] = this.status;
    return data;
  }
}

class Result {
  Network network;
  Network matic;
  String maticStakingRatio;
  List<String> maticValidatorList;

  Result(
      {this.network,
      this.matic,
      this.maticStakingRatio,
      this.maticValidatorList});

  Result.fromJson(Map<String, dynamic> json) {
    network =
        json['network'] != null ? new Network.fromJson(json['network']) : null;
    matic = json['matic'] != null ? new Network.fromJson(json['matic']) : null;
    maticStakingRatio = json['maticStakingRatio'];
    maticValidatorList = json['maticValidatorList'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.network != null) {
      data['network'] = this.network.toJson();
    }
    if (this.matic != null) {
      data['matic'] = this.matic.toJson();
    }
    data['maticStakingRatio'] = this.maticStakingRatio;
    data['maticValidatorList'] = this.maticValidatorList;
    return data;
  }
}

class Network {
  String selfStake;
  String delegatedStake;
  String total;

  Network({this.selfStake, this.delegatedStake, this.total});

  Network.fromJson(Map<String, dynamic> json) {
    selfStake = json['selfStake'];
    delegatedStake = json['delegatedStake'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['selfStake'] = this.selfStake;
    data['delegatedStake'] = this.delegatedStake;
    data['total'] = this.total;
    return data;
  }
}

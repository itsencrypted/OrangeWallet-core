class ValidatorDetail {
  String status;
  ValidatorData result;

  ValidatorDetail({this.status, this.result});

  ValidatorDetail.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    result = json['result'] != null
        ? new ValidatorData.fromJson(json['result'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.result != null) {
      data['result'] = this.result.toJson();
    }
    return data;
  }
}

class ValidatorData {
  int id;
  String name;
  String description;
  String owner;
  String signer;
  String activationEpoch;
  String deactivationEpoch;
  String jailEndEpoch;
  String url;
  String logoUrl;
  String commissionPercent;
  String status;
  String uptimePercent;
  BigInt selfStake;
  BigInt delegatedStake;
  BigInt totalReward;
  BigInt claimedReward;
  int signatureMissCount;
  bool isInAuction;
  String auctionAmount;
  String createdAt;
  String updatedAt;
  String contractAddress;
  String signerPublicKey;
  bool delegationEnabled;

  ValidatorData(
      {this.id,
      this.name,
      this.description,
      this.owner,
      this.signer,
      this.activationEpoch,
      this.deactivationEpoch,
      this.jailEndEpoch,
      this.url,
      this.logoUrl,
      this.commissionPercent,
      this.status,
      this.uptimePercent,
      this.selfStake,
      this.delegatedStake,
      this.totalReward,
      this.claimedReward,
      this.signatureMissCount,
      this.isInAuction,
      this.auctionAmount,
      this.createdAt,
      this.updatedAt,
      this.contractAddress,
      this.signerPublicKey,
      this.delegationEnabled});

  ValidatorData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    owner = json['owner'];
    signer = json['signer'];
    activationEpoch = json['activationEpoch'];
    deactivationEpoch = json['deactivationEpoch'];
    jailEndEpoch = json['jailEndEpoch'];
    url = json['url'];
    logoUrl = json['logoUrl'];
    commissionPercent = json['commissionPercent'].toString();
    status = json['status'];
    uptimePercent = json['uptimePercent'];
    selfStake = BigInt.from(json['selfStake']);
    delegatedStake = BigInt.from(json['delegatedStake']);
    totalReward = BigInt.from(json['totalReward']);
    claimedReward = BigInt.from(json['claimedReward']);
    signatureMissCount = json['signatureMissCount'];
    isInAuction = json['isInAuction'];
    auctionAmount = json['auctionAmount'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    contractAddress = json['contractAddress'];
    signerPublicKey = json['signerPublicKey'];
    delegationEnabled = json['delegationEnabled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['owner'] = this.owner;
    data['signer'] = this.signer;
    data['activationEpoch'] = this.activationEpoch;
    data['deactivationEpoch'] = this.deactivationEpoch;
    data['jailEndEpoch'] = this.jailEndEpoch;
    data['url'] = this.url;
    data['logoUrl'] = this.logoUrl;
    data['commissionPercent'] = this.commissionPercent;
    data['status'] = this.status;
    data['uptimePercent'] = this.uptimePercent;
    data['selfStake'] = this.selfStake;
    data['delegatedStake'] = this.delegatedStake;
    data['totalReward'] = this.totalReward;
    data['claimedReward'] = this.claimedReward;
    data['signatureMissCount'] = this.signatureMissCount;
    data['isInAuction'] = this.isInAuction;
    data['auctionAmount'] = this.auctionAmount;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['contractAddress'] = this.contractAddress;
    data['signerPublicKey'] = this.signerPublicKey;
    data['delegationEnabled'] = this.delegationEnabled;
    return data;
  }
}

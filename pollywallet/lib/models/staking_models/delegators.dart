class Delegators {
  Summary summary;
  List<Result> result;
  String status;

  Delegators({this.summary, this.result, this.status});

  Delegators.fromJson(Map<String, dynamic> json) {
    summary =
        json['summary'] != null ? new Summary.fromJson(json['summary']) : null;
    if (json['result'] != null) {
      result = new List<Result>();
      json['result'].forEach((v) {
        result.add(new Result.fromJson(v));
      });
    }
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.summary != null) {
      data['summary'] = this.summary.toJson();
    }
    if (this.result != null) {
      data['result'] = this.result.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    return data;
  }
}

class Summary {
  int limit;
  int offset;
  String sortBy;
  String direction;
  int total;
  int size;

  Summary(
      {this.limit,
      this.offset,
      this.sortBy,
      this.direction,
      this.total,
      this.size});

  Summary.fromJson(Map<String, dynamic> json) {
    limit = json['limit'];
    offset = json['offset'];
    sortBy = json['sortBy'];
    direction = json['direction'];
    total = json['total'];
    size = json['size'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['limit'] = this.limit;
    data['offset'] = this.offset;
    data['sortBy'] = this.sortBy;
    data['direction'] = this.direction;
    data['total'] = this.total;
    data['size'] = this.size;
    return data;
  }
}

class Result {
  String address;
  int stake;
  int shares;
  int bondedValidator;
  Null deactivationEpoch;
  int claimedReward;
  String createdAt;
  String updatedAt;

  Result(
      {this.address,
      this.stake,
      this.shares,
      this.bondedValidator,
      this.deactivationEpoch,
      this.claimedReward,
      this.createdAt,
      this.updatedAt});

  Result.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    stake = json['stake'];
    shares = json['shares'];
    bondedValidator = json['bondedValidator'];
    deactivationEpoch = json['deactivationEpoch'];
    claimedReward = json['claimedReward'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['stake'] = this.stake;
    data['shares'] = this.shares;
    data['bondedValidator'] = this.bondedValidator;
    data['deactivationEpoch'] = this.deactivationEpoch;
    data['claimedReward'] = this.claimedReward;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

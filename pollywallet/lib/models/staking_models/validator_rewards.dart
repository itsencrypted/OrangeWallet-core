class ValidatorReward {
  Summary summary;
  List<Result> result;
  String status;

  ValidatorReward({this.summary, this.result, this.status});

  ValidatorReward.fromJson(Map<String, dynamic> json) {
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
  int checkpointNumber;
  int validator;
  int reward;
  String power;
  String createdAt;
  String updatedAt;

  Result(
      {this.checkpointNumber,
      this.validator,
      this.reward,
      this.power,
      this.createdAt,
      this.updatedAt});

  Result.fromJson(Map<String, dynamic> json) {
    checkpointNumber = json['checkpointNumber'];
    validator = json['validator'];
    reward = json['reward'];
    power = json['power'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['checkpointNumber'] = this.checkpointNumber;
    data['validator'] = this.validator;
    data['reward'] = this.reward;
    data['power'] = this.power;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

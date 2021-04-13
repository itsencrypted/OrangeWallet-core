class StakedCount {
  String status;
  Result result;

  StakedCount({this.status, this.result});

  StakedCount.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    result =
        json['result'] != null ? new Result.fromJson(json['result']) : null;
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

class Result {
  int stakedCount;

  Result({this.stakedCount});

  Result.fromJson(Map<String, dynamic> json) {
    stakedCount = json['stakedCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stakedCount'] = this.stakedCount;
    return data;
  }
}

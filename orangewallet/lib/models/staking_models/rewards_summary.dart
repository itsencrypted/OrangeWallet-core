class RewardsSummary {
  String status;
  Result result;

  RewardsSummary({this.status, this.result});

  RewardsSummary.fromJson(Map<String, dynamic> json) {
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
  double totalValidatorReward;
  double totalReward;

  Result({this.totalValidatorReward, this.totalReward});

  Result.fromJson(Map<String, dynamic> json) {
    totalValidatorReward = json['totalValidatorReward'];
    totalReward = json['totalReward'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalValidatorReward'] = this.totalValidatorReward;
    data['totalReward'] = this.totalReward;
    return data;
  }
}

class DepositStatusModel {
  List<String> txHashes;

  DepositStatusModel({this.txHashes});

  DepositStatusModel.fromJson(Map<String, dynamic> json) {
    txHashes = json['txHashes'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['txHashes'] = this.txHashes;
    return data;
  }
}

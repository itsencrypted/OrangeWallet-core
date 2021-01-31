class BridgeApiMessage {
  int code;
  String msg;

  BridgeApiMessage({this.code, this.msg});

  BridgeApiMessage.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['msg'] = this.msg;
    return data;
  }
}

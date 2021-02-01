class Payload {
  String message;
  String result;
  String error;

  Payload({this.message, this.result, this.error});

  Payload.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    result = json['result'];
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['result'] = this.result;
    data['error'] = this.error;
    return data;
  }
}

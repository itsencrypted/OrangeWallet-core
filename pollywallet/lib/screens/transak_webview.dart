import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class TransakWebView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String url = ModalRoute.of(context).settings.arguments;
    return WebviewScaffold(
      url: url,
      appBar: new AppBar(
        title: new Text("Transak"),
      ),
    );
  }
}

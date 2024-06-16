import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import "package:webview_universal/webview_universal.dart";

class webviewScreen extends StatefulWidget {
  const webviewScreen({Key? key}) : super(key: key);
  @override
  _webviewScreenState createState() => _webviewScreenState();
}

class _webviewScreenState extends State<webviewScreen> {
  WebViewController webViewController = WebViewController();
  @override
  void initState() {
    super.initState();
    webViewController.init(
      context: context,
      setState: setState,
      uri: Uri.parse("https://ubuntu-kr.org"),
    );
    print('initState is called');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('didChangeDependencies is called');
  }

  @override
  void setState(fn) {
    super.setState(fn);
    print('setState');
  }

  @override
  void deactivate() {
    super.deactivate();
    print('deactivate');
  }

  // dispose 메서드는 위젯이 위젯 트리에서 완전히 제거될 때 호출된다
  @override
  void dispose() {
    super.dispose();
    print('dispose is called');
  }

  @override
  void reassemble() {
    super.reassemble();
    print('reassemble');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Wi-Fi Setup'), actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Wi-Fi 다시 스캔',
            onPressed: () async {
              //   await scanWifi();
            },
          ),
        ]),
        body: WebView(
          controller: webViewController,
        ));
  }
}

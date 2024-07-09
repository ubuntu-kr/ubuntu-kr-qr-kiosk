import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class PrintLayoutSettings extends StatefulWidget {
  const PrintLayoutSettings({Key? key}) : super(key: key);
  @override
  _PrintLayoutSettingsState createState() => _PrintLayoutSettingsState();
}

class _PrintLayoutSettingsState extends State<PrintLayoutSettings> {
  @override
  void initState() {
    super.initState();
    print('initState is called');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('인쇄 레이아웃'),
        ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Text("높이 및 너비(단위: mm)"))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 300),
                    child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          style: TextStyle(fontSize: 20),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: '너비 (mm)',
                          ),
                          onChanged: (value) => {},
                        ))),
                ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 300),
                    child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          style: TextStyle(fontSize: 20),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: '높이 (mm)',
                          ),
                          onChanged: (value) => {},
                        ))),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Text("해상도(단위: DPI)"))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 300),
                    child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          style: TextStyle(fontSize: 20),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: '해상도 (DPI)',
                          ),
                          onChanged: (value) => {},
                        ))),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    padding: const EdgeInsets.all(16.0),
                    child: OutlinedButton(
                        onPressed: () async {
                          var resultSnackBar = SnackBar(
                            content: Text(
                                "행사 관계자를 호출 하였습니다. Event staff has been called."),
                          );
                          ScaffoldMessenger.of(context)
                              .showSnackBar(resultSnackBar);
                        },
                        child: Text(
                          "설정 저장",
                          style: TextStyle(fontSize: 20),
                        ))),
              ],
            ),
          ],
        ));
  }
}

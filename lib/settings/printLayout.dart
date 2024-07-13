import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ubuntu_kr_qr_kiosk/printScreen.dart';

class PrintLayoutSettings extends StatefulWidget {
  const PrintLayoutSettings({Key? key}) : super(key: key);
  @override
  _PrintLayoutSettingsState createState() => _PrintLayoutSettingsState();
}

class _PrintLayoutSettingsState extends State<PrintLayoutSettings> {
  int printCanvasWidthMm = -1;
  int printCanvasHeightMm = -1;
  int printCanvasDpi = 203;
  int printCanvasWidthPx = -1;
  int printCanvasHeightPx = -1;
  @override
  void initState() {
    super.initState();
    var prefs = SharedPreferences.getInstance();
    prefs.then((SharedPreferences prefs) {
      setState(() {
        printCanvasWidthMm = prefs.getInt('printCanvasWidthMm') ?? 70;
        printCanvasHeightMm = prefs.getInt('printCanvasHeightMm') ?? 70;
        printCanvasDpi = prefs.getInt('printCanvasDpi') ?? 203;
        printCanvasWidthPx = (printCanvasWidthMm * printCanvasDpi) ~/ 25.4;
        printCanvasHeightPx = (printCanvasHeightMm * printCanvasDpi) ~/ 25.4;
      });
    });
    print('initState is called');
  }

  void savePrintLayout() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt('printCanvasWidthMm', printCanvasWidthMm);
    prefs.setInt('printCanvasHeightMm', printCanvasHeightMm);
    prefs.setInt('printCanvasDpi', printCanvasDpi);
    var resultSnackBar = SnackBar(
      content: Text(
          "인쇄 레이아웃 저장됨: $printCanvasWidthMm mm * $printCanvasHeightMm mm ($printCanvasDpi DPI) -> $printCanvasWidthPx px * $printCanvasHeightPx px"),
    );
    ScaffoldMessenger.of(context).showSnackBar(resultSnackBar);
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
                          onChanged: (value) {
                            setState(() {
                              printCanvasWidthMm = int.parse(value);
                              printCanvasWidthPx =
                                  (printCanvasWidthMm * printCanvasDpi) ~/ 25.4;
                            });
                            savePrintLayout();
                          },
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
                          onChanged: (value) {
                            setState(() {
                              printCanvasHeightMm = int.parse(value);
                              printCanvasHeightPx =
                                  (printCanvasHeightMm * printCanvasDpi) ~/
                                      25.4;
                            });
                            savePrintLayout();
                          },
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
                          onChanged: (value) {
                            setState(() {
                              printCanvasDpi = int.parse(value);
                              printCanvasWidthPx =
                                  (printCanvasWidthMm * printCanvasDpi) ~/ 25.4;
                              printCanvasHeightPx =
                                  (printCanvasHeightMm * printCanvasDpi) ~/
                                      25.4;
                            });
                            savePrintLayout();
                          },
                        ))),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                        "사용중인 설정: $printCanvasWidthMm mm * $printCanvasHeightMm mm ($printCanvasDpi DPI) -> $printCanvasWidthPx px * $printCanvasHeightPx px"))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    child: Text(
                      "인쇄 테스트 Test printing",
                      style: TextStyle(fontSize: 20),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PrintPage(
                                nametagData: NametagData(
                                    "[이름]",
                                    "[소속]",
                                    "[직책]",
                                    "https://ubuntu-kr.org",
                                    "교환권\n티셔츠 XL (테스트)\n 도시락/채식 (테스트)"))),
                      );
                    })
              ],
            )
          ],
        ));
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        printCanvasWidthPx = mmToPx(printCanvasWidthMm, printCanvasDpi);
        printCanvasHeightPx = mmToPx(printCanvasHeightMm, printCanvasDpi);
      });
    });
    print('initState is called');
  }

  int mmToPx(int mm, int dpi) {
    return (mm * dpi) ~/ 25.4;
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
                                  mmToPx(printCanvasWidthMm, printCanvasDpi);
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
                                  mmToPx(printCanvasHeightMm, printCanvasDpi);
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
                                  mmToPx(printCanvasWidthMm, printCanvasDpi);
                              printCanvasHeightPx =
                                  mmToPx(printCanvasHeightMm, printCanvasDpi);
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
          ],
        ));
  }
}

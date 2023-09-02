import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:yaru/yaru.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'imgutil.dart';
import 'tsplutils.dart';
import 'kioskclient.dart';

GlobalKey globalKey = GlobalKey();

class NametagData {
  final String name;
  final String affiliation;
  final String role;
  final String qrUrl;

  const NametagData(this.name, this.affiliation, this.role, this.qrUrl);
}

class PrintPage extends StatefulWidget {
  const PrintPage({Key? key, required this.nametagData}) : super(key: key);
  final NametagData nametagData;
  @override
  _PrintPageState createState() => _PrintPageState(nametagData);
}

class _PrintPageState extends State<PrintPage> {
  var deviceList = "";
  var qrCodeContent = "";
  var nametagName = "";
  var nametagAffiliation = "";
  var nametagRole = "";
  var nametagQrUrl = "";
  var printStatus = "";
  var isKioskConfigured = false;
  bool isProcessingQrCheckin = false;
  _PrintPageState(NametagData nametagData) {
    nametagName = nametagData.name;
    nametagAffiliation = nametagData.affiliation;
    nametagRole = nametagData.role;
    nametagQrUrl = nametagData.qrUrl;
  }
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 1), () {
      printNametag();
    });
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
  void didUpdateWidget(covariant PrintPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('didUpdateWidget');
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

  Future<ui.Image> _capturePng() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    return image;
  }

  void printNametag() async {
    setState(() {
      printStatus = "인쇄 중...";
    });

    var uiImage = await _capturePng();
    var imageUint8 = await convertImageToMonochrome(uiImage);
    var tsplBitmapData = buildBitmapPrintTsplCmd(
        0, 50, uiImage.width, uiImage.height, 70, 70, imageUint8);
    sendTsplData(tsplBitmapData, 8137, 8214);
    setState(() {
      printStatus = "";
      isProcessingQrCheckin = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('명찰 출력'),
        ),
        body: Row(
          children: [
            Column(
              children: [
                Text(deviceList),
                Text(printStatus),
                SizedBox(
                    width: 550.0,
                    height: 500.0,
                    child: RepaintBoundary(
                        key: globalKey,
                        child: ColorFiltered(
                            colorFilter: greyScaleFilter,
                            child: Container(
                              color: Colors.white,
                              child: Center(
                                  child: Column(
                                children: [
                                  Text(
                                    nametagName,
                                    style: TextStyle(
                                        fontWeight: ui.FontWeight.bold,
                                        fontSize: 70),
                                  ),
                                  Text(
                                    nametagAffiliation,
                                    style: TextStyle(
                                        fontWeight: ui.FontWeight.bold,
                                        fontSize: 30),
                                  ),
                                  Text(
                                    nametagRole,
                                    style: TextStyle(
                                        fontWeight: ui.FontWeight.bold,
                                        fontSize: 30),
                                  ),
                                  QrImageView(
                                      data: nametagQrUrl,
                                      version: QrVersions.auto,
                                      size: 150.0),
                                ],
                              )),
                            ))))
              ],
            )
          ],
        ));
  }
}

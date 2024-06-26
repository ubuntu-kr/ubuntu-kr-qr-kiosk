import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'imgutil.dart';
import 'printclient.dart';

GlobalKey nametagKey = GlobalKey();
GlobalKey couponKey = GlobalKey();

class NametagData {
  final String name;
  final String affiliation;
  final String role;
  final String qrUrl;
  final String couponDetail;

  const NametagData(
      this.name, this.affiliation, this.role, this.qrUrl, this.couponDetail);
}

class PrintPage extends StatefulWidget {
  const PrintPage({Key? key, required this.nametagData}) : super(key: key);
  final NametagData nametagData;
  @override
  _PrintPageState createState() => _PrintPageState(nametagData);
}

class _PrintPageState extends State<PrintPage> {
  var qrCodeContent = "";
  var nametagName = "";
  var nametagAffiliation = "";
  var nametagRole = "";
  var nametagQrUrl = "";
  var couponDetail = "";
  var isKioskConfigured = false;
  bool isProcessingQrCheckin = false;
  _PrintPageState(NametagData nametagData) {
    nametagName = nametagData.name;
    nametagAffiliation = nametagData.affiliation;
    nametagRole = nametagData.role;
    nametagQrUrl = nametagData.qrUrl;
    couponDetail = nametagData.couponDetail;
  }
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 1), () async {
      var result1 = await printNametag(nametagKey);
      var result1Msg = result1
          ? "명찰 인쇄 완료. Nametag has been printed."
          : "명찰 인쇄중 오류 발생. Error while printing nametag.";
      var snackBar = SnackBar(
        content: Text(result1Msg),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      if (couponDetail != "") {
        var result2 = await printNametag(couponKey);
        var result2Msg = result2
            ? "교환권 인쇄 완료. Coupon has been printed."
            : "교환권 인쇄중 오류 발생. Error while printing Coupon.";
        var snackBar2 = SnackBar(
          content: Text(result2Msg),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar2);
      }
      var resultSnackBar = SnackBar(
        content: Text("명찰 및 교환권 인쇄 완료. Nametag and coupon have been printed."),
      );
      ScaffoldMessenger.of(context).showSnackBar(resultSnackBar);
      Navigator.pop(context, 'OK');
      Navigator.pop(context, 'OK');
    });
    print('initState is called');
  }

  Future<ui.Image> _capturePng(GlobalKey globalKey) async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    return image;
  }

  Future<bool> printNametag(GlobalKey globalKey) async {
    var uiImage = await _capturePng(globalKey);
    var result = await printImageToLabel(uiImage, 8137, 8214);
    setState(() {
      isProcessingQrCheckin = false;
    });
    return result == 200;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('명찰 출력'),
        ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Colors.black,
                    ),
                  ),
                  child: SizedBox(
                      width: 550.0,
                      height: 500.0,
                      child: RepaintBoundary(
                          key: nametagKey,
                          child: ColorFiltered(
                              colorFilter: greyScaleFilter,
                              child: Container(
                                color: Colors.white,
                                child: Center(
                                    child: Column(
                                  children: [
                                    Text(
                                      nametagName,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: ui.FontWeight.bold,
                                          fontSize: 75),
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
                              )))),
                ),
                Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.black,
                      ),
                    ),
                    child: SizedBox(
                        width: 550.0,
                        height: 500.0,
                        child: RepaintBoundary(
                            key: couponKey,
                            child: ColorFiltered(
                                colorFilter: greyScaleFilter,
                                child: Container(
                                  color: Colors.white,
                                  child: Center(
                                      child: Column(
                                    children: [
                                      Text(
                                        "교환권",
                                        style: TextStyle(
                                            fontWeight: ui.FontWeight.bold,
                                            fontSize: 30),
                                      ),
                                      Text(
                                        nametagName,
                                        style: TextStyle(fontSize: 30),
                                      ),
                                      Text(
                                        couponDetail,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 30),
                                      ),
                                    ],
                                  )),
                                )))))
              ],
            )
          ],
        ));
  }
}

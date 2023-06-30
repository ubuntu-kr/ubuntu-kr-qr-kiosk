import 'dart:convert';
import 'dart:typed_data';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';
import 'package:quick_usb/quick_usb.dart';
import 'package:provider/provider.dart';
import 'package:charset/charset.dart';
import 'package:image/image.dart' as imglib;
import 'package:flutter_gstreamer_player/flutter_gstreamer_player.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_vision/qr_code_vision.dart' as qrvision;
import 'imgutil.dart';
import 'tsplutils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MyAppState(),
        child: YaruTheme(builder: (context, yaru, child) {
          return MaterialApp(
              theme: yaru.theme, darkTheme: yaru.darkTheme, home: MyHomePage());
        }));
  }
}

class MyAppState extends ChangeNotifier {
  var deviceList = "";
  GlobalKey globalKey = GlobalKey();
  GlobalKey cameraKey = GlobalKey();

  Future<ui.Image> _capturePng() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    return image;
  }

  Future<void> _getQrCodeContentFromCamera() async {
    RenderRepaintBoundary boundary =
        cameraKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();

    final qrCode = qrvision.QrCode();
    final byteData =
        (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!
            .buffer
            .asUint8List();
    qrCode.scanRgbaBytes(byteData, image.width, image.height);

    if (qrCode.location == null) {
      print('No QR code found');
    } else {
      print('QR code here: ${qrCode.location}');

      if (qrCode.content == null) {
        print('The content of the QR code could not be decoded');
      } else {
        print('This is the content: ${qrCode.content?.text}');
      }
    }
  }

  void updateDeviceList() async {
    var descriptions = await QuickUsb.getDevicesWithDescription();
    var devList = descriptions.map((e) => e.device).toList();
    deviceList = devList.join("\n");
    var labelPrinter =
        devList.firstWhere((e) => e.vendorId == 8137 && e.productId == 8214);
    var openDevice = await QuickUsb.openDevice(labelPrinter);
    print('openDevice $openDevice');
    await QuickUsb.setAutoDetachKernelDriver(true);
    notifyListeners();

    var _configuration = await QuickUsb.getConfiguration(0);
    var claimInterface =
        await QuickUsb.claimInterface(_configuration!.interfaces[0]);
    deviceList = _configuration.interfaces[0].endpoints.toString();
    var endpoint = _configuration.interfaces[0].endpoints
        .firstWhere((e) => e.direction == UsbEndpoint.DIRECTION_OUT);

    var uiImage = await _capturePng();
    var imageUint8 = await convertImageToMonochrome(uiImage);
    var bulkTransferOut = await QuickUsb.bulkTransferOut(
        endpoint,
        buildBitmapPrintTsplCmd(
            0, 50, uiImage.width, uiImage.height, 70, 70, imageUint8));
    print('bulkTransferOut $bulkTransferOut');
    await QuickUsb.closeDevice();
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
        appBar: AppBar(
          title: Text('UbuCon KR 체크인 키오스크'),
        ),
        body: Row(
          children: [
            Column(
              children: [
                SizedBox(
                    width: 550.0,
                    height: 500.0,
                    child: RepaintBoundary(
                        key: appState.cameraKey,
                        child: GstPlayer(
                          pipeline:
                              '''v4l2src device=/dev/video0  ! videoconvert ! video/x-raw,format=RGBA ! appsink name=sink''',
                        )))
              ],
            ),
            Column(
              children: [
                Text(appState.deviceList),
                ElevatedButton(
                    child: const Text("Init"),
                    onPressed: () async {
                      await QuickUsb.init();
                    }),
                ElevatedButton(
                    child: const Text("Get List"),
                    onPressed: () async {
                      appState.updateDeviceList();
                    }),
                ElevatedButton(
                    child: const Text("Scan QR"),
                    onPressed: () async {
                      appState._getQrCodeContentFromCamera();
                    }),
                SizedBox(
                    width: 550.0,
                    height: 500.0,
                    child: RepaintBoundary(
                        key: appState.globalKey,
                        child: ColorFiltered(
                            colorFilter: greyScaleFilter,
                            child: Container(
                              color: Colors.white,
                              child: Center(
                                  child: Column(
                                children: [
                                  Text(
                                    "Hey, Parktana!",
                                    style: TextStyle(
                                        fontWeight: ui.FontWeight.bold,
                                        fontSize: 70),
                                  ),
                                  Text(
                                    "Q: 도쿄 가는 빠르고 저렴한 방법은?",
                                    style: TextStyle(
                                        fontWeight: ui.FontWeight.bold,
                                        fontSize: 30),
                                  ),
                                  Text(
                                    "A: 하늘로의 산책을 하십시오. w/ Star Aliance Membership",
                                    style: TextStyle(
                                        fontWeight: ui.FontWeight.bold,
                                        fontSize: 30),
                                  ),
                                  QrImageView(
                                      data: 'https://parktana.youngbin.xyz',
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

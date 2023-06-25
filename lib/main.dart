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

  Future<Uint8List> _capturePng() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();

    ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    var binaryBitmap =
        imglib.Image.fromBytes(width: 550, height: 200, bytes: byteData!.buffer)
            .convert(format: imglib.Format.uint1, numChannels: 1)
            .getBytes();
    // print(binaryBitmap);
    return binaryBitmap;
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

    // var clscmd = utf8.encode("CLS\r\n");
    // var bulkTransferOutCls = await QuickUsb.bulkTransferOut(
    //     endpoint, Uint8List.fromList(clscmd),
    //     timeout: 2000);
    // print('bulkTransferOutCls $bulkTransferOutCls');

    // var cmddata = utf8.encode("CODEPAGE 949");
    var cmddata = utf8.encode("SIZE 70 mm,70 mm\r\n");
    // cmddata += utf8.encode("SIZE 70 mm,70 mm\r\n");
    cmddata += utf8.encode("CLS\r\n");
    cmddata += utf8.encode('BITMAP 0,0,68,200,0, ');
    // print('image bitmap: $imageUint8');\
    var imageUint8 = await _capturePng();
    cmddata += imageUint8;
    cmddata += utf8.encode("PRINT 1\r\n");
    cmddata += utf8.encode("END\r\n");
    // print(utf8.decode(cmddata));
    var bulkTransferOut =
        await QuickUsb.bulkTransferOut(endpoint, Uint8List.fromList(cmddata));
    print('bulkTransferOut $bulkTransferOut');
    await QuickUsb.closeDevice();
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    // final img = textToImage("Test image");
    // final imgBuffer =
    //      img.toByteData(format: ui.ImageByteFormat.png).then();
    return Scaffold(
      appBar: AppBar(
        title: Text('UbuCon KR 체크인 키오스크'),
      ),
      body: Column(
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
          SizedBox(
              width: 550.0,
              height: 200.0,
              child: RepaintBoundary(
                  key: appState.globalKey,
                  child: Container(
                    color: Colors.white,
                    child: Center(child: Text("라벨 출력 테스트")),
                  )))
        ],
      ),
    );
  }
}

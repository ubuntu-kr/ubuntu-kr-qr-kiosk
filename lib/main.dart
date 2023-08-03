import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:yaru/yaru.dart';
import 'package:quick_usb/quick_usb.dart';
import 'package:flutter_gstreamer_player/flutter_gstreamer_player.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_vision/qr_code_vision.dart' as qrvision;
import 'imgutil.dart';
import 'tsplutils.dart';
import 'kioskclient.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

GlobalKey globalKey = GlobalKey();
GlobalKey cameraKey = GlobalKey();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return YaruTheme(builder: (context, yaru, child) {
      return MaterialApp(
          theme: yaru.theme, darkTheme: yaru.darkTheme, home: KioskMainPage());
    });
  }
}

class KioskMainPage extends StatefulWidget {
  const KioskMainPage({Key? key}) : super(key: key);
  @override
  _KioskMainPageState createState() => _KioskMainPageState();
}

class _KioskMainPageState extends State<KioskMainPage> {
  var deviceList = "";
  var qrCodeContent = "";
  var nametagName = "";
  var nametagAffiliation = "";
  var nametagRole = "";
  var nametagQrUrl = "";
  var printStatus = "";
  var isKioskConfigured = false;
  late KioskClient kioskClient;
  bool isProcessingQrCheckin = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    Map<String, String> envVars = Platform.environment;
    var timer = Timer.periodic(Duration(milliseconds: 1), (timer) {
      _getQrCodeContentFromCamera();
    });
    checkIsKioskConfigured().then((checkKioskConfig) {
      print("Is Kiosk configured? ${checkKioskConfig}");
      if (checkKioskConfig) {
        SharedPreferences.getInstance().then((prefs) {
          setState(() {
            isKioskConfigured = checkKioskConfig;
            nametagRole = "체크인 QR을 스캔하세요.";
            kioskClient = KioskClient(
                envVars['HOME']! + "/ubuntu_kr_qr_kiosk_check_in_db.db",
                prefs.getString('host') ?? '',
                prefs.getString('apiToken') ?? '',
                prefs.getString('jwtKey') ?? '',
                prefs.getString('jwtKeyAlgo') ?? '');
            _timer = timer;
          });
        });
      } else {
        setState(() {
          isKioskConfigured = checkKioskConfig;
          nametagRole = "키오스크 설정 QR을 스캔하세요.";
          _timer = timer;
        });
      }
    });

    QuickUsb.init().whenComplete(() => print("QuickUsb Init"));
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
  void didUpdateWidget(covariant KioskMainPage oldWidget) {
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
    _timer.cancel();
    kioskClient.closeDb();
    QuickUsb.exit().whenComplete(() => print("QuickUsb exit"));
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

  Future<void> _getQrCodeContentFromCamera() async {
    if (isProcessingQrCheckin) {
      return;
    }

    RenderRepaintBoundary boundary =
        cameraKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();

    final qrCode = qrvision.QrCode();
    final byteData =
        (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!
            .buffer
            .asUint8List();
    qrCode.scanRgbaBytes(byteData, image.width, image.height);

    if (qrCode.location != null) {
      // print('QR code here: ${qrCode.location}');
      if (qrCode.content != null) {
        try {
          print('QR Content found!');
          print('QR Content: ${qrCode.content?.text}');
          var qrContent = qrCode.content!.text;
          if (!isKioskConfigured) {
            try {
              // base64 decode into string
              var decodedQrContent = utf8.decode(base64.decode(qrContent));
              print(decodedQrContent);
              var clientConfig = jsonDecode(decodedQrContent.toString());
              if (clientConfig.containsKey('config_endpoint') &&
                  clientConfig.containsKey('token')) {
                setState(() {
                  nametagRole = "키오스크 설정 중입니다.";
                });
                await configureKiosk(
                    clientConfig['config_endpoint'], clientConfig['token']);
                Map<String, String> envVars = Platform.environment;
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                var newKioskClient = KioskClient(
                    envVars['HOME']! + "/ubuntu_kr_qr_kiosk_check_in_db.db",
                    prefs.getString('host') ?? '',
                    prefs.getString('apiToken') ?? '',
                    prefs.getString('jwtKey') ?? '',
                    prefs.getString('jwtKeyAlgo') ?? '');
                setState(() {
                  isKioskConfigured = true;
                  nametagRole = "체크인 QR을 스캔하세요.";
                  kioskClient = newKioskClient;
                });
              }
            } on Exception catch (e) {
              print(e);
            }
          } else {
            setState(() {
              isProcessingQrCheckin = true;
            });
            var (result, payload) = kioskClient.checkInLocally(qrContent);
            setState(() {
              nametagName = payload['nametagName'];
              nametagAffiliation = payload['nametagAffiliation'];
              nametagRole = payload['nametagRole'];
              nametagQrUrl = payload['nametagUrl'];
            });
            if (result) {
              Timer(Duration(seconds: 1), () {
                printNametag();
              });
              await kioskClient.checkInOnServer(qrContent);
            }
          }
        } catch (e, s) {
          print(e);
          print(s);
        }
      }
    }
  }

  void printNametag() async {
    setState(() {
      printStatus = "인쇄 중...";
    });
    var descriptions = await QuickUsb.getDevicesWithDescription();
    var devList = descriptions.map((e) => e.device).toList();
    deviceList = devList.join("\n");
    var labelPrinter =
        devList.firstWhere((e) => e.vendorId == 8137 && e.productId == 8214);
    var openDevice = await QuickUsb.openDevice(labelPrinter);
    print('openDevice $openDevice');
    await QuickUsb.setAutoDetachKernelDriver(true);

    var usbConfig = await QuickUsb.getConfiguration(0);
    var claimInterface = await QuickUsb.claimInterface(usbConfig.interfaces[0]);
    setState(() {
      deviceList = usbConfig.interfaces[0].endpoints.toString();
    });
    var endpoint = usbConfig.interfaces[0].endpoints
        .firstWhere((e) => e.direction == UsbEndpoint.DIRECTION_OUT);

    var uiImage = await _capturePng();
    var imageUint8 = await convertImageToMonochrome(uiImage);
    var bulkTransferOut = await QuickUsb.bulkTransferOut(
        endpoint,
        buildBitmapPrintTsplCmd(
            0, 50, uiImage.width, uiImage.height, 70, 70, imageUint8));
    print('bulkTransferOut $bulkTransferOut');
    await QuickUsb.closeDevice();
    setState(() {
      printStatus = "";
      isProcessingQrCheckin = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                        key: cameraKey,
                        child: GstPlayer(
                          pipeline:
                              '''v4l2src device=/dev/video0  ! videoconvert ! video/x-raw,format=RGBA ! appsink name=sink''',
                        )))
              ],
            ),
            Column(
              children: [
                Text(deviceList),
                Text(printStatus),
                ElevatedButton(
                    child: const Text("Get List"),
                    onPressed: () async {
                      printNametag();
                    }),
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

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:ubuntu_kr_qr_kiosk/printScreen.dart';
import 'package:yaru/yaru.dart';
import 'package:flutter/material.dart';
import 'kioskclient.dart';
import 'printScreen.dart';

class CheckInByBarcodeScreen extends StatefulWidget {
  const CheckInByBarcodeScreen({Key? key}) : super(key: key);
  @override
  _CheckInByBarcodeScreenState createState() => _CheckInByBarcodeScreenState();
}

class _CheckInByBarcodeScreenState extends State<CheckInByBarcodeScreen> {
  late KioskClient kioskClient;
  var barcodeData = "";
  var completeBarcodeData = "";
  @override
  void initState() {
    super.initState();
    kioskClient = KioskClient();
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
  void didUpdateWidget(covariant CheckInByBarcodeScreen oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('QR Code Check-in'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  size: 100.0,
                  semanticLabel: 'Text to announce in accessibility modes',
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "QR코드를 스캔 해주세요.",
                  style: TextStyle(fontSize: 40),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: 500,
                    child: TextField(
                      obscureText: true,
                      autofocus: true,
                      style: TextStyle(fontSize: 10),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Barcode data',
                      ),
                      onSubmitted: (value) async {
                        var localResult = kioskClient.checkInLocally(value);
                        if (!localResult.$1) {
                          var snackBar = SnackBar(
                            content: Text(localResult.$2),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          Navigator.pop(context, 'ERROR');
                          return;
                        }
                        var serverResult =
                            await kioskClient.checkInOnServer(value);
                        if (!serverResult.$1) {
                          var snackBar = SnackBar(
                            content: Text(localResult.$2["result"]),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          Navigator.pop(context, 'ERROR');
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PrintPage(
                                  nametagData: NametagData(
                                      serverResult.$2['name'],
                                      serverResult.$2['affilation'],
                                      serverResult.$2['role'],
                                      serverResult.$2['qrUrl']))),
                        );
                      },
                    ))
              ],
            )
          ],
        ));
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:dbus/dbus.dart';
import 'package:nm/nm.dart';

class WifiScreen extends StatefulWidget {
  const WifiScreen({Key? key}) : super(key: key);
  @override
  _WifiScreenState createState() => _WifiScreenState();
}

class _WifiScreenState extends State<WifiScreen> {
  double? scanProgress = 0.0;
  late NetworkManagerClient nmClient;
  List<NetworkManagerAccessPoint> foundAPs = [];
  @override
  void initState() {
    super.initState();
    nmClient = NetworkManagerClient();
    nmClient.connect().then((_) async {
      await scanWifi();
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
  void deactivate() {
    super.deactivate();
    print('deactivate');
  }

  // dispose 메서드는 위젯이 위젯 트리에서 완전히 제거될 때 호출된다
  @override
  void dispose() {
    super.dispose();
    nmClient.close().then((value) => print("nmClient closed"));
    print('dispose is called');
  }

  @override
  void reassemble() {
    super.reassemble();
    print('reassemble');
  }

  Future<void> scanWifi() async {
    setState(() {
      scanProgress = null;
    });
    NetworkManagerDevice device;
    try {
      device = nmClient.devices
          .firstWhere((d) => d.deviceType == NetworkManagerDeviceType.wifi);
    } catch (e) {
      print('No WiFi devices found');
      setState(() {
        scanProgress = 0.0;
      });
      return;
    }

    var wireless = device.wireless!;

    print('Scanning WiFi device ${device.hwAddress}...');
    await wireless.requestScan();

    wireless.propertiesChanged.listen((propertyNames) {
      if (propertyNames.contains('LastScan')) {
        /// Get APs with names.
        var accessPoints =
            wireless.accessPoints.where((a) => a.ssid.isNotEmpty).toList();

        // Sort by signal strength.
        accessPoints.sort((a, b) => b.strength.compareTo(a.strength));
        setState(() {
          foundAPs = accessPoints;
        });
        setState(() {
          scanProgress = 0.0;
        });
        // for (var accessPoint in accessPoints) {
        //   var ssid = utf8.decode(accessPoint.ssid);
        //   var strength = accessPoint.strength.toString().padRight(3);
        //   print("  ${accessPoint.frequency}MHz $strength '$ssid'");
        // }
        // if (accessPoints.isNotEmpty) {
        //   // connectToWifiNetwork(client, device, accessPoints.first);
        // }
        // exit(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Wi-Fi Setup'),
        ),
        body: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LinearProgressIndicator(value: scanProgress),
            Row(
              children: [
                Expanded(
                    child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: foundAPs == null ? 0 : foundAPs.length,
                  itemBuilder: (context, index) {
                    var resultItem = foundAPs[index];
                    return Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 600),
                              child: ListTile(
                                title: Text(
                                  "${utf8.decode(resultItem.ssid)} (${resultItem.frequency}MHz, ${resultItem.strength.toString().padRight(3)})",
                                  style: TextStyle(fontSize: 20),
                                ),
                                onTap: () => {},
                              ))
                        ]);
                  },
                ))
              ],
            )
          ],
        ));
  }
}

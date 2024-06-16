import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:dbus/dbus.dart';
import 'package:nm/nm.dart';
import 'webviewScreen.dart';

class WifiScreen extends StatefulWidget {
  const WifiScreen({Key? key}) : super(key: key);
  @override
  _WifiScreenState createState() => _WifiScreenState();
}

class _WifiScreenState extends State<WifiScreen> {
  double? scanProgress = 0.0;
  var wifiPassword = "";
  late NetworkManagerClient nmClient;
  late NetworkManagerDevice nmDevice;
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
    try {
      nmDevice = nmClient.devices
          .firstWhere((d) => d.deviceType == NetworkManagerDeviceType.wifi);
    } catch (e) {
      print('No WiFi devices found');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("WiFi 장치가 없어서 주변 WiFi 스캔을 할 수 없습니다."),
      ));
      setState(() {
        scanProgress = 0.0;
      });
      return;
    }

    var wireless = nmDevice.wireless!;

    print('Scanning WiFi device ${nmDevice.hwAddress}...');
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("WiFi 스캔이 완료 되었습니다."),
        ));
      }
    });
  }

  void showAccessPointConnectDialog(
      BuildContext context, NetworkManagerAccessPoint accessPoint) {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
                title: Text(utf8.decode(accessPoint.ssid)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('주파수(Frequency): ${accessPoint.frequency}MHz'),
                    Text(
                        '신호 강도(Strength): ${accessPoint.strength.toString().padRight(3)}'),
                    Text(
                        '${utf8.decode(accessPoint.ssid)}에 처음 연결하거나, 암호가 변경된 경우 암호를 입력하세요.'),
                    Text('그렇지 않은 경우 암호 입력란을 비워두세요.'),
                    if (accessPoint.rsnFlags.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          autofocus: true,
                          obscureText: true,
                          style: TextStyle(fontSize: 20),
                          // readOnly: showModalProgress,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: '암호 입력',
                          ),
                          onChanged: (value) => {
                            setState(() {
                              wifiPassword = value;
                            })
                          },
                        ),
                      ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      setState(() {
                        wifiPassword = "";
                      });
                      Navigator.pop(context, 'Cancel');
                    },
                    child: const Text('취소 (Cancel)'),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context, 'Connect');
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            "${utf8.decode(accessPoint.ssid)}에 연결 중입니다..."),
                      ));
                      await connectToAccessPoint(
                          nmClient, nmDevice, accessPoint, wifiPassword);
                    },
                    child: const Text('연결 (Connect)'),
                  ),
                ]));
  }

  Future<void> connectToAccessPoint(
      NetworkManagerClient manager,
      NetworkManagerDevice device,
      NetworkManagerAccessPoint accessPoint,
      String? wifiPsk) async {
    try {
      // Has password
      if (accessPoint.rsnFlags.isNotEmpty) {
        var psk = wifiPsk ?? await getSavedWifiPsk(device, accessPoint);
        if (psk != null) {
          await manager.addAndActivateConnection(
              device: device,
              accessPoint: accessPoint,
              connection: {
                '802-11-wireless-security': {
                  'key-mgmt': DBusString('wpa-psk'),
                  'psk': DBusString(psk)
                }
              });
        }
      } else {
        await manager.addAndActivateConnection(
            device: device, accessPoint: accessPoint);
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("${utf8.decode(accessPoint.ssid)}에 연결 시도 중 오류가 발생했습니다."),
      ));
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("${utf8.decode(accessPoint.ssid)}에 연결 되었습니다!"),
    ));
  }

  Future<String?> getSavedWifiPsk(NetworkManagerDevice device,
      NetworkManagerAccessPoint accessPoint) async {
    var settingsConnection =
        await getAccessPointConnectionSettings(device, accessPoint);
    if (settingsConnection != null) {
      var secrets =
          await settingsConnection.getSecrets('802-11-wireless-security');
      if (secrets.isNotEmpty) {
        var security = secrets['802-11-wireless-security'];
        if (security != null) {
          var psk = security['psk'];
          if (psk != null) {
            return psk.toNative();
          }
        }
      }
    }
    return null;
  }

  Future<NetworkManagerSettingsConnection?> getAccessPointConnectionSettings(
      NetworkManagerDevice device,
      NetworkManagerAccessPoint accessPoint) async {
    var ssid = utf8.decode(accessPoint.ssid);

    var settings = await Future.wait(device.availableConnections.map(
        (e) async => {'settings': await e.getSettings(), 'connection': e}));
    NetworkManagerSettingsConnection? accessPointSettings;
    for (var element in settings) {
      var s = element['settings'] as dynamic;
      if (s != null) {
        var connection = s['connection'] as Map<String, DBusValue>?;
        if (connection != null) {
          var id = connection['id'];
          if (id != null) {
            if (id.toNative() == ssid) {
              accessPointSettings =
                  element['connection'] as NetworkManagerSettingsConnection;
              break;
            }
          }
        }
      }
    }
    return accessPointSettings;
  }

//  Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => const WifiScreen()),
//                   );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Wi-Fi Setup'), actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Wi-Fi 다시 스캔',
            onPressed: () async {
              await scanWifi();
            },
          ),
          IconButton(
            icon: const Icon(Icons.web),
            tooltip: '웹 브라우저',
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const webviewScreen()),
              );
            },
          ),
        ]),
        body: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LinearProgressIndicator(value: scanProgress),
            Expanded(
                child: ListView.builder(
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
                            onTap: () {
                              showAccessPointConnectDialog(context, resultItem);
                            },
                          ))
                    ]);
              },
            ))
          ],
        ));
  }
}

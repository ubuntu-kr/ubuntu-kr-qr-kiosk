import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';
import 'package:quick_usb/quick_usb.dart';
import 'package:provider/provider.dart';

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

  void updateDeviceList() async {
    var descriptions = await QuickUsb.getDevicesWithDescription();
    var devList = descriptions.map((e) => e.device).toList();
    deviceList = devList.join("\n");
    var labelPrinter =
        devList.firstWhere((e) => e.vendorId == 8137 && e.productId == 8214);
    var openDevice = await QuickUsb.openDevice(labelPrinter);
    print('openDevice $openDevice');
    notifyListeners();

    var _configuration = await QuickUsb.getConfiguration(0);
    var claimInterface =
        await QuickUsb.claimInterface(_configuration!.interfaces[0]);
    deviceList = _configuration!.interfaces[0].endpoints.toString();
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('UbuCon KR Check-in Kiosk'),
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
        ],
      ),
    );
  }
}

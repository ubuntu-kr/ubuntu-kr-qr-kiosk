import 'dart:io';

import 'package:flutter/material.dart';
import 'checkInByEmailScreen.dart';
import 'checkInByBarcodeScreen.dart';
import 'package:yaru/yaru.dart';
import 'kioskclient.dart';

void main() {
  runApp(const MyApp());
}

GlobalKey globalKey = GlobalKey();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
        data: const YaruThemeData(
            variant: YaruVariant.orange, useMaterial3: true),
        builder: (context, yaru, child) {
          return DefaultTextStyle(
              style: const TextStyle(
                  fontFamily: "Ubuntu", fontFamilyFallback: ["Noto Sans CJK"]),
              child: MaterialApp(
                  theme: yaru.theme,
                  darkTheme: yaru.darkTheme,
                  home: const KioskMainPage()));
        });
  }
}

class KioskMainPage extends StatefulWidget {
  const KioskMainPage({Key? key}) : super(key: key);
  @override
  _KioskMainPageState createState() => _KioskMainPageState();
}

class _KioskMainPageState extends State<KioskMainPage> {
  @override
  void initState() {
    super.initState();
    Map<String, String> envVars = Platform.environment;
    var host = envVars['KIOSK_HOST'] ?? "http://localhost:8000";
    var apiToken = envVars['KIOSK_API_TOKEN'] ?? "";
    configureKiosk(host, apiToken);
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
          title: Text('UbuCon KR 체크인 키오스크'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fact_check,
                  size: 100.0,
                  semanticLabel: 'Text to announce in accessibility modes',
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "체크인 방법을 선택하세요",
                  style: TextStyle(fontSize: 40),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CheckInByBarcodeScreen()),
                          );
                        },
                        child: Text(
                          "QR 코드",
                          style: TextStyle(fontSize: 40),
                        ))),
                Container(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CheckInByEmailScreen()),
                          );
                        },
                        child: Text(
                          "E-Mail 주소",
                          style: TextStyle(fontSize: 40),
                        ))),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlinedButton(
                        onPressed: () {},
                        child: Text(
                          "관계자 호출 CALL STAFF",
                          style: TextStyle(fontSize: 30),
                        ))),
              ],
            )
          ],
        ));
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'checkInByEmailScreen.dart';
import 'checkInByBarcodeScreen.dart';
import 'package:yaru/yaru.dart';
import 'kioskclient.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

GlobalKey globalKey = GlobalKey();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var yaru = YaruThemeData(variant: YaruVariant.orange, useMaterial3: true);
    var yaruTheme = yaru.theme!;
    var yaruDarkTheme = yaru.darkTheme!;
    ThemeData customTheme = yaruTheme.copyWith(
        textTheme: GoogleFonts.nanumGothicTextTheme(),
        primaryTextTheme: GoogleFonts.nanumGothicTextTheme(),
        appBarTheme: yaruTheme.appBarTheme.copyWith(
            titleTextStyle:
                GoogleFonts.nanumGothic(color: Colors.black, fontSize: 20)),
        snackBarTheme: yaruTheme.snackBarTheme.copyWith(
            contentTextStyle: GoogleFonts.nanumGothic(color: Colors.white)));
    ThemeData customThemeDark = yaruDarkTheme.copyWith(
        textTheme: GoogleFonts.nanumGothicTextTheme(),
        primaryTextTheme: GoogleFonts.nanumGothicTextTheme(),
        appBarTheme: yaruDarkTheme.appBarTheme.copyWith(
            titleTextStyle:
                GoogleFonts.nanumGothic(color: Colors.white, fontSize: 20)),
        snackBarTheme: yaruDarkTheme.snackBarTheme.copyWith(
            contentTextStyle: GoogleFonts.nanumGothic(color: Colors.black)));
    return MaterialApp(
        theme: customTheme,
        darkTheme: customThemeDark,
        home: const KioskMainPage());
  }
}

class KioskMainPage extends StatefulWidget {
  const KioskMainPage({Key? key}) : super(key: key);
  @override
  _KioskMainPageState createState() => _KioskMainPageState();
}

class _KioskMainPageState extends State<KioskMainPage> {
  late KioskClient kioskClient;

  @override
  void initState() {
    super.initState();
    Map<String, String> envVars = Platform.environment;
    var host = envVars['KIOSK_HOST'] ?? "http://localhost:8000";
    var apiToken = envVars['KIOSK_API_TOKEN'] ?? "";
    configureKiosk(host, apiToken);
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
          title: Text('참석자 체크인 키오스크 Attendee Check-in Kiosk'),
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
                Card(
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      splashColor: Colors.orange.withAlpha(30),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const CheckInByBarcodeScreen()),
                        );
                      },
                      child: Container(
                          padding: const EdgeInsets.all(30.0),
                          child: Column(children: [
                            Icon(
                              Icons.qr_code_scanner,
                              size: 100.0,
                            ),
                            Text("QR 코드", style: TextStyle(fontSize: 40))
                          ])),
                    )),
                Card(
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      splashColor: Colors.orange.withAlpha(30),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const CheckInByEmailScreen()),
                        );
                      },
                      child: Container(
                          padding: const EdgeInsets.all(30.0),
                          child: Column(children: [
                            Icon(
                              Icons.email_outlined,
                              size: 100.0,
                            ),
                            Text("E-Mail 주소", style: TextStyle(fontSize: 40))
                          ])),
                    ))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlinedButton(
                        onPressed: () async {
                          await kioskClient.callStaff();
                          var resultSnackBar = SnackBar(
                            content: Text(
                                "행사 관계자를 호출 하였습니다. Event staff has been called."),
                          );
                          ScaffoldMessenger.of(context)
                              .showSnackBar(resultSnackBar);
                        },
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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'checkInByEmailScreen.dart';
import 'checkInByBarcodeScreen.dart';
import 'package:yaru/yaru.dart';
import 'kioskclient.dart';
import 'settings/settings.dart';
import 'package:google_fonts/google_fonts.dart';
import 'clockwidgets.dart';

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
            actions: <Widget>[
              IconButton(
                icon: const Icon(YaruIcons.settings),
                tooltip: '설정',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Settings()),
                  );
                },
              ),
            ]),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 1300, maxHeight: 200),
                    child: YaruBanner.tile(
                        surfaceTintColor: YaruColors.orange,
                        title: Text("환영합니다 | Welcome",
                            style: TextStyle(fontSize: 60)),
                        subtitle: Text("체크인 방법을 선택하세요 | Choose Check-in method",
                            style: TextStyle(fontSize: 30)),
                        icon: Icon(
                          YaruIcons.ubuntu_logo_large,
                          size: 120,
                        ))),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 650, maxHeight: 250),
                    child: YaruBanner.tile(
                      title: Text("QR 코드로 체크인", style: TextStyle(fontSize: 50)),
                      subtitle: Text("Check-in with QR Code",
                          style: TextStyle(fontSize: 25)),
                      icon: Icon(
                        Icons.qr_code,
                        size: 120,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const CheckInByBarcodeScreen()),
                        );
                      },
                    )),
                ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 650, maxHeight: 250),
                    child: YaruBanner.tile(
                      title:
                          Text("이메일 주소로 체크인", style: TextStyle(fontSize: 50)),
                      subtitle: Text("Check-in with E-Mail Address",
                          style: TextStyle(fontSize: 25)),
                      icon: Icon(
                        YaruIcons.mail_open,
                        size: 120,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const CheckInByEmailScreen()),
                        );
                      },
                    )),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 650, maxHeight: 150),
                    child: YaruBanner.tile(
                      title: ClockTimeWidget(
                        style: TextStyle(fontSize: 30),
                      ),
                      subtitle: ClockDateWidget(style: TextStyle(fontSize: 20)),
                      icon: Icon(
                        YaruIcons.clock,
                        size: 60,
                      ),
                    )),
                ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 650, maxHeight: 150),
                    child: YaruBanner.tile(
                      surfaceTintColor: YaruColors.orange,
                      title: Text("관계자 호출", style: TextStyle(fontSize: 30)),
                      subtitle:
                          Text("CALL STAFF", style: TextStyle(fontSize: 20)),
                      icon: Icon(
                        YaruIcons.light_bulb_on,
                        size: 60,
                      ),
                      onTap: () async {
                        await kioskClient.callStaff();
                        var resultSnackBar = SnackBar(
                          content: Text(
                              "행사 관계자를 호출 하였습니다. Event staff has been called."),
                        );
                        ScaffoldMessenger.of(context)
                            .showSnackBar(resultSnackBar);
                      },
                    )),
              ],
            )
          ],
        ));
  }
}

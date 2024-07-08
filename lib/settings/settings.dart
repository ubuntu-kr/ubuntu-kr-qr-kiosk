import 'package:flutter/material.dart';
import 'package:yaru/widgets.dart';
import 'wifiScreen.dart';
import 'printerChooser.dart';

class Settings extends StatelessWidget {
  const Settings({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정 Settings'),
      ),
      body: YaruMasterDetailPage(
        length: 2,
        tileBuilder: (context, index, selected, availableWidth) {
          if (index == 0) {
            return YaruMasterTile(title: Text('Wi-Fi Setup'));
          } else {
            return YaruMasterTile(title: Text('프린터 선택'));
          }
        },
        pageBuilder: (context, index) {
          if (index == 0) {
            return WifiScreen();
          } else {
            return PrinterChooser();
          }
        },
      ),
    );
  }
}

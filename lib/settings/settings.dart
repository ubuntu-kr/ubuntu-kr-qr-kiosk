import 'package:flutter/material.dart';
import 'package:yaru/widgets.dart';
import 'package:yaru/icons.dart';

import 'wifiScreen.dart';
import 'printerChooser.dart';

class Settings extends StatelessWidget {
  const Settings({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('설정 Settings'),
      // ),

      body: YaruMasterDetailPage(
        appBar: YaruWindowTitleBar(
          title: const Text('설정 Settings'),
          border: BorderSide.none,
          backgroundColor: YaruMasterDetailTheme.of(context).sideBarColor,
        ),
        bottomBar: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: YaruMasterTile(
            leading: const Icon(YaruIcons.arrow_left_outlined),
            title: const Text('닫기 Close'),
            onTap: () => Navigator.pop(context, 'Close'),
          ),
        ),
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

import 'package:flutter/material.dart';
import 'package:yaru/widgets.dart';
import 'package:yaru/icons.dart';

import 'wifiScreen.dart';
import 'printerChooser.dart';
import 'printLayout.dart';

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
        length: 3,
        tileBuilder: (context, index, selected, availableWidth) {
          switch (index) {
            case 0:
              return YaruMasterTile(title: Text('Wi-Fi Setup'));
            case 1:
              return YaruMasterTile(title: Text('프린터 선택'));
            default:
              return YaruMasterTile(title: Text('인쇄 레이아웃'));
          }
        },
        pageBuilder: (context, index) {
          switch (index) {
            case 0:
              return WifiScreen();
            case 1:
              return PrinterChooser();
            default:
              return PrintLayoutSettings();
          }
        },
      ),
    );
  }
}

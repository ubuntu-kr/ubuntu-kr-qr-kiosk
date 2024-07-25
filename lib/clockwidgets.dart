import 'dart:async';
import 'dart:io';
import 'package:yaru/yaru.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClockTimeWidget extends StatelessWidget {
  const ClockTimeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        return Text(DateFormat('hh:mm:ss a').format(DateTime.now()));
      },
    );
  }
}

class ClockDateWidget extends StatelessWidget {
  const ClockDateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        return Text(DateFormat('yyyy-MM-dd').format(DateTime.now()));
      },
    );
  }
}

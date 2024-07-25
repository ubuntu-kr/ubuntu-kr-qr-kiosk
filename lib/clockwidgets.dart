import 'dart:async';
import 'dart:io';
import 'package:yaru/yaru.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClockTimeWidget extends StatelessWidget {
  final TextStyle? style;
  const ClockTimeWidget({super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        return Text(DateFormat('hh:mm:ss a').format(DateTime.now()),
            style: style);
      },
    );
  }
}

class ClockDateWidget extends StatelessWidget {
  final TextStyle? style;
  const ClockDateWidget({super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        return Text(DateFormat('yyyy-MM-dd').format(DateTime.now()),
            style: style);
      },
    );
  }
}

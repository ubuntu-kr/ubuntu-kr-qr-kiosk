import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:yaru/yaru.dart';
import 'package:flutter/material.dart';
import 'kioskclient.dart';

class CheckInByEmailScreen extends StatefulWidget {
  const CheckInByEmailScreen({Key? key}) : super(key: key);
  @override
  _CheckInByEmailScreenState createState() => _CheckInByEmailScreenState();
}

class _CheckInByEmailScreenState extends State<CheckInByEmailScreen> {
  late KioskClient kioskClient;
  List searchResults = [
    {
      "id": 2,
      "name": "Youngbin Han",
      "email": "sukso96100@gmail.com",
      "affilation": "Ubuntu Korea",
      "role": "Organizer",
      "qrUrl": "https://discourse.ubuntu-kr.org/u/sukso96100"
    }
  ];
  var verifyCodeInput = "";
  var verifyCodeFinal = "";
  var showModalProgress = false;
  @override
  void initState() {
    super.initState();
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
  void didUpdateWidget(covariant CheckInByEmailScreen oldWidget) {
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
          title: Text('E-Mail 주소로 체크인'),
        ),
        body: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 500,
                      child: TextField(
                        style: TextStyle(fontSize: 30),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'E-Mail 주소 입력',
                        ),
                        onChanged: (text) async {
                          var result =
                              await kioskClient.searchByEmailKeyword(text);
                          setState(() {
                            searchResults = result.$2;
                          });
                        },
                      ),
                    ))
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: searchResults == null ? 0 : searchResults.length,
                  itemBuilder: (context, index) {
                    var resultItem = searchResults[index];
                    return ListTile(
                      title: Text(
                          '${resultItem["name"]} (${resultItem['email']})'),
                      onTap: () => {
                        showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                                  title: Text(resultItem['name']),
                                  content: Column(
                                    children: [
                                      Visibility(
                                          visible: showModalProgress,
                                          child: LinearProgressIndicator(
                                              value: null)),
                                      Text(resultItem['email']),
                                      Text(resultItem['affilation']),
                                      Text(resultItem['role']),
                                      TextField(
                                        readOnly: showModalProgress,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: '인증코드 입력',
                                        ),
                                        onChanged: (value) => {
                                          setState(() {
                                            verifyCodeInput = value;
                                          })
                                        },
                                      ),
                                    ],
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          verifyCodeInput = "";
                                        });
                                        Navigator.pop(context, 'Cancel');
                                      },
                                      child: const Text('취소 (X)'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        showDialog<String>(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (BuildContext context) =>
                                                AlertDialog(
                                                    content: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    CircularProgressIndicator(
                                                      value: null,
                                                    )
                                                  ],
                                                )));
                                        var result =
                                            await kioskClient.checkInBySearch(
                                                resultItem['id'],
                                                verifyCodeInput);
                                        setState(() {
                                          verifyCodeInput = "";
                                        });
                                        Navigator.pop(context, 'OK');
                                        Navigator.pop(context, 'OK');
                                        var snackBar = SnackBar(
                                          content: Text(result.$2),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                      },
                                      child: const Text('확인 (O)'),
                                    ),
                                  ],
                                ))
                      },
                    );
                  },
                ))
              ],
            )
          ],
        ));
  }
}

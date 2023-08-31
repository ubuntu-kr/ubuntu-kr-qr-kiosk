import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:yaru/yaru.dart';
import 'package:flutter/material.dart';

class CheckInByEmailScreen extends StatefulWidget {
  const CheckInByEmailScreen({Key? key}) : super(key: key);
  @override
  _CheckInByEmailScreenState createState() => _CheckInByEmailScreenState();
}

class _CheckInByEmailScreenState extends State<CheckInByEmailScreen> {
  @override
  void initState() {
    super.initState();

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
                      ),
                    ))
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: const <Widget>[
                      ListTile(
                        leading: Icon(Icons.map),
                        title: Text('Map'),
                      ),
                      ListTile(
                        leading: Icon(Icons.photo_album),
                        title: Text('Album'),
                      ),
                      ListTile(
                        leading: Icon(Icons.phone),
                        title: Text('Phone'),
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        ));
  }
}

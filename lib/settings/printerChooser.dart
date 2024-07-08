import 'package:flutter/material.dart';
import '../printclient.dart';

class PrinterChooser extends StatefulWidget {
  const PrinterChooser({Key? key}) : super(key: key);
  @override
  _PrinterChooserState createState() => _PrinterChooserState();
}

class _PrinterChooserState extends State<PrinterChooser> {
  double? scanProgress = 0.0;
  List<dynamic> printerList = [
    // {
    //   "manufacturerName": "HP",
    //   "productName": "LaserJet 2000",
    //   "vendorId": 0,
    //   "productId": 0
    // }
  ];
  @override
  void initState() {
    super.initState();
    scanPrinters().then((_) => print('printer scanned'));
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

  Future<void> scanPrinters() async {
    setState(() {
      scanProgress = null;
    });
    var scanResult = await getPrinterList();
    setState(() {
      printerList = scanResult;
      scanProgress = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('프린터 선택 (USB)'), actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'USB 장치 새로고침',
            onPressed: () async {
              await scanPrinters();
            },
          ),
        ]),
        body: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LinearProgressIndicator(value: scanProgress),
            Expanded(
                child: ListView.builder(
              itemCount: printerList == null ? 0 : printerList.length,
              itemBuilder: (context, index) {
                var resultItem = printerList[index];
                return Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 600),
                          child: ListTile(
                            title: Text(
                              "${resultItem["manufacturerName"]} ${resultItem["productName"]} (${resultItem["vendorId"]}, ${resultItem["productId"]})",
                              style: TextStyle(fontSize: 20),
                            ),
                            onTap: () {
                              // showAccessPointConnectDialog(context, resultItem);
                            },
                          ))
                    ]);
              },
            ))
          ],
        ));
  }
}

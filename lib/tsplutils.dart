import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

Uint8List buildBitmapPrintTsplCmd(int x, int y, int imgWidthPx, int imgHeightPx,
    int canvasWidthMm, int canvasHeightMm, Uint8List imageBitmap) {
  var widthInBytes = (imgWidthPx / 8).ceil();
  var cmddata = utf8.encode("SIZE $canvasWidthMm mm,$canvasHeightMm mm\r\n");
  cmddata += utf8.encode("CLS\r\n");
  cmddata += utf8.encode('BITMAP $x,$y,$widthInBytes,$imgHeightPx,1, ');
  cmddata += imageBitmap;
  cmddata += utf8.encode("\r\nPRINT 1\r\n");
  cmddata += utf8.encode("END\r\n");
  return Uint8List.fromList(cmddata);
}

Future<void> sendTsplData(
    Uint8List tsplData, int vendorId, int productId) async {
  var url = Uri.parse("http://0.0.0.0:5000/write_usb/$vendorId/$productId");

  var request = new http.Request("POST", url);
  print(tsplData);
  request.bodyBytes = tsplData;
  var response = await request.send();
}

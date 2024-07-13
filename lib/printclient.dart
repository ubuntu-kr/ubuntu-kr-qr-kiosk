import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<int> printImageToLabel(
    Uint8List imageUint8List, int vendorId, int productId) async {
  var prefs = await SharedPreferences.getInstance();
  var widthMm = prefs.getInt('printCanvasWidthMm') ?? 70;
  var heightMm = prefs.getInt('printCanvasHeightMm') ?? 70;
  var canvasDpi = prefs.getInt('printCanvasDpi') ?? 203;

  var url = Uri.parse(
      "http://0.0.0.0:5000/print/$vendorId/$productId?print_canvas_width_mm=$widthMm&print_canvas_height_mm=$heightMm&margin_top_px=0&margin_left_px=0&print_dpi=$canvasDpi");
  // imageToPrint to uint8list
  // var imgByteData = await imageToPrint.toByteData(format: ImageByteFormat.png);
  // var imageUnit8List = imgByteData!.buffer.asUint8List();
  // File origFile = File("./image_flutter.png")..writeAsBytesSync(imageUint8List);
  var multipartFile = http.MultipartFile.fromBytes("image", imageUint8List,
      filename: 'label.png', contentType: MediaType.parse('image/png'));
  var request = http.MultipartRequest("POST", url);
  // attach image file on multipart formadta
  request.files.add(multipartFile);

  var response = await request.send();
  return response.statusCode;
  // return 200;
}

Future<List<dynamic>> getPrinterList() async {
  var url = Uri.parse("http://0.0.0.0:5000/list");
  var response = await http.get(url);
  var jsonBody = jsonDecode(response.body) as List<dynamic>;
  return jsonBody;
}

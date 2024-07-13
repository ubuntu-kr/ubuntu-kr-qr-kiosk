import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

Future<int> printImageToLabel(
    Image imageToPrint, int vendorId, int productId) async {
  var url = Uri.parse(
      "http://0.0.0.0:5000/print/$vendorId/$productId?print_canvas_width_mm=70&print_canvas_height_mm=70&margin_top_px=0&margin_left_px=0&print_dpi=203");
  // imageToPrint to uint8list
  var img_byte_data =
      await imageToPrint.toByteData(format: ImageByteFormat.png);
  var image_uint8list = img_byte_data!.buffer.asUint8List();
  var multipartFile = http.MultipartFile.fromBytes("image", image_uint8list,
      filename: 'label.png', contentType: MediaType.parse('image/png'));
  var request = http.MultipartRequest("POST", url);
  // attach image file on multipart formadta
  request.files.add(multipartFile);
  var response = await request.send();
  return response.statusCode;
}

Future<List<dynamic>> getPrinterList() async {
  var url = Uri.parse("http://0.0.0.0:5000/list");
  var response = await http.get(url);
  var jsonBody = jsonDecode(response.body) as List<dynamic>;
  return jsonBody;
}

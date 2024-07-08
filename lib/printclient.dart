import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;

Future<int> printImageToLabel(
    Image imageToPrint, int vendorId, int productId) async {
  var url = Uri.parse("http://0.0.0.0:5000/print/$vendorId/$productId");
  // imageToPrint to uint8list
  var img_byte_data = await imageToPrint.toByteData();
  var image_uint8list = img_byte_data!.buffer.asUint8List();
  var multipartFile =
      await http.MultipartFile.fromBytes("image", image_uint8list);
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

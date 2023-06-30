import 'dart:typed_data';
import 'dart:ui';
import 'package:image/image.dart' as imglib;
import 'dart:ui' as ui;

Future<Uint8List> convertImageToMonochrome(ui.Image image) async {
  ByteData? byteData = await image.toByteData();
  var imglibImage = imglib.Image.fromBytes(
      image.width, image.height, byteData!.buffer.asUint8List());
  // var imglibImage = imglib.Image.fromBytes(
  //     width: image.width,
  //     height: image.height,
  //     bytes: byteData!.buffer,
  //     numChannels: 4);

  var widthInBytes = (imglibImage.width / 8).ceil();
  List<List<int>> imgData = List.filled(imglibImage.height, []);
  for (var y = 0; y < imglibImage.height; y++) {
    List<int> row = List.filled(widthInBytes, 0);
    for (var b = 0; b < widthInBytes; b++) {
      var byte = 0;
      var mask = 128;
      for (var x = b * 8; x < (b + 1) * 8; x++) {
        var lum = 255.0;
        try {
          var pix = Color(imglibImage.getPixel(x, y));
          lum = (0.2126 * pix.red) + (0.7152 * pix.green) + (0.0722 * pix.blue);
        } on RangeError {
          lum = 255.0;
        }
        if (lum > 160) byte = byte ^ mask; // empty dot (1)
        mask = mask >> 1;
      }

      row[b] = byte;
    }
    imgData[y] = row;
  }

  var flat = imgData.expand((i) => i).toList();

  return Uint8List.fromList(flat);
}

var greyScaleFilter = ColorFilter.matrix(<double>[
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
]);

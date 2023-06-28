import 'dart:typed_data';
import 'dart:convert';

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

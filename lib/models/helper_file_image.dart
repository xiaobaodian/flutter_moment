import 'dart:io';
import 'package:image/image.dart' as pimage;

Future<dynamic> decodeImageFile(String name) async {
  if (File(name).existsSync()) {
    return pimage.decodeImage(File(name).readAsBytesSync());
  }
  return null;
}
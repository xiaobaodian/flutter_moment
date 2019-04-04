import 'package:path_provider/path_provider.dart';

Future<String> getLocalPath() async {
  //getApplicationDocumentsDirectory()  getTemporaryDirectory()
  return (await getApplicationDocumentsDirectory()).path;
}

Future<String> getPersonPhotoPath(String id) async {
  String localPath = await getLocalPath();
  return '$localPath/Person-$id.png';
}
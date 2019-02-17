import 'package:path_provider/path_provider.dart';

Future<String> getLocalPath() async {
  //String dir = (await getApplicationDocumentsDirectory()).path;
  return (await getApplicationDocumentsDirectory()).path;
}

Future<String> getPersonPhotoPath(String id) async {
  String localPath = await getLocalPath();
  return '$localPath/Person-$id.png';
}
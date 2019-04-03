import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences(){
    init();
  }

  SharedPreferences prefs;

  Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

}
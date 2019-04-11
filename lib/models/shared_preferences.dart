import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences(){
    init();
  }

  SharedPreferences prefs;

  Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

  /// [detectFlags]自动提取人物位置标签
  bool get detectFlags => getBoolValue('DetectFlags', true);
  set detectFlags(bool value) => prefs.setBool('DetectFlags', value);

  /// [autoSave]自动保存
  bool get autoSave => getBoolValue('AutoSave', true);
  set autoSave(bool value) => prefs.setBool('AutoSave', value);

  /// bool类型参数的存取操作
  bool getBoolValue(String key, bool defaultValue) {
    bool value = prefs.getBool(key);
    if (value == null) {
      value = defaultValue;
      prefs.setBool(key, value);
    }
    return value;
  }

}
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences(){
    init();
  }

  SharedPreferences prefs;

  Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

  //Config

  String get upgradeConfigPath => getStringValue('UpgradeConfigPath', 'https://share.heiluo.com/share/download?type=1&shareId=ce2e6c74d2b0428f80ff8203b84b7379&fileId=2609208');
  set upgradeConfigPath(String value) => prefs.setString('UpgradeConfigPath', value);

  /// [upgradePath]自升级的路径
  String get upgradeAppPath => getStringValue('UpgradeAppPath', 'https://share.heiluo.com/share/download?type=1&shareId=e6414385ca4a48b98899a7d51ca29af7&fileId=2445569');
  set upgradeAppPath(String value) => prefs.setString('UpgradeAppPath', value);

  /// [detectFlags]自动提取人物位置标签
  bool get detectFlags => getBoolValue('DetectFlags', true);
  set detectFlags(bool value) => prefs.setBool('DetectFlags', value);

  /// [autoSave]自动保存
  bool get autoSave => getBoolValue('AutoSave', true);
  set autoSave(bool value) => prefs.setBool('AutoSave', value);

  /// [dailyReminders]每日提醒，预设值只取小时、分钟部分。
  String get dailyReminders => getStringValue('DailyReminders', '2019-04-17T20:30:00.000000');
  set dailyReminders(String value) => this.prefs.setString('DailyReminders', value);

  /// bool类型参数的存取操作
  bool getBoolValue(String key, bool defaultValue) {
    bool value = prefs.getBool(key);
    if (value == null) {
      value = defaultValue;
      prefs.setBool(key, value);
    }
    return value;
  }

  /// String类型参数的存取操作
  String getStringValue(String key, String defaultValue) {
    String value = prefs.getString(key);
    if (value == null) {
      value = defaultValue;
      prefs.setString(key, value);
    }
    return value;
  }

}
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences(){
    init();
  }

  SharedPreferences prefs;

  Future init() async {
    prefs = await SharedPreferences.getInstance();

    // 用于删除废弃的参数，以后去掉这个语句
    prefs.remove('dailyReminders');
  }

  //Config

  String get upgradeConfigPath => getStringValue('UpgradeConfigPath', 'https://share.heiluo.com/share/download?type=1&shareId=ce2e6c74d2b0428f80ff8203b84b7379&fileId=2609208');
  set upgradeConfigPath(String value) => prefs.setString('UpgradeConfigPath', value);

  /// [upgradePath]自升级的路径
  String get upgradeAppPath => getStringValue('UpgradeAppPath', 'https://share.heiluo.com/share/download?type=1&shareId=e6414385ca4a48b98899a7d51ca29af7&fileId=2445569');
  set upgradeAppPath(String value) => prefs.setString('UpgradeAppPath', value);

  /// [priorityDisplayOverdueTasks]优先显示逾期任务页面
  bool get priorityDisplayOverdueTasks => getBoolValue('PriorityDisplayOverdueTasks', true);
  set priorityDisplayOverdueTasks(bool value) => prefs.setBool('PriorityDisplayOverdueTasks', value);

  /// [saveCompleteTasks]优先显示逾期任务页面
  bool get saveCompleteTasks => getBoolValue('SaveCompleteTasks', true);
  set saveCompleteTasks(bool value) => prefs.setBool('SaveCompleteTasks', value);

  /// [detectFlags]自动提取人物位置标签
  bool get detectFlags => getBoolValue('DetectFlags', true);
  set detectFlags(bool value) => prefs.setBool('DetectFlags', value);

  /// [autoSave]自动保存
  bool get autoSave => getBoolValue('AutoSave', true);
  set autoSave(bool value) => prefs.setBool('AutoSave', value);

  /// [canDailyReminder]允许每日提醒
  bool get canDailyReminder => getBoolValue('CanDailyReminder', true);
  set canDailyReminder(bool value) => prefs.setBool('CanDailyReminder', value);

  /// [dailyReminderOne]每日提醒。设置值只取小时、分钟部分。
  String get dailyReminderOne => getStringValue('DailyReminders', '2019-04-17T20:30:00.000000');
  set dailyReminderOne(String value) => this.prefs.setString('DailyReminders', value);

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
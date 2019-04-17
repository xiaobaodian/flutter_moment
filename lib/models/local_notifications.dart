import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notifications {
  BuildContext context;
  var notifications = FlutterLocalNotificationsPlugin();

  void init(BuildContext context) {
    this.context = context;
    var initializationSettingsAndroid = AndroidInitializationSettings('time');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidRecieveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    notifications.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onDidRecieveLocalNotification(
      int id, String title, String body, String payload) async {}

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    //payload 可作为通知的一个标记，区分点击的通知。
    if (payload == "complete") {
      await Navigator.pushNamed(context, 'HomeScreen');
    }
  }

  Future showDailyAtTime(DateTime date) async {
    Time time = Time(date.hour, date.minute, 0);
    await notifications.cancel(11);

    //安卓的通知配置，必填参数是渠道id, 名称, 和描述, 可选填通知的图标，重要度等等。
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '11', 'MomentDailyNotification', '每天的定时通知',
        importance: Importance.Max, priority: Priority.High,
    );

    //IOS的通知配置
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    //显示通知，其中 21 代表通知的 id，用于区分通知。
    await notifications.showDailyAtTime(
        11,
        '时光',
        '开始记录你的美好时光吧',
        time,
        platformChannelSpecifics,
        payload: 'gotoMain'
    );
  }



  Future _showNotification() async {
    var scheduledNotificationDateTime =
        DateTime.now().add(new Duration(seconds: 10));

    var time = Time(9, 22, 0);

    //安卓的通知配置，必填参数是渠道id, 名称, 和描述, 可选填通知的图标，重要度等等。
//    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//        '21', 'MomentNotification21', '这是时光App的测试通知',
//        importance: Importance.Max, priority: Priority.High);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '21', 'MomentNotification31', '这是时光App的测试通知');

    //IOS的通知配置
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    //显示通知，其中 11 代表通知的 id，用于区分通知。
//    await notifications.show(
//        21,
//        '时光',
//        '吃货，准备吧！',
//        platformChannelSpecifics,
//        payload: 'complete'
//    );
    await notifications.schedule(
        21,
        '时光',
        '吃货，倒计时5秒',
        scheduledNotificationDateTime,
        platformChannelSpecifics
    );
//    await notifications.showDailyAtTime(
//        31,
//        '时光',
//        '开始记录你的美好时光吧',
//        time,
//        platformChannelSpecifics
//    );
  }

  //删除单个通知
  Future _cancelNotification() async {
    //参数 0 为需要删除的通知的id
    await notifications.cancel(0);
  }

//删除所有通知
  Future cancelAllNotifications() async {
    await notifications.cancelAll();
  }

  Future showNotification() async {
    await _showNotification();
  }
}

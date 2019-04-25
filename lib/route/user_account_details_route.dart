import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/widgets/cccat_divider_ext.dart';
import 'package:flutter_moment/widgets/cccat_list_tile.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class UserAccountRoute extends StatefulWidget {
  @override
  UserAccountRouteState createState() => UserAccountRouteState();
}

class UserAccountRouteState extends State<UserAccountRoute> {
  ModalRoute  currentRoute;
  GlobalStoreState _store;
  List<String> updatesTips = ['正在检测...','无法获取版本信息', '点击开始更新', '点击检查更新', '没有检测到更新'];
  int updatesState = 0;
  DateTime dailyReminderOne;
  String reminders;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = GlobalStore.of(context);
    reminders = _dailyReminderLabel();
    currentRoute = ModalRoute.of(context);
    checkUpgrade();
  }

  String _dailyReminderLabel() {
    String label;
    if (_store.prefs.canDailyReminder) {
      dailyReminderOne = DateTime.parse(_store.prefs.dailyReminderOne);
      String minuteLabel = dailyReminderOne.minute == 0 ? '00' : '${dailyReminderOne.minute}';
      label = '会在每天${dailyReminderOne.hour}:$minuteLabel提醒你记下美好时刻';
    } else {
      label = '建议打开每日提醒';
    }
    return label;
  }

  Future checkUpgrade() async {
    debugPrint('开始检查更新');
    await _store.initVersion();
    // 继续判断_store.appVersion是否为空，如果是，就说明网络问题，取不到数据
    if (_store.appVersion == null) {
      updatesState = 1;
    } else {
      if (updatesState == 0) {
        updatesState = _store.appVersion.hasUpgrade(_store) ? 2 : 3;
      } else {
        updatesState = _store.appVersion.hasUpgrade(_store) ? 2 : 4;
      }
    }
    if (currentRoute.isCurrent) {
      setState(() {
        debugPrint('updatesState = $updatesState');
      });
    } else {
      debugPrint('UserAccountRoute 已经关闭');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('账户'),
      ),
      body: buildBody(context, _store),
    );
  }

  Widget buildBody(BuildContext context, GlobalStoreState store) {
    const dividerHeight = 7.0;
    const dividerIndent = 48.0;
    const dividerThickness = 6.0;
    TextStyle subStyle = Theme.of(context).textTheme.caption.merge(TextStyle(
          fontSize: 12,
        ));
    reminders = _dailyReminderLabel();
    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 56,
                height: 56,
                child: CircleAvatar(
                  radius: 5,
                  backgroundImage: AssetImage('assets/image/xuelei01.jpg'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('账户名'),
                    Text('会员等级'),
                  ],
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: () {},
              ),
            ],
          ),
        ),
        DividerExt(height: dividerHeight, thickness: dividerThickness),
        CatListTile(
          title: Text('视图'),
          leading: Icon(Icons.view_agenda),
          trailing: Icon(Icons.chevron_right),
        ),
        DividerExt(height: dividerHeight, indent: dividerIndent),
        CatListTile(
          title: Text('每日提醒'),
          subtitle: Text(reminders,
            style: subStyle,
          ),
          leading: Icon(Icons.alarm),
          trailing: Switch(
            value: _store.prefs.canDailyReminder,
            onChanged: (value) {
              setState(() {
                _store.prefs.canDailyReminder = value;
                if (value) {
                  var date = DateTime.parse(_store.prefs.dailyReminderOne);
                  _store.notifications.setDailyReminderOneAtTime(date);
                } else {
                  _store.notifications.removeDailyReminderOne();
                }
              });
            },
          ),
          onTap: () {
            DatePicker.showTimePicker(context,
              locale: LocaleType.zh,
              showTitleActions: true,
              currentTime: dailyReminderOne,
              onConfirm: (time){
                dailyReminderOne = time;
                store.prefs.dailyReminderOne = time.toIso8601String();
                store.notifications.setDailyReminderOneAtTime(time);
                setState(() {
                  String minuteLabel = time.minute == 0 ? '00' : '${time.minute}';
                  reminders = '${time.hour}:$minuteLabel';
                });
              },
            );
          },
        ),
        DividerExt(height: dividerHeight, indent: dividerIndent),
        CatListTile(
          title: Text('照片'),
          subtitle: Text(
            '照片保存时的大小',
            style: subStyle,
          ),
          leading: Icon(Icons.photo),
          trailText: Text('中'),
          trailing: Icon(Icons.chevron_right),
        ),
        DividerExt(height: dividerHeight, indent: dividerIndent),
        CatListTile(
          title: Text('日历'),
          leading: Icon(Icons.calendar_today),
          trailing: Icon(Icons.chevron_right),
          onTap: () {

          },
        ),
        DividerExt(height: dividerHeight, indent: dividerIndent),
        CatListTile(
          title: Text('任务'),
          leading: Icon(Icons.assignment_turned_in),
          trailing: Icon(Icons.chevron_right),
          onTap: () {

          },
        ),
        DividerExt(height: dividerHeight, indent: dividerIndent),
        CatListTile(
          title: Text('提取标签'),
          subtitle: Text(
            '从正文中自动提取人物和位置标签',
            style: subStyle,
          ),
          leading: Icon(MdiIcons.tagMultiple),
          trailing: Switch(
            value: _store.prefs.detectFlags,
            onChanged: (value) {
              setState(() {
                _store.prefs.detectFlags = value;
              });
            },
          ),
        ),
        DividerExt(height: dividerHeight, indent: dividerIndent),
        CatListTile(
          title: Text('自动保存'),
          subtitle: Text(
            '编辑正文时，返回即保存内容',
            style: subStyle,
          ),
          leading: Icon(Icons.save),
          trailing: Switch(
            value: _store.prefs.autoSave,
            onChanged: (value) {
              setState(() {
                _store.prefs.autoSave = value;
              });
            },
          ),
        ),
        DividerExt(height: dividerHeight, thickness: dividerThickness),
        CatListTile(
          title: Text('语言'),
          subtitle: Text(
            '跟随系统语言',
            style: subStyle,
          ),
          leading: Icon(Icons.language),
          trailText: Text('简体中文'),
          trailing: Icon(Icons.chevron_right),
        ),
        DividerExt(height: dividerHeight, indent: dividerIndent),
        CatListTile(
          title: Text('帮助'),
          leading: Icon(Icons.help_outline),
          trailing: Icon(Icons.chevron_right),
        ),
        DividerExt(height: dividerHeight, thickness: dividerThickness),
        CatListTile(
          title: Text('版本'),
          subtitle: Text(updatesTips[updatesState], style: subStyle,),
          leading: Icon(Icons.update),
          trailing: updatesState == 2
              ? Text(
                  '发现新版本：${_store.appVersion.version} (${_store.appVersion.buildNumber})')
              : Text(
                  '${_store.packageInfo.version} (${_store.packageInfo.buildNumber})'),
          onTap: () {
            if (updatesState == 2) {
              store.appVersion.updates(context, store);
            } else {
              Fluttertoast.showToast(
                  msg: "开始检查更新...",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.yellow,
                  textColor: Colors.black45,
                  fontSize: 16.0
              );
              Future.delayed(Duration(seconds: 2), (){
                setState(() {
                  checkUpgrade();
                });
              });
            }
          },
          onLongPress: () async {
            await checkUpgrade();
            if (updatesState > 0) {
              await store.appVersion.cleanSaveDir();
              store.appVersion.updates(context, store);
            }
          },
        ),
        DividerExt(height: dividerHeight, indent: dividerIndent),
        CatListTile(
          title: Text('关于'),
          leading: Icon(Icons.child_care),
          trailing: Icon(Icons.chevron_right),
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AboutDialog(
                    applicationIcon:
                        Image.asset("assets/image/defaultPersonPhoto1.png"),
                    applicationName: '时光',
                    applicationVersion:
                        "${_store.packageInfo.version} (${_store.packageInfo.buildNumber})",
                    //applicationLegalese: '${_store.appVersion.title}',
                    children: <Widget>[
                      Divider(),
                      Text(
                          '${_store.androidInfo.brand} ${_store.androidInfo.model}'),
                      //Text("${_store.androidInfo.version}"),
                      //Text("${_store.androidInfo.device}"),
                      //Text("${_store.androidInfo.display}"),
                      //Text("${_store.androidInfo.board}"),
                      //Text("${_store.appVersion.appPath}"),
                    ],
                  );
                });
          },
        ),
      ],
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/widgets/cccat_divider_ext.dart';
import 'package:flutter_moment/widgets/cccat_list_tile.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserAccountRoute extends StatefulWidget {
  @override
  UserAccountRouteState createState() => UserAccountRouteState();
}

class UserAccountRouteState extends State<UserAccountRoute> {
  GlobalStoreState _store;
  String updatesTips;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = GlobalStore.of(context);
    updatesTips = _store.appVersion.needUpgrade ? '点击开始更新' : '点击检查更新';
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
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {},
          ),
          PopupMenuButton(
            onSelected: (int v) {
              if (v == 1) {
              } else if (v == 2) {}
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<int>>[
                PopupMenuItem(
                  value: 1,
                  child: CatListTile(
                    leading: Icon(Icons.edit),
                    leadingSpace: 24,
                    contentPadding: EdgeInsets.fromLTRB(8, 8, 0, 8),
                    title: Text('编辑'),
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  child: CatListTile(
                    leading: Icon(Icons.delete),
                    leadingSpace: 24,
                    contentPadding: EdgeInsets.fromLTRB(8, 8, 0, 8),
                    title: Text('删除'),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: buildBody(context, _store),
    );
  }

  Widget buildBody(BuildContext context, GlobalStoreState store) {
    const dividerHeight = 3.0;
    const dividerIndent = 48.0;
    const dividerThickness = 6.0;
    TextStyle subStyle = Theme.of(context).textTheme.caption.merge(TextStyle(
          fontSize: 12,
        ));
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
          title: Text('提醒'),
          leading: Icon(Icons.alarm),
          trailing: Icon(Icons.chevron_right),
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
            store.notifications.showNotification();
          },
        ),
        DividerExt(height: dividerHeight, indent: dividerIndent),
        CatListTile(
          title: Text('任务'),
          leading: Icon(Icons.assignment_turned_in),
          trailing: Icon(Icons.chevron_right),
          onTap: () {
            store.notifications.removeNotification();
          },
        ),
        DividerExt(height: dividerHeight, indent: dividerIndent),
        CatListTile(
          title: Text('提取标签'),
          subtitle: Text(
            '从正文中自动提取人物和位置标签',
            style: subStyle,
          ),
          leading: Icon(Icons.label_outline),
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
          subtitle:  Text(updatesTips, style: subStyle,),
          leading: Icon(Icons.update),
          trailing: store.appVersion.needUpgrade
              ? Text(
                  '发现新版本：${_store.appVersion.version} (${_store.appVersion.buildNumber})')
              : Text(
                  '${_store.packageInfo.version} (${_store.packageInfo.buildNumber})'),
          onTap: () {
            if (store.appVersion.needUpgrade) {
              store.appVersion.updates(context, store);
            } else {
              Fluttertoast.showToast(
                  msg: "开始检查更新...",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.yellow,
                  //textColor: Colors.white,
                  fontSize: 16.0
              );
              Future.delayed(Duration(seconds: 2), (){
                setState(() {
                  store.initVersion();
                  updatesTips = store.appVersion.needUpgrade? '点击开始更新' : '没有检测到更新';
                });
              });
            }
          },
          onLongPress: () async {
            if (store.appVersion == null) {
              await store.initVersion();
            }
            if (store.appVersion != null) {
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
                    applicationLegalese: '${_store.appVersion.title}',
                    children: <Widget>[
                      Divider(),
                      Text(
                          '${_store.androidInfo.brand} ${_store.androidInfo.model}'),
                      //Text("${_store.androidInfo.version}"),
                      //Text("${_store.androidInfo.device}"),
                      //Text("${_store.androidInfo.display}"),
                      Text("${_store.androidInfo.board}"),
                      Text("${_store.appVersion.path}"),
                    ],
                  );
                });
          },
        ),
      ],
    );
  }
}

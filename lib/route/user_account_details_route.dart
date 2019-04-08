import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moment/calendar_tools.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/models/models.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_data.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_widget.dart';
import 'package:flutter_moment/route/editer_focus_event_route.dart';
import 'package:flutter_moment/route/editer_focus_item_route.dart';
import 'package:flutter_moment/task/task_item.dart';
import 'package:flutter_moment/widgets/cccat_divider_ext.dart';
import 'package:flutter_moment/widgets/cccat_list_tile.dart';

class UserAccountRoute extends StatefulWidget {
  @override
  UserAccountRouteState createState() => UserAccountRouteState();
}

class UserAccountRouteState extends State<UserAccountRoute> {
  GlobalStoreState _store;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = GlobalStore.of(context);
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
    return ListView(
      children: <Widget>[
        ListTile(
          title: Text('视图'),
          leading: Icon(Icons.view_agenda),
          trailing: Icon(Icons.chevron_right),
        ),
        DividerExt(height: dividerHeight, thickness: dividerThickness),
        ListTile(
          title: Text('提醒'),
          leading: Icon(Icons.alarm),
          trailing: Icon(Icons.chevron_right),
        ),
        DividerExt(height: dividerHeight, indent: dividerIndent),
        ListTile(
          title: Text('照片'),
          leading: Icon(Icons.photo),
          trailing: Icon(Icons.chevron_right),
        ),
        DividerExt(height: dividerHeight, indent: dividerIndent),
        ListTile(
          title: Text('日历'),
          leading: Icon(Icons.calendar_today),
          trailing: Icon(Icons.chevron_right),
        ),
        DividerExt(height: dividerHeight, indent: dividerIndent),
        ListTile(
          title: Text('任务'),
          leading: Icon(Icons.work),
          trailing: Icon(Icons.chevron_right),
        ),
        DividerExt(height: dividerHeight, indent: dividerIndent),
        ListTile(
          title: Text('标签'),
          leading: Icon(Icons.label_outline),
          trailing: Icon(Icons.chevron_right),
        ),
        DividerExt(height: dividerHeight, thickness: dividerThickness),
        ListTile(
          title: Text('语言'),
          leading: Icon(Icons.language),
          trailing: Icon(Icons.chevron_right),
        ),
        DividerExt(height: dividerHeight, indent: dividerIndent),
        ListTile(
          title: Text('帮助'),
          leading: Icon(Icons.help_outline),
          trailing: Icon(Icons.chevron_right),
        ),
        DividerExt(height: dividerHeight, thickness: dividerThickness),
        ListTile(
          title: Text('版本'),
          leading: Icon(Icons.update),
          trailing: store.appVersion.needUpgrade
              ? Text('发现新版本：${_store.appVersion.buildNumber}')
              : Text('${_store.packageInfo.version} (${_store.packageInfo.buildNumber})'),
          onTap: (){
            if (store.appVersion.needUpgrade) {
              store.appVersion.updates(context, store);
            }
          },
        ),
        DividerExt(height: dividerHeight, indent: dividerIndent),
        ListTile(
          title: Text('关于'),
          leading: Icon(Icons.child_care),
          trailing: Icon(Icons.chevron_right),
          onTap: (){
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AboutDialog(
                  applicationIcon: Image.asset("assets/image/defaultPersonPhoto1.png"),
                  applicationName: '时光',
                  applicationVersion: "${_store.packageInfo.version} (${_store.packageInfo.buildNumber})",
                  applicationLegalese: '数据框架构成版',
                  children: <Widget>[
                    Divider(),
                    Text('${_store.androidInfo.brand} ${_store.androidInfo.model}'),
                    //Text("${_store.androidInfo.version}"),
                    //Text("${_store.androidInfo.device}"),
                    Text("${_store.androidInfo.display}"),
                    Text("${_store.androidInfo.board}"),
                  ],
                );
              }
            );
          },
        ),
      ],
    );
  }
}

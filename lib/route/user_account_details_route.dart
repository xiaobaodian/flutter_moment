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
        title: Text('任务'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.description),
            onPressed: (){
            },
          ),
          PopupMenuButton(
            onSelected: (int v){
              if (v == 1) {
              } else if (v == 2) {
              }
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
    store.taskSet.itemList.sort((a,b) => b.createDate.compareTo(a.createDate));
    return ListView.separated(
        itemCount: store.taskSet.itemList.length,
        itemBuilder: (context, index){
          var task = store.taskSet.itemList[index];
          print('task createDate: ${task.title} - ${task.createDate}');
          final date = store.calendarMap.getDateFromIndex(task.createDate);
          final str = DateTimeExt.chineseDateString(date);
          return ListTile(
            leading: SizedBox(
              width: 32,
              height: 32,
              child: Checkbox(
                  value: task.state == TaskState.Complete,
                  onChanged: (isSelected) {
                    setState(() {
                      task.state =
                      isSelected ? TaskState.Complete : TaskState.StandBy;
                      //store.changeTaskItem(task);
                      store.taskSet.changeItem(task);
                    });
                  }
              ),
            ),
            title: Text(task.title),
            subtitle: Text(str),
            isThreeLine: true,
            onTap: (){
              DailyRecord dailyRecord = store.getDailyRecordFormTask(task);
              FocusEvent focusEvent = store.getFocusEventFormTask(task);
              print('task focusitem id : ${task.focusItemId}');
              print('task dayIndex: ${task.createDate}');
              print('focusEvent dayIndex: ${focusEvent.dayIndex}');
              assert(dailyRecord != null);
              assert(focusEvent != null);
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return EditerFocusEventRoute(focusEvent);
              })).then((resultItem) {
                if (resultItem is PassingObject<FocusEvent>) {
                  dailyRecord.richLines.clear();
                  focusEvent = resultItem.newObject;
                  store.changeFocusEventAndTasks(resultItem);
                  //store.changeFocusEvent(event);
                } else if (resultItem is int) {
                  dailyRecord.richLines.clear();
                  store.removeFocusEventAndTasks(focusEvent);
                }
              });
            },
//          onLongPress: (){
//            store.taskSet.removeItem(task);
//          },
          );
        },
        separatorBuilder: (context, index){
          return Divider();
        }
    );
  }

}
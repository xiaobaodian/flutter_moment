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

class BrowseTaskCategoryRoute extends StatefulWidget {
  @override
  BrowseTaskCategoryRouteState createState() => BrowseTaskCategoryRouteState();
}

class BrowseTaskCategoryRouteState extends State<BrowseTaskCategoryRoute>
    with SingleTickerProviderStateMixin {
  GlobalStoreState _store;
  TabController _controller;
  final List<String> tabLabel = []; //'执行中', '已完成'

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = GlobalStore.of(context);
    _controller = TabController(
      initialIndex: 0,
      length: _store.taskCategories.allTasks.subNodes.length,
      vsync: this
    );
    _store.taskCategories.allTasks.subNodes.forEach((node){
      tabLabel.add(node.title);
    });
//    _store.taskSet.itemList.forEach((task){
//      debugPrint('开始分配任务');
//      _store.taskCategories.allTasks.assigned(task);
//    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('分类任务'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.description),
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
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 48,
            width: double.infinity,
            child: TabBar(
              controller: _controller,
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: tabLabel
                .map((label) => Text(label, style: TextStyle(fontSize: 17, color: Colors.black54)))
                .toList(),
            ),
          ),
          Divider(height: 1,),
          Expanded(
            child: buildBody(context, _store),
          ),
        ],
      ),
    );
  }

  // buildBody(context, _store)

  Widget buildBody(BuildContext context, GlobalStoreState store) {
    //store.taskSet.itemList.sort((a, b) => b.createDate.compareTo(a.createDate));
    return TabBarView(
      controller: _controller,
      children: <Widget>[
        ListView.separated(
          itemBuilder: (context, index) =>
              buildActionTaskItem(store, context, index),
          separatorBuilder: (context, index) => Divider(
                indent: 16,
                height: 8,
              ),
          itemCount: store.taskCategories.actionTasks.children.length,
        ),
        ListView.separated(
          itemBuilder: (context, index) =>
              buildCompleteTaskItem(store, context, index),
          separatorBuilder: (context, index) => Divider(
                indent: 70,
                height: 8,
              ),
          itemCount: store.taskCategories.completeTasks.children.length,
        ),
      ],
    );
  }

  Widget buildActionTaskItem(
      GlobalStoreState store, BuildContext context, int index) {
    TaskItem task = store.taskCategories.actionTasks.children[index];
    return buildTaskItem(store, context, task);
  }

  Widget buildCompleteTaskItem(
      GlobalStoreState store, BuildContext context, int index) {
    TaskItem task = store.taskCategories.completeTasks.children[index];
    return buildTaskItem(store, context, task);
  }

  Widget buildTaskItem(
      GlobalStoreState store, BuildContext context, TaskItem task) {
    final date = store.calendarMap.getDateFromIndex(task.createDate);
    final str = DateTimeExt.chineseDateString(date);
    return CatListTile(
      leading: SizedBox(
        width: 32,
        height: 32,
        child: Checkbox(
            value: task.state == TaskState.Complete,
            onChanged: (isSelected) {
              setState(() {
                task.state =
                    isSelected ? TaskState.Complete : TaskState.StandBy;
                store.taskSet.changeItem(task);
                store.taskCategories.allTasks.change(task);
              });
            }),
      ),
      title: Text(task.title),
      subtitle: Text(str),
      onTap: () {
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
  }
}

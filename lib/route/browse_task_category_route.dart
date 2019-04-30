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
import 'package:flutter_moment/task/tree_node.dart';
import 'package:flutter_moment/widgets/cccat_header_list_view.dart';
import 'package:flutter_moment/widgets/cccat_list_tile.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class BrowseTaskCategoryRoute extends StatefulWidget {
  @override
  BrowseTaskCategoryRouteState createState() => BrowseTaskCategoryRouteState();
}

class BrowseTaskCategoryRouteState extends State<BrowseTaskCategoryRoute>
    with SingleTickerProviderStateMixin {
  GlobalStoreState _store;
  TabController _controller;
  final List<String> tabLabel = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = GlobalStore.of(context);

    bool priorityDisplayOverdueTasks =
        _store.prefs.priorityDisplayOverdueTasks &&
            _store.taskCategories.lateTasks.childrenIsNotEmpty;

    _controller = TabController(
      initialIndex: priorityDisplayOverdueTasks ? 1 : 0,
      length: _store.taskCategories.allTasks.subNodes.length,
      vsync: this,
    );
    _store.taskCategories.allTasks.subNodes.forEach((node) {
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
        title: Text('任务'),
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
            height: 36,
            width: double.infinity,
            child: TabBar(
              controller: _controller,
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: tabLabel
                  .map((label) => Text(label,
                      style: TextStyle(fontSize: 17, color: Colors.black54)))
                  .toList(),
            ),
          ),
          Divider(
            height: 1,
          ),
          Expanded(
            child: buildBody(context, _store),
          ),
        ],
      ),
    );
  }

  // buildBody(context, _store)

  Widget buildBody(BuildContext context, GlobalStoreState store) {
    store.taskCategories
      ..actionTasks.children.sort((a, b) => a.dueDate.compareTo(b.dueDate))
      ..lateTasks.children.sort((a, b) => b.dueDate.compareTo(a.dueDate))
      ..completeTasks.children.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    return TabBarView(
      controller: _controller,
      children: <Widget>[
        CustomScrollView(
          slivers: _buildSlivers(context, _store.taskCategories.actionTasks),
        ),
        CustomScrollView(
          slivers: _buildSlivers(context, _store.taskCategories.lateTasks),
        ),
        CustomScrollView(
          slivers: _buildSlivers(context, _store.taskCategories.completeTasks),
        ),
      ],
    );
  }

  List<Widget> _buildSlivers(BuildContext context, TreeNode<TaskItem> node) {
    List<Widget> slivers = List<Widget>();
    for (int i = 0;
    i < node.subNodes.length;
    i++) {
      if (node.subNodes[i].children.isNotEmpty) {
        slivers.add(SliverStickyHeader(
          header: Container(
            height: 32.0,
            color: Color.fromARGB(254, 245, 245, 245),
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
              child: Text(
                node.subNodes[i].title,
                //style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => getTaskItem(context, node, i, index),
              childCount:
              node.subNodes[i].children.length,
            ),
          ),
        ));
      }
    }
    return slivers;
  }

  Widget getTaskItem(BuildContext context, TreeNode<TaskItem> node, int nodeIndex, int index) {
    TaskItem task = node.subNodes[nodeIndex].children[index];
    return buildTaskItem(_store, context, task);
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

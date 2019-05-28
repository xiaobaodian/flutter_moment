import 'package:flutter/material.dart';
import 'package:flutter_moment/calendar_tools.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/models/models.dart';
import 'package:flutter_moment/route/editer_focus_event_route.dart';
import 'package:flutter_moment/task/task_item.dart';
import 'package:flutter_moment/task/tree_node.dart';
import 'package:flutter_moment/widgets/cccat_list_tile.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HomeRoute extends StatefulWidget {
  HomeRoute(this.store);

  final GlobalStoreState store;

  @override
  HomeRouteState createState() => HomeRouteState();
}

class HomeRouteState extends State<HomeRoute> {
  final List<String> tabLabel = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var today = DateTime.now();
    var dateTitle = DateTimeExt.chineseDateString(today) +
        ' ' +
        DateTimeExt.chineseWeekName(today);
    return Scaffold(
      appBar: AppBar(
        title: Text(dateTitle),
        actions: <Widget>[
          IconButton(
            icon: Icon(MdiIcons.imageFilterDrama),
            onPressed: () {},
          ),
        ],
      ),
      body: buildBody(context, widget.store),
    );
  }

  // buildBody(context, _store)

  Widget buildBody(BuildContext context, GlobalStoreState store) {
    store.taskCategories
      ..actionTasks.children.sort((a, b) => a.dueDate.compareTo(b.dueDate))
      ..lateTasks.children.sort((a, b) => b.dueDate.compareTo(a.dueDate))
      ..completeTasks.children.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    return CustomScrollView(
      slivers: _buildSlivers(context),
    );
  }

  List<Widget> _buildSlivers(BuildContext context) {
    List<Widget> slivers = List<Widget>();
    int dailyLength = widget.store.dailyRecordSet.itemList.length;

    slivers.add(SliverToBoxAdapter(
      child: buildTaskCards(),
    ));
    slivers.add(SliverList(delegate: SliverChildBuilderDelegate(
      (context, index) => buildFocusEventItem(context, widget.store.dailyRecordSet.itemList[dailyLength - 1 - index]),
      childCount: dailyLength,
    )));
    return slivers;
  }

  Widget buildFocusEventItem(BuildContext context, DailyRecord dailyRecord) {
    widget.store.setFocusEventsToDailyRecord(dailyRecord);
    var date = widget.store.calendarMap.getDateFromIndex(dailyRecord.dayIndex);
    var dateTitle = DateTimeExt.chineseDateString(date);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(dateTitle),
        ),
        for ( var event in dailyRecord.focusEvents) Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text(widget.store.getFocusTitleBy(event.focusItemBoxId)),
                  Text('${event.noteLines[0].getContent()}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
          ),
        ),
        //for ( var event in dailyRecord.focusEvents) Text('${event.noteLines[0].getContent()}')
      ],
    );
  }

  Widget buildTaskCards() {
    return SizedBox(
      height: 146,
      width: double.infinity,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('逾期'),
              Card(
                color: Colors.red,
                child: SizedBox(
                  height: 104,
                  width: 260,
                  child: Text('aaaa'),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('执行'),
              Card(
                color: Colors.amberAccent,
                child: SizedBox(
                  height: 104,
                  width: 200,
                  child: Text('bbbbbb'),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('待定'),
              Card(
                color: Colors.blue,
                child: SizedBox(
                  height: 104,
                  width: 200,
                  child: Text('cccccc'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

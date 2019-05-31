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
  final Color cardColor = Color.fromARGB(254, 248, 248, 246);
  //final Color timeLineColor = Color.fromARGB(254, 230, 230, 230);
  final Color timeLineColor = Color.fromARGB(254, 253, 205, 0);
  final double timeLineLeft = 16;

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
    var dateTitle = DateTimeExt.chineseDateString(today, isShort: false) +
        ' ' +
        DateTimeExt.chineseWeekName(today);
    return Scaffold(
      backgroundColor: Color.fromARGB(254, 253, 255, 253),
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
      child: _buildTaskCards(),
    ));
    slivers.add(SliverToBoxAdapter(
      child: SizedBox(height: 16,),
    ));
    slivers.add(SliverList(
        delegate: SliverChildBuilderDelegate(
      (context, index) => buildFocusEventItem(
          widget.store.dailyRecordSet.itemList[dailyLength - 1 - index]),
      childCount: dailyLength,
    )));
    slivers.add(SliverToBoxAdapter(
      child: Row(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: widget.timeLineColor,
              borderRadius: BorderRadiusDirectional.horizontal(
                end: Radius.circular(6),
              )
            ),
            padding: EdgeInsets.all(4),
            width: 30,
            child: Text('End',
              style: TextStyle(
                color: Colors.black45,
              fontSize: 10),
            ),
          ),
          Expanded(
            child: Text(''),
          )
        ],
      ),
    ));
    return slivers;
  }

  Widget _buildEventItem(FocusEvent event, BoxDecoration boxDecoration) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.fromLTRB(widget.timeLineLeft, 0, 0, 0),
          decoration: boxDecoration,
          child: SizedBox(height: 8),
        ),
        Stack(
          alignment: AlignmentDirectional.centerStart,
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(widget.timeLineLeft, 0, 0, 0),
              padding: EdgeInsets.fromLTRB(16, 4, 8, 4),
              decoration: boxDecoration,
              child: Text(
                widget.store.getFocusTitleBy(event.focusItemBoxId),
                style: Theme.of(context).textTheme.body1.merge(TextStyle(fontWeight: FontWeight.bold)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Positioned(
              left: widget.timeLineLeft - 5.5,
              //top: 21,
              child: Icon(
                MdiIcons.brightness1,
                size: 12,
                color: widget.timeLineColor,
              )
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.fromLTRB(widget.timeLineLeft, 0, 0, 0),
          padding: EdgeInsets.fromLTRB(16, 8, 8, 0),
          decoration: boxDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (var line in event.noteLines) Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 6),
                child: Text(
                  '${line.getContent()}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.body1,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget buildFocusEventItem(DailyRecord dailyRecord) {
    widget.store.setFocusEventsToDailyRecord(dailyRecord);
    //var date = widget.store.calendarMap.getDateFromIndex(dailyRecord.dayIndex);
    //var dateTitle = DateTimeExt.chineseDateString(date);
    var dateTitle = widget.store.timeLineTools.getDateTitle(dailyRecord.dayIndex, hasWeekTitle: true);
    var boxDecoration = BoxDecoration(
        border: BorderDirectional(
            start: BorderSide(
      color: widget.timeLineColor,
      width: 1,
      style: BorderStyle.solid,
    )));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // 每天的日期标题
        Container(
          padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
          decoration: BoxDecoration(
            color: widget.timeLineColor,
            borderRadius: BorderRadiusDirectional.horizontal(
              end: Radius.circular(8),
            ),
//            boxShadow: [
//              BoxShadow(
//                color: Colors.black12,
//                offset: Offset(1.0, 3.0),
//                blurRadius: 6.0,
//                spreadRadius: 1.0
//              )
//            ]
          ),
          child: Text(
            dateTitle,
            style: TextStyle(
              //color: Colors.white,
              fontSize: 10,
            ),
          ),
        ),
        // 标题下面的空行
        Container(
          margin: EdgeInsets.fromLTRB(widget.timeLineLeft, 0, 0, 0),
          padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
          decoration: boxDecoration,
          child: SizedBox(height: 6),
        ),
        for (var event in dailyRecord.focusEvents) _buildEventItem(event, boxDecoration),
        Container(
          margin: EdgeInsets.fromLTRB(widget.timeLineLeft, 0, 0, 0),
          padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
          decoration: boxDecoration,
          child: SizedBox(height: 16),
        ),
        //for ( var event in dailyRecord.focusEvents) Text('${event.noteLines[0].getContent()}')
      ],
    );
  }

  Widget _getTaskLine(String title) {
    return Text('□ $title',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTaskLine(List<TaskItem> items) {
    if (items.length == 0) {
      return Center(child: Text('没有任务'));
    } else if (items.length <= 4) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (var item in items) _getTaskLine(item.title)
        ],
      );
    }
    int ys = items.length - 3;
    List<TaskItem> subItems = [];
    subItems.add(items[0]);
    subItems.add(items[1]);
    subItems.add(items[2]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (var item in subItems) _getTaskLine(item.title),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
          child: Center(
            child: Text('还有 $ys 条任务',
              style: Theme.of(context).textTheme.caption,
              textAlign: TextAlign.end,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCards() {
    List<TaskItem> lateItems = widget.store.taskCategories.lateTasks.getChildren();
    List<TaskItem> actionItems = widget.store.taskCategories.actionTasks.getChildren();
    //List<TaskItem> lateItems = widget.store.taskCategories.lateTasks.getChildren();

    Color cardColor = Color.fromARGB(254, 248, 248, 246);

    return SizedBox(
      height: 146,
      width: double.infinity,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 0 ,0),
                child: Text('逾期', style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              Card(
                color: cardColor,
                elevation: 0,
                child: SizedBox(
                  height: 104,
                  width: 260,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildTaskLine(lateItems),
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 0 ,0),
                child: Text('执行', style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              Card(
                color: cardColor,
                elevation: 0,
                child: SizedBox(
                  height: 104,
                  width: 200,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildTaskLine(actionItems),
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 0 ,0),
                child: Text('待定', style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              Card(
                color: cardColor,
                elevation: 0,
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

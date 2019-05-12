import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_moment/calendar_map.dart';
import 'package:flutter_moment/calendar_tools.dart';
import 'package:flutter_moment/global_store.dart';

class CalendarRoute extends StatefulWidget {
  @override
  CalendarRouteState createState() => CalendarRouteState();
}

class CalendarRouteState extends State<CalendarRoute> {
  final DateTime today = DateTime.now();
//
  static int currentYear;
  static int firstItemYear;
//  static int weekLines = 0;
//
//  Map<String, double> monthsOffset;
//  List<DateIndex> dateIndex;

  //-------------------------------------
  CalendarMap calendarMap;

  ScrollController _controller;
  double calendarCellWidth;

  String calendarTitle;

  @override
  void initState() {
    super.initState();
//    CalendarState.currentYear = this.today.year;
//    CalendarState.firstItemYear = this.today.year;
//    calendarTitle = ('${CalendarState.currentYear}年');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    calendarCellWidth = MediaQuery.of(context).size.width / 7;
    calendarMap = GlobalStore.of(context).calendarMap;
    calendarTitle = ('${calendarMap.selectedDate.year}年');
    _controller = ScrollController(
      initialScrollOffset: calendarMap.selectedDayOffset,
    );
    _controller.addListener(() {
      if (CalendarRouteState.currentYear != 0) {
        setCalendarTitle();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void setCalendarTitle({int year}) {
    if (year != null) {
      setState(() {
        calendarTitle = ('$year年');
      });
    } else if (CalendarRouteState.currentYear !=
        CalendarRouteState.firstItemYear) {
      CalendarRouteState.currentYear = CalendarRouteState.firstItemYear;
      setState(() {
        calendarTitle = ('${CalendarRouteState.currentYear}年');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(calendarTitle),
        bottom: getMonthWeekTitle(),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.today),
            // 返回当前日期，需要设置CalendarState.currentYear = 0，这样在_controller.addListener和
            // CalendarChildDelegate获取屏幕第一条item时就暂停处理，不然会因为动画延时导致年份显示不正确。
            // 然后通过延时（这样贴合动态效果）直接设置年份标题为当前，并将设置CalendarState.currentYear
            // 恢复为当前年份，_controller.addListener和CalendarChildDelegate就在执行中恢复了正常处理
            onPressed: () {
              CalendarRouteState.firstItemYear = 0;
              CalendarRouteState.currentYear = 0;
              _controller.animateTo(calendarMap.todayOffset,
                  duration: Duration(milliseconds: 150), curve: Curves.easeIn);
              Future.delayed(const Duration(milliseconds: 250), () {
                setCalendarTitle(year: today.year);
                CalendarRouteState.currentYear = today.year;
                CalendarRouteState.firstItemYear = today.year;
              });
            },
          ),
        ],
      ),
      body: ListView.custom(
        controller: _controller,
        cacheExtent: 0.0,
        itemExtent:
            calendarMap.monthBoxCellHeight, // CalendarState.monthBoxCellHeight,
        childrenDelegate: CalendarChildDelegate(
          (context, index) {
            return getWeekLineTable(calendarMap.everyWeekIndex[index]);
          },
          childCount: calendarMap.weeksTotal,
          calendarMap: calendarMap,
        ),
      ),
    );
  }

  Widget getMonthWeekTitle() {
    return PreferredSize(
      preferredSize: Size(double.infinity, 50),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _getWeekTitleWidgets(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getWeekTitleWidgets() {
    List<Widget> widgets = [];
    const titles = ['一', '二', '三', '四', '五', '六', '日'];
    for (int i = 0; i < titles.length; i++) {
      widgets.add(SizedBox(
        width: 24,
        height: 16,
        child: Text(
          titles[i],
          textAlign: TextAlign.center,
          style: TextStyle(color: i < 5 ? Colors.white : Colors.white70),
        ),
      ));
    }
    return widgets;
  }

  Widget getWeekLineTable(WeekProperty weekIndex) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Table(
        columnWidths: <int, TableColumnWidth>{
          0: FixedColumnWidth(calendarCellWidth),
          1: FixedColumnWidth(calendarCellWidth),
          2: FixedColumnWidth(calendarCellWidth),
          3: FixedColumnWidth(calendarCellWidth),
          4: FixedColumnWidth(calendarCellWidth),
          5: FixedColumnWidth(calendarCellWidth),
          6: FixedColumnWidth(calendarCellWidth),
        },
        //border: TableBorder.all(color: Colors.black12, width: 1.0, style: BorderStyle.solid),
        children: getWeekLineFrom(weekIndex),
      ),
    );
  }

  List<TableRow> getWeekLineFrom(WeekProperty weekIndex) {
    var dateExt = DateTimeExt(weekIndex.date());
    var rows = List<TableRow>();
    if (weekIndex.weeks == 0) {
      var monthTitle = List<Widget>();
      for (int i = 1; i < 8; i++) {
        if (i == dateExt.firstWeekDayOfMonth) {
          monthTitle.add(SizedBox(
            width: calendarCellWidth,
            height: calendarMap.monthBoxTitleHeight,
            child: Container(
              //color: Colors.blue,
              alignment: Alignment.bottomCenter,
              child: Text(
                '${weekIndex.month}月',
                style: Theme.of(context).textTheme.subhead,
              ),
            ),
          ));
        } else {
          monthTitle.add(Text(''));
        }
      }
      rows.add(TableRow(
        children: monthTitle,
      ));
    } else {
      rows.add(TableRow(
        children: getWeekOfMonth(dateExt, weekIndex.weeks),
      ));
    }
    return rows;
  }

  List<Widget> getWeekOfMonth(DateTimeExt datetime, int weekIndex) {
    var days = datetime.getDaysOfWeek(weekIndex);
    var weekDaysWidget = List<Widget>();
    days.forEach((day) {
      weekDaysWidget.add(getDayCell(day));
    });
    return weekDaysWidget;
  }

  Widget getDayWidget(DateTime date) {
    if (date == null) {
      return Text('');
    }

    List<Widget> widgets = [];
    ThemeData themeData = Theme.of(context);

    if (calendarMap.isSelectedDate(date)) {
      widgets.add(CircleAvatar(
        backgroundColor: Colors.black12,
      ));
    }

    if (calendarMap.isToday(date)) {
      widgets.add(Text(
        date.day.toString(),
        style: TextStyle(
          color: themeData.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ));
      widgets.add(Padding(
        padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
        child: Text(
          '今天',
          style: TextStyle(
            color: themeData.primaryColor,
            fontSize: 9,
          ),
        ),
      ));
    } else {
      widgets.add(Text(
        date.day.toString(),
        style:
            TextStyle(color: date.weekday < 6 ? Colors.black : Colors.black54),
      ));
    }

    if (calendarMap.hasDailyRecord(date)) {
      widgets.add(Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 25),
        child: CircleAvatar(
          backgroundColor: Colors.black12,  //themeData.primaryColor
          radius: 3,
        ),
      ));
    }

    return SizedBox(
      height: calendarCellWidth,
      width: calendarCellWidth,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: widgets,
      ),
    );
  }

  Widget getDayCell(DateTime day) {
    return InkWell(
      child: SizedBox(
          width: calendarCellWidth,
          height: calendarMap.monthBoxCellHeight,
          child: Container(
            padding: EdgeInsets.all(3),
            alignment: Alignment.center,
            child: getDayWidget(day),
          )),
      onTap: () {
        Navigator.pop(context, day);
      },
    );
  }
}

class DateIndex {
  int year, month, weekIndex;
  DateIndex(this.year, this.month, this.weekIndex);
  DateTime date() {
    return DateTime(year, month);
  }
}

class CalendarChildDelegate extends SliverChildBuilderDelegate {
  CalendarMap calendarMap;

  CalendarChildDelegate(
    Widget Function(BuildContext, int) builder, {
    int childCount,
    bool addAutomaticKeepAlive = true,
    bool addRepaintBoundaries = true,
    CalendarMap calendarMap,
  }) : super(builder,
            childCount: childCount,
            addAutomaticKeepAlives: addAutomaticKeepAlive,
            addRepaintBoundaries: addRepaintBoundaries) {
    this.calendarMap = calendarMap;
  }

//  @override
//  Widget build(BuildContext context, int index) {
//    return calendarState.getWeekLineTable(calendarState.dateIndex[index]);
//  }

  @override
  void didFinishLayout(int firstIndex, int lastIndex) {
    if (CalendarRouteState.firstItemYear != 0) {
      CalendarRouteState.firstItemYear =
          calendarMap.everyWeekIndex[firstIndex].year;
    }
  }

//  @override
//  bool shouldRebuild(SliverChildDelegate oldDelegate) {
//    return true;
//  }

//  @override
//  int get childCount => CalendarState.weekLines;

}

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_moment/launch_page.dart';
import 'package:flutter_moment/calendar_map.dart';
import 'package:flutter_moment/calendar_tools.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/models/models.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_data.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_widget.dart';
import 'package:flutter_moment/route/browse_task_category_route.dart';
import 'package:flutter_moment/route/calendar_route.dart';
import 'package:flutter_moment/route/details_focus_item_route.dart';
import 'package:flutter_moment/route/editer_focus_event_route.dart';
import 'package:flutter_moment/route/browse_daily_focus_route.dart';
import 'package:flutter_moment/route/user_account_details_route.dart';
import 'package:flutter_moment/widgets/trim_picture_dialog.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

void main() => runApp(GlobalStore(child: MyApp()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('zh', 'CH'),
        const Locale('en', 'US'),
      ],
      title: 'Today focus',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LaunchPage(),
      routes: <String, WidgetBuilder>{
        'HomeScreen': (_) => HomeScreen(),
        'UserAccount': (_) => UserAccountRoute(),
        'CalendarRoute': (_) => CalendarRoute(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  //final homeStateKey = GlobalKey<_HomeScreenState>();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalStoreState _store;
  CalendarMap _calendarMap;
  bool hideGoTodayButton;
  bool firstReminderUpgrade;

  //ScrollController _scrollController;
  PageController _pageController;
  PageStorageBucket _pageStorageBucket;

  @override
  void initState() {
    super.initState();
    //恢复状态栏和虚拟导航栏显示
    //SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    //SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top, SystemUiOverlay.bottom]);
    hideGoTodayButton = true;
    firstReminderUpgrade = true;
  }

  @override
  Future didChangeDependencies() async {
    super.didChangeDependencies();
    _store = GlobalStore.of(context);
    _calendarMap = _store.calendarMap;
    _pageController = PageController(
      initialPage: _calendarMap.getDateIndex(),
      //viewportFraction: 0.8,
    );
    _pageStorageBucket = PageStorageBucket();
    _store.notifications.init(context);

    if (_store.appVersion == null) {
      await _store.initVersion();
    }
    // 如果_store.appVersion继续为空，说明网络有问题
    if (_store.appVersion != null) {
      if (_store.appVersion.hasUpgrade(_store) && firstReminderUpgrade) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('有新的版本发布'),
        ));
        firstReminderUpgrade = false;
      }
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    debugPrint('退出了主页 ！！！');
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint('退出了这个App ！！！');
    _store.dataSource.closeDataBase();
  }

  void jumpToCurrentPage() {
    setState(() {
      _pageController.animateToPage(_calendarMap.currentDateIndexed,
          duration: Duration(milliseconds: 250), curve: Curves.ease);
    });
  }

  void jumpToSelectedPage() {
    setState(() {
      _pageController.animateToPage(_calendarMap.selectedDateIndex,
          duration: Duration(milliseconds: 250), curve: Curves.ease);
    });
  }

  int buildDailyEventNote(DailyRecord dailyRecord) {
    dailyRecord.buildRichList(_store, true);
    return dailyRecord.richLines.length;
  }

  Widget drawerHeaderChild(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 90,
              height: 90,
              child: CircleAvatar(
                radius: 5,
                backgroundImage: AssetImage('assets/image/xuelei01.jpg'),
                //child: Text('雪嫘'),
              ),
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.settings),
              color: Colors.white,
              onPressed: () {
                Navigator.of(context).pushNamed('UserAccount');
              },
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Text(
              '白金会员',
              style: Theme.of(context)
                  .textTheme
                  .body1
                  .merge(TextStyle(color: Colors.white)),
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        debugPrint('退出了主页');
        await _store.dataSource.closeDataBase();
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: drawerHeaderChild(context),
              ),
              ListTile(
                leading: Icon(Icons.assignment_turned_in),
                title: Text(
                  '任务',
                  style: TextStyle(fontSize: 18),
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  var navigator = Navigator.of(context);
                  navigator.pop(context);
                  navigator
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return BrowseTaskCategoryRoute(_store);
                    //return BrowseTaskRoute();
                  }));
                },
              ),
              Divider(
                height: 3,
              ),
              ListTile(
                leading: Icon(Icons.filter_center_focus),
                title: Text(
                  '焦点',
                  style: TextStyle(fontSize: 18),
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  var navigator = Navigator.of(context);
                  navigator.pop(context);
                  navigator
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return BrowseDailyFocusRoute(0);
                  }));
                },
              ),
              ListTile(
                leading: Icon(Icons.people),
                title: Text(
                  '人物',
                  style: TextStyle(fontSize: 18),
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  var navigator = Navigator.of(context);
                  navigator.pop(context);
                  navigator
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return BrowseDailyFocusRoute(1);
                  }));
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text(
                  '相片',
                  style: TextStyle(fontSize: 18),
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  var navigator = Navigator.of(context);
                  navigator.pop(context);
                  navigator
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return BrowseDailyFocusRoute(4);
                  }));
                },
              ),
              ListTile(
                leading: Icon(MdiIcons.mapMarkerMultiple),
                title: Text(
                  '位置',
                  style: TextStyle(fontSize: 18),
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  var navigator = Navigator.of(context);
                  navigator.pop(context);
                  navigator
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return BrowseDailyFocusRoute(2);
                  }));
                },
              ),
              ListTile(
                leading: Icon(MdiIcons.tagMultiple),
                title: Text(
                  '标签',
                  style: TextStyle(fontSize: 18),
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  var navigator = Navigator.of(context);
                  navigator.pop(context);
                  navigator
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return BrowseDailyFocusRoute(3);
                  }));
                },
              ),
              Divider(
                height: 3,
              ),
              ListTile(
                leading: Icon(Icons.child_care),
                title: Text(
                  '消息',
                  style: TextStyle(fontSize: 18),
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  //TrimPicture
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: Text('时光'),
          actions: <Widget>[
            Offstage(
              offstage: hideGoTodayButton,
              child: IconButton(
                icon: Icon(Icons.trip_origin),
                onPressed: () {
                  jumpToCurrentPage();
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.today),
              onPressed: () {
                Navigator.of(context).pushNamed('CalendarRoute').then((day) {
                  if (day != null) {
                    if (_calendarMap.isNotSelectedDate(day)) {
                      _calendarMap.selectedDate = day;
                      jumpToSelectedPage();
                    }
                  }
                });
              },
            )
          ],
        ),
        body: PageStorage(
          bucket: _pageStorageBucket,
          child: PageView.builder(
            controller: _pageController,
            itemBuilder: (context, index) {
              var dailyRecord = _store.getDailyRecordOrNull(index);
              if (dailyRecord != null) {
                if (dailyRecord.focusEventsIsNull) {
                  _store.setFocusEventsToDailyRecord(dailyRecord);
                  buildDailyEventNote(dailyRecord);
                } else {
                  if (dailyRecord.richLines == null ||
                      dailyRecord.richLines.isEmpty) {
                    buildDailyEventNote(dailyRecord);
                  }
                }
              }
              return getDayNote(context, index);
            },
            itemCount: _calendarMap.daysTotal,
            onPageChanged: (index) {
              _calendarMap.setSelectedDateFromIndex(index);
              if (_calendarMap.currentDateIndexed == index) {
                setState(() {
                  hideGoTodayButton = true;
                });
              } else {
                if (hideGoTodayButton != false) {
                  setState(() {
                    hideGoTodayButton = false;
                  });
                }
              }
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            var events = _store.getFocusEventsFromSelectedDay();
            var list = List<FocusItem>();
            if (events.length == 0) {
              list.addAll(_store.focusItemSet.itemList);
            } else {
              _store.focusItemSet.itemList.forEach((focus) {
                if (!events
                    .any((event) => event.focusItemBoxId == focus.boxId)) {
                  list.add(focus);
                }
              });
            }
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return _buildFocusModelSheet(_store, list);
              },
            );
          },
          child: Icon(Icons.edit),
        ),
      ),
    );
  }
}

Widget getDayNote(BuildContext context, int index) {
  CalendarMap calendarMap = GlobalStore.of(context).calendarMap;
  DateTime date = calendarMap.everyDayIndex[index].date();
  return Column(
    children: <Widget>[
      _getDateHeader(context, index, date),
      Expanded(
        child: _getListView(context, index),
      ),
    ],
  );
}

Widget _getDateHeader(BuildContext context, int index, DateTime date) {
  var map = GlobalStore.of(context).calendarMap;
  String dayLeap = map.getChineseTermOfRecentDay(index);
  return Container(
    padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
//      gradient: LinearGradient(colors: <Color>[
//        Colors.white,
//        Colors.yellow,
//      ]),
      border: BorderDirectional(
          bottom: BorderSide(color: Colors.black26, width: 0.5)),
    ),
    alignment: Alignment.center,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
//        SizedBox(
//          height: 20,
//          child: ColorizeAnimatedTextKit(
//            text: ["${date.year}年${date.month}月${date.day}日", "${DateTimeExt.chineseWeekName(date, longName: true)}",],
//            colors: [
//              Colors.purple,
//              Colors.blue,
//              Colors.yellow,
//              Colors.red,
//            ],
//            textStyle: TextStyle(fontSize: 14.0, fontFamily: "Horizon"),
//            textAlign: TextAlign.start,
//            alignment: AlignmentDirectional.topStart,
//          ),
//        ),
        Text(
          '${date.year}年${date.month}月${date.day}日 - ${DateTimeExt.chineseWeekName(date, longName: true)}',
          style: TextStyle(
            fontSize: 14.0,
          ),
        ),
        Text(
          '$dayLeap',
          style: TextStyle(
            fontSize: 14.0,
          ),
        ),
      ],
    ),
  );
}

Widget _buildFocusModelSheet(
    GlobalStoreState store, List<FocusItem> usableList) {
  final dailyRecord = store.calendarMap.getDailyRecordFromSelectedDay();
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
        child: Text('准备记录的关注点'),
      ),
      Divider(
        height: 12,
      ),
      Expanded(
        child: ListView.builder(
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(MdiIcons.accountStarOutline),
              title: Text(usableList[index].title),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return EditerFocusEventRoute(store, FocusEvent(
                    dayIndex: store.selectedDateIndex,
                    focusItemBoxId: usableList[index].boxId,
                  ));
                })).then((resultItem) {
                  debugPrint(
                      'resultItem is null: ${resultItem == null} , resultItem is int: ${resultItem is int}');
//                  store.checkDailyRecord();
//                  if (resultItem is PassingObject<FocusEvent>) {
//                    store.addFocusEventToSelectedDay(resultItem.newObject);
//                  } else {
//                    store.checkDailyRecord();
//                  }
                });
              },
            );
          },
          itemCount: usableList.length,
        ),
      ),
    ],
  );
}

class SliverPanel extends SliverPersistentHeaderDelegate {
  final Widget child;

  SliverPanel(this.child);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    debugPrint('shrinkOffset: $shrinkOffset');
    return child;
  }

  @override
  double get maxExtent => 40;

  @override
  double get minExtent => 40;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

/// [event]是一个指向[richLine.note]的变量，所以下面的处理中只能使用event.copyWith
/// 方法获取新的数据，不能直接赋值。如果被复制的话是没有意义的。
Widget _getListView(BuildContext context, int dayIndex) {
  var store = GlobalStore.of(context);
  //var dailyRecord = store.calendarMap.getDailyRecordOrNullFromDayIndex(dayIndex);
  var dailyRecord = store.getDailyRecordOrNull(dayIndex);

  if (dailyRecord == null) {
    return Center(
      child: Text('还没有数据'),
    );
  }

  RichSource richSource = RichSource(dailyRecord.richLines);
  RichNote richNote = RichNote(
    richSource: richSource,
    store: store,
    onTap: (tapObject) {
      var richLine = tapObject.richLine;
      FocusEvent focusEvent = richLine.note;

      debugPrint('edit focusEvent id: ${focusEvent.boxId}');

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return EditerFocusEventRoute(store, focusEvent);
      })).then((resultItem) async {
        debugPrint(
            'resultItem is null: ${resultItem == null} , resultItem is int: ${resultItem is int}');
//        if (resultItem is PassingObject<FocusEvent>) {
//          store.changeFocusEventAndTasks(resultItem);
//          focusEvent.copyWith(resultItem.newObject);
//        } else if (resultItem is int) {
//          store.removeFocusEventAndTasks(focusEvent);
//        }
      });
    },
    onLongTap: (tapObject) {
      var richLine = tapObject.richLine;
      if (richLine.type == RichType.FocusTitle) {
        FocusEvent event = richLine.note;
        var focusItem = store.getFocusItemBy(event.focusItemBoxId);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return FocusItemDetailsRoute(focusItem);
        }));
      }
    },
  );
  return richNote;
}

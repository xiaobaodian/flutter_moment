import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_moment/launch_page.dart';
import 'package:flutter_moment/calendar_map.dart';
import 'package:flutter_moment/calendar_tools.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/models/models.dart';
import 'package:flutter_moment/route/calendar_route.dart';
import 'package:flutter_moment/demo_data.dart';
import 'package:flutter_moment/route/editer_focus_event_route.dart';
import 'package:flutter_moment/route/daily_focus_route.dart';
import 'package:flutter_moment/route/rich_text_editer.dart';
import 'package:flutter_moment/widgets/trim_picture_dialog.dart';

void main() => runApp(GlobalStore(child: MyApp()));

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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
        'CalendarRoute': (_) => CalendarRoute(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  //HomeScreen({Key key, this.title}) : super(key: key);

  //final String title;
  final homeStateKey = GlobalKey<_HomeScreenState>();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalStoreState _store;
  CalendarMap _calendarMap;
  bool hideGoTodayButton;

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = GlobalStore.of(context);
    _calendarMap = _store.calendarMap;
    _pageController = PageController(initialPage: _calendarMap.getDateIndex());
    _pageStorageBucket = PageStorageBucket();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  void test(String text) {
    var snackBar = SnackBar(
      content: Text('返回了：$text'),
      backgroundColor: Colors.yellow,
    );
    Builder(builder: (BuildContext context) {
      Scaffold.of(context).showSnackBar(snackBar);
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Center(
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: CircleAvatar(
                    radius: 5,
                    backgroundImage: AssetImage('assets/image/xuelei01.jpg'),
                    //child: Text('雪嫘'),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.filter_center_focus),
              title: Text(
                '焦点',
                style: TextStyle(fontSize: 18),
              ),
              trailing: Icon(Icons.arrow_right),
              onTap: () {
                var navigator = Navigator.of(context);
                navigator.pop(context);
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return DailyFocusRoute(0);
                }));
              },
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text(
                '事项',
                style: TextStyle(fontSize: 18),
              ),
              trailing: Icon(Icons.arrow_right),
              onTap: () {
                var navigator = Navigator.of(context);
                navigator.pop(context);
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return DailyFocusRoute(0);
                }));
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text(
                '人物',
                style: TextStyle(fontSize: 18),
              ),
              trailing: Icon(Icons.arrow_right),
              onTap: () {
                var navigator = Navigator.of(context);
                navigator.pop(context);
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return DailyFocusRoute(1);
                }));
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text(
                '相片',
                style: TextStyle(fontSize: 18),
              ),
              trailing: Icon(Icons.arrow_right),
              onTap: () {
                var navigator = Navigator.of(context);
                navigator.pop(context);
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return DailyFocusRoute(3);
                }));
              },
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text(
                '位置',
                style: TextStyle(fontSize: 18),
              ),
              trailing: Icon(Icons.arrow_right),
              onTap: () {
                var navigator = Navigator.of(context);
                navigator.pop(context);
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return DailyFocusRoute(2);
                }));
              },
            ),
            ListTile(
              leading: Icon(Icons.label),
              title: Text(
                '标签',
                style: TextStyle(fontSize: 18),
              ),
              trailing: Icon(Icons.arrow_right),
              onTap: () {
                var navigator = Navigator.of(context);
                navigator.pop(context);
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return DailyFocusRoute(4);
                }));
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text(
                '设置',
                style: TextStyle(fontSize: 18),
              ),
              trailing: Icon(Icons.arrow_right),
              onTap: () {  //TrimPicture
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (context) {
                    return TrimPictureDialog();
                  }
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('今日时光'),
        actions: <Widget>[
//          IconButton(
//            icon: Icon(Icons.inbox),
//            onPressed: () {
//              debugPrint('inbox'); //RichTextEditerRoute
//              Navigator.of(context)
//                  .push(MaterialPageRoute(builder: (BuildContext context) {
//                return RichTextEditerRoute('q');
//              }));
//            },
//          ),
          Offstage(
            offstage: hideGoTodayButton,
            child: IconButton(
              icon: Icon(Icons.home),
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
          var selectedDayEvents = _store.calendarMap.getFocusEventsFromSelectedDay();
          var list = List<FocusItem>();
          if (selectedDayEvents.length == 0) {
            list.addAll(_store.focusItemList);
          } else {
            _store.focusItemList.forEach((focus) {
              if (!selectedDayEvents.any((event) => event.focusItemBoxId == focus.boxId)) {
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
        child: Icon(Icons.filter_center_focus),
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
  List<String> dayName = ['前天', '昨天', '今天', '明天', '后天'];
  int base = map.currentDateIndexed - 2;
  int offset = index - base;
  String dayLeap;
  if (offset < 0 || offset > 4) {
    dayLeap = '';
  } else {
    dayLeap = dayName[offset];
  }
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
        Text(
          '${date.year}年${date.month}月${date.day}日',
          style: TextStyle(
            fontSize: 14.0,
          ),
        ),
        Text(
          '$dayLeap  ${DateTimeExt.chineseWeekName(date, longName: true)}',
          style: TextStyle(
            fontSize: 14.0,
          ),
        ),
      ],
    ),
  );
}

Widget _buildFocusModelSheet(GlobalStoreState store, List<FocusItem> usableList) {
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
              leading: Icon(Icons.all_out),
              title: Text(usableList[index].title),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return EditerFocusEventRoute(FocusEvent(focusItemBoxId: usableList[index].boxId));
                })).then((resultItem) {
                  if (resultItem is FocusEvent) {
                    store.addFocusEventToSelectedDay(resultItem, usableList[index].boxId);
                    //usableList[index].addReferences();
                  }
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

Widget _getListView(BuildContext context, int dayIndex) {
  var store = GlobalStore.of(context);
  var dailyRecord = store.calendarMap.everyDayIndex[dayIndex].dailyRecord;

  if (dailyRecord == null) {
    return Center(
      child: Text('还没有数据'),
    );
  } else {
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          child: Container(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Text(
                    store.getFocusTitleFrom(dailyRecord.focusEvents[index].focusItemBoxId),
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
                Text(
                  dailyRecord.focusEvents[index].note,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (BuildContext context) {
              return EditerFocusEventRoute(dailyRecord.focusEvents[index]);
            })).then((resultItem) {
              if (resultItem is FocusEvent) {
                store.changeFocusEventToSelectedDay(resultItem, index);
              } else if (resultItem is int) {
                store.removeFocusEventToSelectedDay(index, dailyRecord.focusEvents[index].focusItemBoxId);
              }
            });
          },
        );
      },
      itemCount: dailyRecord.focusEvents.length,
    );
  }
}
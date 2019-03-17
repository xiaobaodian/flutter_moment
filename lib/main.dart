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
import 'package:flutter_moment/route/browse_task_route.dart';
import 'package:flutter_moment/route/calendar_route.dart';
import 'package:flutter_moment/route/details_focus_item_route.dart';
import 'package:flutter_moment/route/editer_focus_event_route.dart';
import 'package:flutter_moment/route/browse_daily_focus_route.dart';
import 'package:flutter_moment/widgets/trim_picture_dialog.dart';

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
        primarySwatch: Colors.blueGrey,
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

  int buildDailyEventNote(DailyRecord dailyRecord) {
    dailyRecord.buildRichList(_store, true);
    return dailyRecord.richLines.length;
  }

  @override
  Widget build(BuildContext context) {
    _store.updateCurrentDate();
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
              leading: Icon(Icons.assignment_turned_in),
              title: Text(
                '任务',
                style: TextStyle(fontSize: 18),
              ),
              trailing: Icon(Icons.arrow_right),
              onTap: () {
                var navigator = Navigator.of(context);
                navigator.pop(context);
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return BrowseTaskRoute();
                }));
              },
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
              trailing: Icon(Icons.arrow_right),
              onTap: () {
                var navigator = Navigator.of(context);
                navigator.pop(context);
                Navigator.of(context)
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
              trailing: Icon(Icons.arrow_right),
              onTap: () {
                var navigator = Navigator.of(context);
                navigator.pop(context);
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return BrowseDailyFocusRoute(3);
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
                  return BrowseDailyFocusRoute(2);
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
                  return BrowseDailyFocusRoute(4);
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
              onTap: () {
                //TrimPicture
                Navigator.of(context).pop();
                showDialog(
                    context: context,
                    builder: (context) {
                      return TrimPictureDialog();
                    });
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('今日时光'),
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
            var dailyRecord = _store.calendarMap.getDailyRecordFromIndex(index);
            if (dailyRecord != null) {
              if (dailyRecord.richLines == null ||
                  dailyRecord.richLines.length == 0) {
                //  || dailyRecord.richLines.length == 0
                Future(() => buildDailyEventNote(dailyRecord)).then((length) {
                  if (length > 0) {
                    setState(() {
                      debugPrint('延迟生成daily record rich list 完成...');
                    });
                  }
                });
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
          var selectedDayEvents =
              _store.calendarMap.getFocusEventsFromSelectedDay();
          var list = List<FocusItem>();
          if (selectedDayEvents.length == 0) {
            list.addAll(_store.focusItemList);
          } else {
            _store.focusItemList.forEach((focus) {
              if (!selectedDayEvents
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
              leading: Icon(Icons.all_out),
              title: Text(usableList[index].title),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return EditerFocusEventRoute(FocusEvent(
                    dayIndex: store.selectedDateIndex,
                    focusItemBoxId: usableList[index].boxId,
                  ));
                })).then((resultItem) {
                  if (resultItem is PassingObject<FocusEvent>) {
                    store.addFocusEventToSelectedDay(resultItem.newObject);
                  } else {
                    store.checkDailyRecord();
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

/// [event]是一个指向[richLine.note]的变量，所以下面的处理中只能使用event.copyWith
/// 方法获取新的数据，不能直接赋值。如果被复制的话是没有意义的。
Widget _getListView(BuildContext context, int dayIndex) {
  var store = GlobalStore.of(context);
  var dailyRecord = store.calendarMap.getDailyRecordFromIndex(dayIndex);

  if (dailyRecord == null) {
    return Center(
      child: Text('还没有数据'),
    );
  }

  RichSource richSource = RichSource(dailyRecord.richLines);
  RichNote richNote = RichNote(
    richSource: richSource,
    store: store,
    onTapLine: (tapObject) {
      //var richLine = dailyRecord.richLines[tapObject.index];
      var richLine = tapObject.richLine;
      FocusEvent event = richLine.note;
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return EditerFocusEventRoute(event);
      })).then((resultItem) {
        if (resultItem is PassingObject<FocusEvent>) {
          //dailyRecord.richLines.clear();
          Future(() {
            store.changeFocusEventAndTasks(resultItem);
          }).then((_) {
            event.copyWith(resultItem.newObject);
          });
        } else if (resultItem is int) {
          //dailyRecord.richLines.clear();
          store.removeFocusEventAndTasks(event);
        }
      });
    },
    onLongTapLine: (tapObject) {
      //var richLine = dailyRecord.richLines[index];
      var richLine = tapObject.richLine;
      if (richLine.type == RichType.FocusTitle) {
        FocusEvent event = richLine.note;
        var focusItem = store.getFocusItemFromId(event.focusItemBoxId);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return FocusItemDetailsRoute(focusItem);
        }));
      }
    },
  );
  return richNote;
}

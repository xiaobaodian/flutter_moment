import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moment/models/shared_preferences.dart';
import 'package:package_info/package_info.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter_moment/calendar_map.dart';
import 'package:flutter_moment/models/data_services.dart';
import 'package:flutter_moment/models/helper_file.dart';
import 'package:flutter_moment/models/data_helper.dart';
import 'package:flutter_moment/models/models.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_data.dart';
import 'package:flutter_moment/task/task_item.dart';

class GlobalStore extends StatefulWidget {
  final Widget child;
  final CalendarMap calendarMap;

  GlobalStore({
    @required this.child,
    this.calendarMap,
  });

  static GlobalStoreState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_StoreInherited)
            as _StoreInherited)
        .data;
  }

  @override
  GlobalStoreState createState() => GlobalStoreState();
}

class GlobalStoreState extends State<GlobalStore> {
  DataSource dataSource;
  static const _platformDataSource = const MethodChannel('DataSource');
  String localDir;
  CalendarMap calendarMap = CalendarMap();
  PackageInfo packageInfo;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo;
  AppPreferences prefs;
  UserItem user = UserItem();

  ReferencesData<FocusItem> focusItemSet;
  ReferencesData<PersonItem> personSet;
  ReferencesData<PlaceItem> placeSet;
  ReferencesData<TagItem> tagSet;
  BasicData<TaskItem> taskSet;
  BasicData<FocusEvent> focusEventSet;
  BasicData<DailyRecord> dailyRecordSet;


  //Map<int, TaskItem> _taskItemMap = Map<int, TaskItem>();
  //List<TaskItem> taskItemList;

  @override
  void initState() {
    super.initState();
    debugPrint('GlobalStore 初始化...');

    initSystem();

    dataSource = DataSource(version: 1);
    Future.wait([
      dataSource.openDataBase().then((_){
        print('openDataBase loading');
      })
    ]).then((_){
      focusItemSet = ReferencesData(dataSource: dataSource);
      personSet = ReferencesData(dataSource: dataSource);
      placeSet = ReferencesData(dataSource: dataSource);
      tagSet = ReferencesData(dataSource: dataSource);
      taskSet = BasicData(dataSource: dataSource);
      dailyRecordSet = BasicData(dataSource: dataSource);
      focusEventSet = BasicData(dataSource: dataSource);

      focusItemSet.loadItemsFromDataSource().then((_){
        if (focusItemSet.itemList.isEmpty) {
          dataSource.initData(this);
        }
      });
      personSet.loadItemsFromDataSource();
      placeSet.loadItemsFromDataSource();
      tagSet.loadItemsFromDataSource();
      taskSet.loadItemsFromDataSource();
      focusEventSet.loadItemsFromDataSource().then((_){
        focusEventSet.itemList.forEach((focusEvent){
          replaceExpandDataWithTasks(focusEvent);
        });
      });
      dailyRecordSet.loadItemsFromDataSource().then((_){
        dailyRecordSet.itemList.forEach((record){
          int dayIndex = record.dayIndex;
          calendarMap.everyDayIndex[dayIndex].dailyRecord = record;
        });
      });
      personSet.sort();
      placeSet.sort();
      tagSet.sort();
    });

  }

  void updateCurrentDate() {
    calendarMap.initCurrentDate();
  }

  Future initSystem() async {
    //    getLocalPath().then((path) {
    //      localDir = path;
    //    });

    packageInfo = await PackageInfo.fromPlatform();
    androidInfo = await deviceInfo.androidInfo;
  }

  int get selectedDateIndex => calendarMap.selectedDateIndex;

  // FocusItem

  String getFocusTitleBy(int id) => focusItemSet.getItemFromId(id)?.title;
  FocusItem getFocusItemBy(int id) => focusItemSet.getItemFromId(id);

  int changeTaskItemFromFocusEvent(FocusEvent focusEvent) {
    int s = 0;
    focusEvent.noteLines.forEach((line) {
      if (line.type == RichType.Task) {
        TaskItem task = line.expandData;
        if (task.boxId == 0) {
          print('批处理FocusEvent包含的任务，未入库Task：${task.title}');
          //addTaskItem(task);
          taskSet.addItem(task);
          s++;
        } else {
          //changeTaskItem(task);
          taskSet.changeItem(task);
          print('批处理FocusEvent包含的任务，修改了Task(${task.boxId})：${task.title}');
        }
      } else {
        if (line.expandData != null) {
          if (line.expandData is TaskItem) {
            TaskItem task = line.expandData;
            if (task.boxId > 0) {
              //removeTaskItem(task);
              taskSet.removeItem(task);
              print('批处理FocusEvent包含的任务，删除了Task：${task.title}');
            }
          }
          line.expandData = null;
        }
      }
    });
    return s;
  }

  // person

  PersonItem getPersonItemFromId(int id) => personSet.getItemFromId(id);

  // DailyRecords

  DailyRecord get selectedDailyRecord =>
      calendarMap.getDailyRecordFromSelectedDay();

  DailyRecord getDailyRecord(int dayIndex) {
    return calendarMap.everyDayIndex[dayIndex].dailyRecord;
  }

  DailyRecord getDailyRecordFormTask(TaskItem task) {
    return calendarMap.getDailyRecordFromIndex(task.createDate);
  }

  void checkDailyRecord({int dayIndex}) {
    if (dayIndex == null) {
      if (selectedDailyRecord == null || selectedDailyRecord.richLines.isEmpty)
        calendarMap.clearDailyRecordOfSelectedDay();
    } else {
      var dailyRecord = calendarMap.everyDayIndex[dayIndex].dailyRecord;
      if (dailyRecord == null || dailyRecord.richLines.isEmpty)
        calendarMap.clearDailyRecordOfDayIndex(dayIndex);
    }
  }

  void clearSelectedDayDailyRecord() {
    calendarMap.clearDailyRecordOfSelectedDay();
  }

  void clearDailyRecordOfDayIndex(int dayIndex) =>
      calendarMap.clearDailyRecordOfDayIndex(dayIndex);

  // FocusEvent  replaceExpandDataWithTasks

  void replaceExpandDataWithTasks(FocusEvent event) {
    for (var line in event.noteLines) {
      if (line.type == RichType.Task && line.expandData is int) {
        int id = line.expandData;
        debugPrint('将ID转换成任务数据，当前ID：$id');
        line.expandData = taskSet.getItemFromId(id);
        assert(line.expandData != null);
      }
    }
  }

  void addFocusEventToSelectedDay(FocusEvent focusEvent) {
    /// 获取FocusItem，引用增加一次，保存到数据库
    //focusItemAddReferences(focusEvent.focusItemBoxId);
    focusItemSet.addReferencesByBoxId(focusEvent.focusItemBoxId);

    /// 为focusEvent设置dayIndex值，重要
    focusEvent.dayIndex = calendarMap.selectedDateIndex;

    selectedDailyRecord.richLines.clear();
    selectedDailyRecord.focusEvents.add(focusEvent);

    /// 如果还没有保存过就加入到数据库
    if (selectedDailyRecord.boxId == 0) {
      //putDailyRecord(selectedDailyRecord);
      dailyRecordSet.addItem(selectedDailyRecord);
    }
    int r = changeTaskItemFromFocusEvent(focusEvent) * 100;

    focusEvent.extractingPersonList(personSet.itemList);
    focusEvent.personKeys.keyList.forEach((key) => personSet.addReferencesByBoxId(key));

    focusEvent.extractingPlaceList(placeSet.itemList);
    focusEvent.placeKeys.keyList.forEach((id) => placeSet.addReferencesByBoxId(id));

    debugPrint('新增 标签的个数: ${focusEvent.tagKeys.keyList.length}');

    focusEvent.tagKeys.keyList.forEach((id) => tagSet.addReferencesByBoxId(id));

    Future.delayed(Duration(milliseconds: r), () {
      //putFocusEvent(focusEvent);
      focusEventSet.addItem(focusEvent);
    });
  }

  void changeFocusEventForDayIndex(
      FocusEvent focusEvent, int focusEventsIndex, int dayIndex) {
    /// 为focusEvent设置dayIndex值，重要
    focusEvent.dayIndex = dayIndex;

    /// 获取给定日期的FocusEvents列表，然后替换掉index位置的记录
    var dayEvents = calendarMap.getFocusEventsFromDayIndex(dayIndex);
    dayEvents[focusEventsIndex] = focusEvent;
    int i = changeTaskItemFromFocusEvent(focusEvent);
    Future.delayed(Duration(milliseconds: 100 * i), () {
      //changeFocusEvent(focusEvent);
      focusEventSet.changeItem(focusEvent);
    });
    debugPrint('change SelectedDay Events: ${json.encode(dayEvents)}');
  }

  Future changeFocusEventAndTasks(PassingObject<FocusEvent> passingObject) async {
    FocusEvent newFocus = passingObject.newObject;
    FocusEvent oldFocus = passingObject.oldObject;

    DailyRecord dailyRecord = getDailyRecord(newFocus.dayIndex);
    dailyRecord.richLines.clear();

    int r = changeTaskItemFromFocusEvent(newFocus) * 100;

    if (oldFocus != null) {
      newFocus.extractingPersonList(personSet.itemList);
      newFocus.extractingPlaceList(placeSet.itemList);

      debugPrint('当前标签的个数: ${newFocus.tagKeys.keyList.length}');

      // 比较人物的引用
      DiffKeysResult result = LabelKeys.diffKeys(oldFocus.personKeys.keyList, newFocus.personKeys.keyList);

      // 测试用
      result.newKeys
          .forEach((id) => print('新增人物引用：${getPersonItemFromId(id).name}'));
      result.unusedKeys
          .forEach((id) => print('减少人物引用：${getPersonItemFromId(id).name}'));

      result.newKeys.forEach((id) => personSet.addReferencesByBoxId(id));
      result.unusedKeys.forEach((id) => personSet.minusReferencesByBoxId(id));

      // 比较位置的引用
      result = LabelKeys.diffKeys(oldFocus.placeKeys.keyList, newFocus.placeKeys.keyList);

      // 测试用
      result.newKeys
          .forEach((id) => print('新增位置引用：${placeSet.getItemFromId(id).title}'));
      result.unusedKeys
          .forEach((id) => print('减少位置引用：${placeSet.getItemFromId(id).title}'));

      result.newKeys.forEach((id) => placeSet.addReferencesByBoxId(id));
      result.unusedKeys.forEach((id) => placeSet.minusReferencesByBoxId(id));

      // 比较标签的引用
      result = LabelKeys.diffKeys(oldFocus.tagKeys.keyList, newFocus.tagKeys.keyList);

      // 测试用
      result.newKeys
          .forEach((id) => print('新增标签引用：${tagSet.getItemFromId(id).title}'));
      result.unusedKeys
          .forEach((id) => print('减少标签引用：${tagSet.getItemFromId(id).title}'));

      result.newKeys.forEach((id) => tagSet.addReferencesByBoxId(id));
      result.unusedKeys.forEach((id) => tagSet.minusReferencesByBoxId(id));
    }

    await Future.delayed(Duration(milliseconds: r), () {
      //changeFocusEvent(newFocus);
      focusEventSet.changeItem(newFocus);
    });
  }

  void removeFocusEventAndTasks(FocusEvent focusEvent) {
    print('开始执行: removeFocusEventAndTasks');

    /// 获取FocusItem，引用减少一次
    //focusItemMinusReferences(focusEvent.focusItemBoxId);
    focusItemSet.minusReferencesByBoxId(focusEvent.focusItemBoxId);

    /// 删除index位置focusEvent记录里面的TaskItem
    focusEvent.noteLines.forEach((line) {
      if (line.expandData is TaskItem) {
        //removeTaskItem(line.expandData);
        TaskItem task = line.expandData;
        taskSet.removeItem(task);
      }
    });

    focusEvent.personKeys.keyList.forEach((id) => personSet.minusReferencesByBoxId(id));
    focusEvent.placeKeys.keyList.forEach((id) => personSet.minusReferencesByBoxId(id));
    focusEvent.tagKeys.keyList.forEach((id) => personSet.minusReferencesByBoxId(id));

    //removeFocusEvent(focusEvent);
    focusEventSet.removeItem(focusEvent);
    DailyRecord dailyRecord = getDailyRecord(focusEvent.dayIndex);
    dailyRecord.richLines.clear();
    dailyRecord.focusEvents.remove(focusEvent);

    if (dailyRecord.focusEventIsNull) {
      //removeDailyRecord(dailyRecord);
      dailyRecordSet.removeItem(dailyRecord);
      clearDailyRecordOfDayIndex(focusEvent.dayIndex);
    }
    //debugPrint('remove SelectedDay Events: ${json.encode(selectedDailyRecord.focusEvents)}');
  }

  /// 获取指定FocusItem相关的全部FocusEvent
  List<FocusEvent> getFocusEventsFromFocusItemId(int id) {
    List<FocusEvent> resultFocusEvents = [];
    var everyDay = calendarMap.everyDayIndex;
    for (int i = everyDay.length - 1; i > 0; i--) {
      var day = everyDay[i];
      if (day.dailyRecord != null) {
        day.dailyRecord.initRichList(this, true);
        if (day.dailyRecord.focusEventIsNull) {
          setFocusEventsToDailyRecord(day.dailyRecord);
        }
        day.dailyRecord.focusEvents?.forEach((event) {
          if (event.focusItemBoxId == id) {
            resultFocusEvents.add(event);
          }
        });
      }
    }
    return resultFocusEvents;
  }

  List<FocusEvent> getFocusEventsFromPersonItemId(int id) {
    List<FocusEvent> resultFocusEvents = [];
    var everyDay = calendarMap.everyDayIndex;
    for (int i = everyDay.length - 1; i > 0; i--) {
      var day = everyDay[i];
      if (day.dailyRecord != null) {
        day.dailyRecord.initRichList(this, true);
        if (day.dailyRecord.focusEventIsNull) {
          setFocusEventsToDailyRecord(day.dailyRecord);
        }
        day.dailyRecord.focusEvents.forEach((event) {
          if (event.personKeys.keyList.indexOf(id) > -1) {
            resultFocusEvents.add(event);
          }
        });
      }
    }
    return resultFocusEvents;
  }

  List<FocusEvent> getFocusEventsFromPlaceItemId(int id) {
    List<FocusEvent> resultFocusEvents = [];
    var everyDay = calendarMap.everyDayIndex;
    for (int i = everyDay.length - 1; i > 0; i--) {
      var day = everyDay[i];
      if (day.dailyRecord != null) {
        day.dailyRecord.initRichList(this, true);
        if (day.dailyRecord.focusEventIsNull) {
          setFocusEventsToDailyRecord(day.dailyRecord);
        }
        day.dailyRecord.focusEvents.forEach((event) {
          if (event.placeKeys.keyList.indexOf(id) > -1) {
            resultFocusEvents.add(event);
          }
        });
      }
    }
    return resultFocusEvents;
  }

  List<FocusEvent> getFocusEventsFromTagItemId(int id) {
    List<FocusEvent> resultFocusEvents = [];
    var everyDay = calendarMap.everyDayIndex;
    for (int i = everyDay.length - 1; i > 0; i--) {
      var day = everyDay[i];
      if (day.dailyRecord != null) {
        day.dailyRecord.initRichList(this, true);
        if (day.dailyRecord.focusEventIsNull) {
          setFocusEventsToDailyRecord(day.dailyRecord);
        }
        day.dailyRecord.focusEvents.forEach((event) {
          if (event.tagKeys.keyList.contains(id)) {
            resultFocusEvents.add(event);
          }
        });
      }
    }
    return resultFocusEvents;
  }

  void setFocusEventsToDailyRecord(DailyRecord dailyRecord) {
    if (dailyRecord.focusEventIsNull) {
      dailyRecord.focusEvents = [];
      focusEventSet.itemList.forEach((focusEvent){
        if (focusEvent.dayIndex == dailyRecord.dayIndex) dailyRecord.focusEvents.add(focusEvent);
      });
    }
  }

  List<FocusEvent> getFocusEventsFromSelectedDay() {
    var record = calendarMap.getDailyRecordFromSelectedDay();
    setFocusEventsToDailyRecord(record);
    return record.focusEvents;
  }

  FocusEvent getFocusEventFormDailyRecord(
      DailyRecord dailyRecord, int focusId) {
    FocusEvent focusEvent;
    dailyRecord.focusEvents.forEach((event) {
      if (event.focusItemBoxId == focusId) {
        focusEvent = event;
      }
    });
    return focusEvent;
  }

  FocusEvent getFocusEventFormTask(TaskItem task) {
    //FocusEvent focusEvent;
    DailyRecord dailyRecord =
        calendarMap.getDailyRecordFromIndex(task.createDate);
    FocusEvent focusEvent =
        getFocusEventFormDailyRecord(dailyRecord, task.focusItemId);
    return focusEvent;
  }

  // build & inherited

  @override
  Widget build(BuildContext context) {
    return _StoreInherited(
      data: this,
      child: widget.child,
    );
  }
}

class _StoreInherited extends InheritedWidget {
  final GlobalStoreState data;

  _StoreInherited({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
}

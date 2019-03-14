import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moment/calendar_map.dart';
import 'package:flutter_moment/models/data_services.dart';
import 'package:flutter_moment/models/helper_file.dart';
import 'package:flutter_moment/models/models.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_data.dart';
import 'package:flutter_moment/task/TaskItem.dart';

class GlobalStore extends StatefulWidget {

  final Widget child;
  final CalendarMap calendarMap;

  GlobalStore({
    @required this.child,
    this.calendarMap,
  });

  static GlobalStoreState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_StoreInherited) as _StoreInherited).data;
  }

  @override
  GlobalStoreState createState() => GlobalStoreState();
}

class GlobalStoreState extends State<GlobalStore> {
  static const _platformDataSource = const MethodChannel('DataSource');
  String localDir;
  CalendarMap calendarMap = CalendarMap();
  Map<int, FocusItem> _focusItemMap = Map<int, FocusItem>();
  Map<int, PersonItem> _personItemMap = Map<int, PersonItem>();
  Map<int, PlaceItem> _placeItemMap = Map<int, PlaceItem>();
  Map<int, TaskItem> _taskItemMap = Map<int, TaskItem>();
  List<FocusItem> focusItemList;
  List<PersonItem> personItemList;
  List<PlaceItem> placeItemList;
  List<TaskItem> taskItemList;

  @override
  void initState() {
    super.initState();
    debugPrint('GlobalStore 初始化...');

    getLocalPath().then((path){
      localDir = path;
    });

    loadTaskItems();
    loadFocusItems();
    loadPersonItems();
    loadPlaceItems();
    //loadDailyRecords();

  }

  void loadTaskItems(){
    _platformDataSource.invokeMethod('LoadTaskItems').then((result) {
      List<dynamic> resultJson = json.decode(result) as List;
      taskItemList = resultJson.map((item) {
        TaskItem task = TaskItem.fromJson(item);
        _taskItemMap[task.boxId] = task;
        return task;
      }).toList();
      loadDailyRecords();
    });
  }

  void loadFocusItems(){
    _platformDataSource.invokeMethod('LoadFocusItems').then((result) {
      List<dynamic> resultJson = json.decode(result) as List;
      focusItemList = resultJson.map((item) {
        FocusItem focus = FocusItem.fromJson(item);
        _focusItemMap[focus.boxId] = focus;
        return focus;
      }).toList();
    });
  }

  void loadPersonItems(){
    _platformDataSource.invokeMethod('LoadPersonItems').then((result) {
      List<dynamic> resultJson = json.decode(result) as List;
      personItemList = resultJson.map((item) {
        PersonItem person = PersonItem.fromJson(item);
        _personItemMap[person.boxId] = person;
        return person;
      }).toList();
    });
  }

  void loadPlaceItems(){
    _platformDataSource.invokeMethod('LoadPlaceItems').then((result) {
      List<dynamic> resultJson = json.decode(result) as List;
      placeItemList = resultJson.map((item) {
        PlaceItem place = PlaceItem.fromJson(item);
        _placeItemMap[place.boxId] = place;
        return place;
      }).toList();
    });
  }

  void loadDailyRecords(){
    _platformDataSource.invokeMethod('LoadDailyRecords').then((result) {
      List<dynamic> resultJson = json.decode(result) as List;
      resultJson.forEach((item){
        DailyRecord dailyRecord = DailyRecord.fromJson(item);
        int dayIndex = dailyRecord.dayIndex;
        calendarMap.everyDayIndex[dayIndex].dailyRecord = dailyRecord;
        dailyRecord.focusEvents.forEach((event){
          event.noteLines.forEach((line){
            if (line.type == RichType.Task) {
              int id = line.expandData;
              line.expandData = _taskItemMap[id];
            }
          });
        });
      });
    });
  }

  void updateCurrentDate() {
    calendarMap.initCurrentDate();
  }

  int get selectedDateIndex => calendarMap.selectedDateIndex;

  // FocusItem

  String getFocusTitleFrom(int id) => _focusItemMap[id]?.title;
  FocusItem getFocusItemFromId(int id) => _focusItemMap[id];

  void focusItemAddReferences(int id) {
    FocusItem focusItem = _focusItemMap[id];
    focusItem.addReferences();
    changeFocusItem(focusItem);
  }

  void focusItemMinusReferences(int id) {
    FocusItem focusItem = _focusItemMap[id];
    focusItem.minusReferences();
    changeFocusItem(focusItem);
  }

  void addFocusItem(FocusItem focus) {
    focusItemList.add(focus);
    _platformDataSource.invokeMethod("PutFocusItem", json.encode(focus)).then((id) {
      print('新的焦点条目已加入，boxId: $id');
      focus.boxId = id;
      _focusItemMap[id] = focus;
    });
  }

  void changeFocusItem(FocusItem focus) {
    _platformDataSource.invokeMethod("PutFocusItem", json.encode(focus));
  }

  void removeFocusItem(FocusItem focus) {
    _platformDataSource.invokeMethod("RemoveFocusItem", focus.boxId.toString());
    debugPrint('执行删除 focus item : ${focus.boxId}');
    _focusItemMap.remove(focus.boxId);
    focusItemList.remove(focus);
  }

  // task

  void addTaskItem(TaskItem task) {
    taskItemList.add(task);
    debugPrint('加入Task到Store列表中: ${task.title}');
    _platformDataSource.invokeMethod("PutTaskItem", json.encode(task)).then((id) {
      debugPrint('加入Task到数据库中: ${task.title}');
      task.boxId = id;
      _taskItemMap[id] = task;
    });
  }

  void changeTaskItem(TaskItem task) {
    int p = taskItemList.indexOf(_taskItemMap[task.boxId]);
    taskItemList[p] = task;
    _taskItemMap[task.boxId] = task;
    _platformDataSource.invokeMethod("PutTaskItem", json.encode(task));
    debugPrint('在数据库中修改了Task: ${task.title}');
  }

  void removeTaskItem(TaskItem task) {
    if (task == null) return;
    var oldTask = _taskItemMap[task.boxId];
    taskItemList.remove(oldTask);
    _taskItemMap.remove(task.boxId);
    debugPrint('从Store列表中删除了Task: ${task.title}');
    _platformDataSource.invokeMethod("RemoveTaskItem", task.boxId.toString());
    debugPrint('从数据库中删除了Task: ${task.title}');
  }

  void removeTaskItemFromId(int id) {
    removeTaskItem(_taskItemMap[id]);
  }

  int changeTaskItemFromFocusEvent(FocusEvent focusEvent) {
    int s = 0;
    focusEvent.noteLines.forEach((line){
      if (line.type == RichType.Task) {
        TaskItem task = line.expandData;
        if (task.boxId == 0) {
          print('批处理FocusEvent包含的任务，未入库Task：${task.title}');
          addTaskItem(task);
          s++;
        } else {
          changeTaskItem(task);
          print('批处理FocusEvent包含的任务，修改了Task：${task.title}');
        }
      } else {
        if (line.expandData != null) {
          if (line.expandData is int) {
            line.expandData = _taskItemMap[line.expandData];
            assert(line.expandData != null);
          }
          TaskItem task = line.expandData;
          if (task.boxId > 0) {
            removeTaskItem(task);
            print('批处理FocusEvent包含的任务，删除了Task：${task.title}');
          }
          line.expandData = null;
        }
      }
    });
    return s;
  }

  // person

  PersonItem getPersonItemFromId(int id) => _personItemMap[id];

  void personItemAddReferences(int id) {
    PersonItem person = _personItemMap[id];
    person.addReferences();
    changePersonItem(person);
  }

  void personItemMinusReferences(int id) {
    PersonItem person = _personItemMap[id];
    person.minusReferences();
    changePersonItem(person);
  }

  void addPersonItem(PersonItem person) {
    personItemList.add(person);
    _platformDataSource.invokeMethod("PutPersonItem", json.encode(person)).then((id) {
      person.boxId = id;
      _personItemMap[id] = person;
    });
  }

  void changePersonItem(PersonItem person) {
    _platformDataSource.invokeMethod("PutPersonItem", json.encode(person));
  }

  void removePersonItem(PersonItem person) {
    _platformDataSource.invokeMethod("RemovePersonItem", person.boxId.toString());
    _personItemMap.remove(person.boxId);
    personItemList.remove(person);
  }

  // place

  PlaceItem getPlaceItemFromId(int id) => _placeItemMap[id];

  void addPlaceItem(PlaceItem place) {
    placeItemList.add(place);
    _platformDataSource.invokeMethod("PutPlaceItem", json.encode(place)).then((id) {
      place.boxId = id;
      _placeItemMap[id] = place;
    });
  }

  void changePlaceItem(PlaceItem place) {
    _platformDataSource.invokeMethod("PutPlaceItem", json.encode(place));
  }

  void removePlaceItem(PlaceItem place) {
    _platformDataSource.invokeMethod("RemovePlaceItem", place.boxId.toString());
    _placeItemMap.remove(place.boxId);
    placeItemList.remove(place);
  }

  // DailyRecords

  DailyRecord get selectedDailyRecord => calendarMap.getDailyRecordFromSelectedDay();

  DailyRecord getDailyRecord(int dayIndex) {
    return calendarMap.everyDayIndex[dayIndex].dailyRecord;
  }

  DailyRecord getDailyRecordFormTask(TaskItem task) {
    return calendarMap.getDailyRecordFromIndex(task.createDate);
  }

  void clearSelectedDayDailyRecord(){
    calendarMap.clearDailyRecordOfSelectedDay();
  }

  void clearDailyRecordOfDayIndex(int dayIndex) => calendarMap.clearDailyRecordOfDayIndex(dayIndex);

  void putDailyRecord(DailyRecord dailyRecord) {
    _platformDataSource.invokeMethod("PutDailyRecord", json.encode(dailyRecord)).then((id) {
      dailyRecord.boxId = id;
    });
  }

  void changeDailyRecord(DailyRecord dailyRecord) {
    _platformDataSource.invokeMethod("PutDailyRecord", json.encode(dailyRecord));
  }

  void removeDailyRecord(DailyRecord dailyEvens) {
    // 删除DailyEvents数据
    _platformDataSource.invokeMethod("RemoveDailyRecord", dailyEvens.boxId.toString());
    //dailyEventsMap
  }

  // FocusEvent

  void loadTasksForFocusEvent(FocusEvent event) {
    for (var line in event.noteLines) {
      if (line.type == RichType.Task && line.expandData is int) {
        int id = line.expandData;
        line.expandData = _taskItemMap[id];
        assert(line.expandData != null);
      }
    }
  }

  void addFocusEventToSelectedDay(FocusEvent focusEvent) { //, int focusItemBoxId
    /// 获取FocusItem，引用增加一次，保存到数据库
    focusItemAddReferences(focusEvent.focusItemBoxId);

    /// 为focusEvent设置dayIndex值，重要
    focusEvent.dayIndex = calendarMap.selectedDateIndex;

    /// 获取选中日期的DailyRecord，
    selectedDailyRecord.focusEvents.add(focusEvent);

    /// 如果还没有保存过就加入到数据库
    if (selectedDailyRecord.boxId == 0) {
      putDailyRecord(selectedDailyRecord);
    }
    int r = changeTaskItemFromFocusEvent(focusEvent) * 100;
    focusEvent.extractingPersonList(personItemList);
    focusEvent.personKeys.forEach((key) => personItemAddReferences(key));
    Future.delayed(Duration(milliseconds: r), (){
      putFocusEvent(focusEvent);
    });
  }


  void changFocusEventForDailyEvent(FocusEvent focusEvent, int focusEventsIndex, DailyRecord dailyRecord) {
    /// 为focusEvent设置dayIndex值，重要
    focusEvent.dayIndex = dailyRecord.dayIndex;

    /// 获取给定日期的FocusEvents列表，然后替换掉index位置的记录
    var dayEvents = dailyRecord.focusEvents;
    dayEvents[focusEventsIndex] = focusEvent;
    int i = changeTaskItemFromFocusEvent(focusEvent);
    Future.delayed(Duration(milliseconds: 100 * i), () {
      changeFocusEvent(focusEvent);
    });
    debugPrint('change SelectedDay Events: ${json.encode(dayEvents)}');
  }

  void changeFocusEventForDayIndex(FocusEvent focusEvent, int focusEventsIndex, int dayIndex) {
    /// 为focusEvent设置dayIndex值，重要
    focusEvent.dayIndex = dayIndex;

    /// 获取给定日期的FocusEvents列表，然后替换掉index位置的记录
    var dayEvents = calendarMap.getFocusEventsFromDayIndex(dayIndex);
    dayEvents[focusEventsIndex] = focusEvent;
    int i = changeTaskItemFromFocusEvent(focusEvent);
    Future.delayed(Duration(milliseconds: 100 * i), () {
      changeFocusEvent(focusEvent);
    });
    debugPrint('change SelectedDay Events: ${json.encode(dayEvents)}');
  }

  void changeFocusEventAndTasks(PassingObject<FocusEvent> passingObject) {
    FocusEvent newFocus = passingObject.newObject;
    FocusEvent oldFocus = passingObject.oldObject;

    int r = changeTaskItemFromFocusEvent(newFocus) * 100;

    if (oldFocus != null) {
      newFocus.extractingPersonList(personItemList);
      // 下面比较人物的引用
      List<int> newKeys = [];
      for (var personKey in newFocus.personKeys) {
        int keyIndex = oldFocus.personKeys.indexOf(personKey);
        if (keyIndex == -1) {
          newKeys.add(personKey);
        } else {
          oldFocus.personKeys.removeAt(keyIndex);
        }
      }

      // 测试用
      newKeys.forEach((key) => print('新增人物引用：${getPersonItemFromId(key).name}'));
      oldFocus.personKeys.forEach((key) => print('减少人物引用：${getPersonItemFromId(key).name}'));

      newKeys.forEach((key) => personItemAddReferences(key));
      oldFocus.personKeys.forEach((key) => personItemMinusReferences(key));
    }

    Future.delayed(Duration(milliseconds: r), (){
      changeFocusEvent(newFocus);
    });
  }


  void removeFocusEventAndTasks(FocusEvent focusEvent) {
    print('开始执行: removeFocusEventAndTasks');
    /// 获取FocusItem，引用减少一次
    focusItemMinusReferences(focusEvent.focusItemBoxId);

    /// 删除index位置focusEvent记录里面的TaskItem
    focusEvent.noteLines.forEach((line){
      if (line.expandData is TaskItem) {
        removeTaskItem(line.expandData);
      }
    });
    focusEvent.personKeys.forEach((key) => personItemMinusReferences(key));
    removeFocusEvent(focusEvent);
    DailyRecord dailyRecord = getDailyRecord(focusEvent.dayIndex);
    dailyRecord.focusEvents.remove(focusEvent);

    if (dailyRecord.isNull) {
      removeDailyRecord(dailyRecord);
      clearDailyRecordOfDayIndex(focusEvent.dayIndex);
    }
    //debugPrint('remove SelectedDay Events: ${json.encode(selectedDailyRecord.focusEvents)}');
  }

  void putFocusEvent(FocusEvent focusEvent) {
    assert(focusEvent.boxId == 0);
    _platformDataSource.invokeMethod("PutFocusEvent", json.encode(focusEvent)).then((id) {
      focusEvent.boxId = id;
    });
    var test = json.encode(focusEvent);
    debugPrint('Put Focus Event: $test');
  }

  void changeFocusEvent(FocusEvent focusEvent) {
    assert(focusEvent.boxId > 0);
    _platformDataSource.invokeMethod("PutFocusEvent", json.encode(focusEvent));
    var test = json.encode(focusEvent);
    debugPrint('change Focus Event: $test');
  }

  void removeFocusEvent(FocusEvent focusEvent) {
    _platformDataSource.invokeMethod("RemoveFocusEvent", focusEvent.boxId.toString());
    var test = json.encode(focusEvent);
    debugPrint('remove Focus Event: $test');
  }

  List<FocusEvent> getFocusEventsFromFocusItemId(int id){
    List<FocusEvent> focusEvents = [];
    var everyDay = calendarMap.everyDayIndex;
    for (int i = everyDay.length - 1; i > 0; i--) {
      var day = everyDay[i];
      if (day.dailyRecord != null) {
        day.dailyRecord.initRichList(this, true);
        day.dailyRecord.focusEvents.forEach((event){
          if (event.focusItemBoxId == id) {
            focusEvents.add(event);
          }
        });
      }
    }
    return focusEvents;
  }

  List<FocusEvent> getFocusEventsFromPersonItemId(int id){
    List<FocusEvent> focusEvents = [];
    var everyDay = calendarMap.everyDayIndex;
    for (int i = everyDay.length - 1; i > 0; i--) {
      var day = everyDay[i];
      if (day.dailyRecord != null) {
        day.dailyRecord.initRichList(this, true);
        day.dailyRecord.focusEvents.forEach((event){
          if (event.personKeys.indexOf(id) > -1) {
            focusEvents.add(event);
          }
        });
      }
    }
    return focusEvents;
  }

  FocusEvent getFocusEventFormDailyRecord(DailyRecord dailyRecord, int focusId) {
    FocusEvent focusEvent;
    dailyRecord.focusEvents.forEach((event){
      if (event.focusItemBoxId == focusId) {
        focusEvent = event;
      }
    });
    return focusEvent;
  }

  FocusEvent getFocusEventFormTask(TaskItem task) {
    //FocusEvent focusEvent;
    DailyRecord dailyRecord = calendarMap.getDailyRecordFromIndex(task.createDate);
    FocusEvent focusEvent = getFocusEventFormDailyRecord(dailyRecord, task.focusItemId);
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
  }): super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

}
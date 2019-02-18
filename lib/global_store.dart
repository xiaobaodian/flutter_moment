import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moment/calendar_map.dart';
import 'package:flutter_moment/models/data_services.dart';
import 'package:flutter_moment/models/helper_file.dart';
import 'package:flutter_moment/models/models.dart';

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
  List<FocusItem> focusItemList;
  List<PersonItem> personItemList;
  List<PlaceItem> placeItemList;

  @override
  void initState() {
    super.initState();

    getLocalPath().then((path){
      localDir = path;
    });

    _platformDataSource.invokeMethod('LoadFocusItems').then((result) {
      List<dynamic> resultJson = json.decode(result) as List;
      focusItemList = resultJson.map((item) {
        FocusItem focus = FocusItem.fromJson(item);
        _focusItemMap[focus.boxId] = focus;
        return focus;
      }).toList();
    });

    _platformDataSource.invokeMethod('LoadPersonItems').then((result) {
      List<dynamic> resultJson = json.decode(result) as List;
      personItemList = resultJson.map((item) {
        PersonItem person = PersonItem.fromJson(item);
        _personItemMap[person.boxId] = person;
        return person;
      }).toList();
    });

    _platformDataSource.invokeMethod('LoadPlaceItems').then((result) {
      List<dynamic> resultJson = json.decode(result) as List;
      placeItemList = resultJson.map((item) {
        PlaceItem place = PlaceItem.fromJson(item);
        _placeItemMap[place.boxId] = place;
        return place;
      }).toList();
    });

    _platformDataSource.invokeMethod('LoadDailyRecords').then((result) {
      List<dynamic> resultJson = json.decode(result) as List;
      resultJson.forEach((item){
        DailyRecord dailyRecord = DailyRecord.fromJson(item);
        int dayIndex = dailyRecord.dayIndex;
        calendarMap.everyDayIndex[dayIndex].dailyRecord = dailyRecord;
      });
    });
  }

  // FocusItem

  String getFocusTitleFrom(int id) => _focusItemMap[id]?.title;
  FocusItem getFocusItemFromId(int id) => _focusItemMap[id];

  void putFocusItem(FocusItem focus) {
    focusItemList.add(focus);
    _platformDataSource.invokeMethod("PutFocusItem", json.encode(focus)).then((id) {
      focus.boxId = id;
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

  // person

  PersonItem getPersonItemFromId(int id) => _personItemMap[id];

  void putPersonItem(PersonItem person) {
    personItemList.add(person);
    _platformDataSource.invokeMethod("PutPersonItem", json.encode(person)).then((id) {
      person.boxId = id;
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

  void putPlaceItem(PlaceItem place) {
    placeItemList.add(place);
    _platformDataSource.invokeMethod("PutPlaceItem", json.encode(place)).then((id) {
      place.boxId = id;
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

  void putDailyRecord(DailyRecord dailyRecord) {
    _platformDataSource.invokeMethod("PutDailyRecord", json.encode(dailyRecord)).then((id) {
      dailyRecord.boxId = id;
    });
  }

  void changeDailyRecord(DailyRecord dailyRecord) {
    _platformDataSource.invokeMethod("PutDailyRecord", json.encode(dailyRecord));
  }

  void removeDailyRecord(DailyRecord dailyEvens) {
    // 删除关联数据（focusEvents）
    // 删除DailyEvents数据
    _platformDataSource.invokeMethod("RemoveDailyRecord", dailyEvens.boxId.toString());
    //dailyEventsMap
  }

  // FocusEvent

  void addFocusEventToSelectedDay(FocusEvent focusEvent, int focusItemBoxId) {
    /// 获取FocusItem，引用增加一次，保存到数据库
    FocusItem focusItem = getFocusItemFromId(focusItemBoxId);
    focusItem.addReferences();
    changeFocusItem(focusItem);

    /// 为focusEvent设置dayIndex值，重要
    focusEvent.dayIndex = calendarMap.selectedDateIndex;

    /// 获取选中日期的DailyRecord，
    var dailyRecord = calendarMap.getDailyRecordFromSelectedDay();
    debugPrint('保存时获取到的daily record : $dailyRecord');
    dailyRecord.focusEvents.add(focusEvent);

    /// 如果还没有保存过就加入到数据库
    if (dailyRecord.boxId == 0) {
      putDailyRecord(dailyRecord);
    }
    putFocusEvent(focusEvent);
    debugPrint('add SelectedDay Events: ${json.encode(dailyRecord.focusEvents)}');
  }

  void changeFocusEventToSelectedDay(FocusEvent focusEvent, int index) {
    /// 为focusEvent设置dayIndex值，重要
    focusEvent.dayIndex = calendarMap.selectedDateIndex;

    /// 获取选中日期的FocusEvents列表，然后替换掉index位置的记录
    var selectedDayEvents = calendarMap.getFocusEventsFromSelectedDay();
    selectedDayEvents[index] = focusEvent;

    changeFocusEvent(focusEvent);
    debugPrint('change SelectedDay Events: ${json.encode(selectedDayEvents)}');
  }

  void removeFocusEventToSelectedDay(int index, int focusItemBoxId) {
    /// 获取FocusItem，引用减少一次
    FocusItem focusItem = getFocusItemFromId(focusItemBoxId);
    focusItem.minusReferences();
    changeFocusItem(focusItem);

    /// 获取选中日期的FocusEvents列表，然后删除掉index位置的记录
    var selectedDayEvents = calendarMap.getFocusEventsFromSelectedDay();
    removeFocusEvent(selectedDayEvents[index]);
    selectedDayEvents.removeAt(index);

    debugPrint('remove SelectedDay Events: ${json.encode(selectedDayEvents)}');
  }

  void putFocusEvent(FocusEvent focusEvent) {
    _platformDataSource.invokeMethod("PutFocusEvent", json.encode(focusEvent)).then((id) {
      focusEvent.boxId = id;
    });
    var test = json.encode(focusEvent);
    debugPrint('Put Focus Event: $test');
  }

  void changeFocusEvent(FocusEvent focusEvent) {
    var test = json.encode(focusEvent);
    print(test);
  }

  void removeFocusEvent(FocusEvent focusEvent) {
    var test = json.encode(focusEvent);
    print(test);
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
import 'package:flutter/material.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/models/models.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_data.dart';
import 'package:flutter_moment/task/task_item.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'data_helper.dart';

class TableDefinition {
  TableDefinition({
    this.name,
    this.structure,
    this.version = 1,
  });

  String name;
  String structure;
  int version;
}

class DataSource {
  DataSource(){
    initTable();
  }

  String _path;
  int version = 3;
  int oldVersion = 0;
  int newVersion = 0;
  Map<String, TableDefinition> tables = Map<String, TableDefinition>();
  Database _database;

  String get path => _path;
  Database get database => _database;
  bool get hasUpdate => newVersion > oldVersion;
  bool get notUpdate => newVersion == oldVersion;

  Future init() async {
    var p = await getDatabasesPath();
    _path = join(p, "TimeMoment.db");
    debugPrint('database path : $_path');
  }

  Future openDataBase() async {
    if (_database != null) {
      if (_database.isOpen) return;
    }
    if (_path == null) {
      await init();
    }
    debugPrint('当前数据库版本: $version');
    _database = await openDatabase(_path, version: version,
      onCreate: (Database db, int version) async {
        await db.execute(
            'CREATE TABLE ${tables['FocusItem'].name} (${tables['FocusItem'].structure})');
        await db.execute(
            'CREATE TABLE ${tables['PersonItem'].name} (${tables['PersonItem'].structure})');
        await db.execute(
            'CREATE TABLE ${tables['PlaceItem'].name} (${tables['PlaceItem'].structure})');
        await db.execute(
            'CREATE TABLE ${tables['TagItem'].name} (${tables['TagItem'].structure})');
        await db.execute(
            'CREATE TABLE ${tables['DailyRecord'].name} (${tables['DailyRecord'].structure})');
        await db.execute(
            'CREATE TABLE ${tables['FocusEvent'].name} (${tables['FocusEvent'].structure})');
        await db.execute(
            'CREATE TABLE ${tables['TaskItem'].name} (${tables['TaskItem'].structure})');
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        this.oldVersion = oldVersion;
        this.newVersion = newVersion;
        debugPrint('database onUpgrade -> oldVersion: $oldVersion, newVersion: $newVersion');

        if (oldVersion == 1) {
          await db.execute(
              'ALTER TABLE ${tables['TaskItem'].name} ADD COLUMN completeDate integer');
          await db.execute(
              'ALTER TABLE ${tables['TaskItem'].name} ADD COLUMN startTimeStr text');
          await db.execute(
              'ALTER TABLE ${tables['TaskItem'].name} ADD COLUMN endTimeStr text');
          await db.execute(
              'ALTER TABLE ${tables['TaskItem'].name} ADD COLUMN timeId integer');
          await db.execute(
              'ALTER TABLE ${tables['FocusItem'].name} ADD COLUMN timeId integer');
          await db.execute(
              'ALTER TABLE ${tables['PersonItem'].name} ADD COLUMN timeId integer');
          await db.execute(
              'ALTER TABLE ${tables['PlaceItem'].name} ADD COLUMN timeId integer');
          await db.execute(
              'ALTER TABLE ${tables['TagItem'].name} ADD COLUMN timeId integer');
          await db.execute(
              'ALTER TABLE ${tables['DailyRecord'].name} ADD COLUMN timeId integer');
          await db.execute(
              'ALTER TABLE ${tables['FocusEvent'].name} ADD COLUMN timeId integer');
        }
        if (oldVersion == 2) {
          await db.execute(
              'ALTER TABLE ${tables['FocusItem'].name} ADD COLUMN timeId integer');
          await db.execute(
              'ALTER TABLE ${tables['PersonItem'].name} ADD COLUMN timeId integer');
          await db.execute(
              'ALTER TABLE ${tables['PlaceItem'].name} ADD COLUMN timeId integer');
          await db.execute(
              'ALTER TABLE ${tables['TagItem'].name} ADD COLUMN timeId integer');
          await db.execute(
              'ALTER TABLE ${tables['DailyRecord'].name} ADD COLUMN timeId integer');
          await db.execute(
              'ALTER TABLE ${tables['FocusEvent'].name} ADD COLUMN timeId integer');
          await db.execute(
              'ALTER TABLE ${tables['TaskItem'].name} ADD COLUMN timeId integer');
        }
      }
    );
  }

  Future<void> closeDataBase() async {
    await _database?.close();
  }

  Future deleteDataBase() async {
    await deleteDatabase(_path);
  }

  void initTable() {
    tables['FocusItem'] = TableDefinition(name: 'FocusItemTable', structure: '''
        boxId integer primary key autoincrement,
        timeId integer,
        title text,
        comment text,
        count integer,
        presets integer,
        internal integer,
        tags text,
        objectId text,
        createdAt text,
        updatedAt text
      ''');

    tables['PersonItem'] = TableDefinition(name: 'PersonTable', structure: '''
        boxId integer primary key autoincrement,
        timeId integer,
        name text, 
        nickname text,
        photo text,
        gender integer, 
        birthday text, 
        height real,
        weight real,
        count integer,
        tags text,
        username text,
        objectId text,
        createdAt text,
        updatedAt text
      ''');

    tables['PlaceItem'] = TableDefinition(
      name: 'PlaceTable',
      structure: '''
        boxId integer primary key autoincrement,
        timeId integer,
        title text not null,
        address text,
        coverPicture text,
        count integer,
        tags text,
        objectId text,
        createdAt text,
        updatedAt text
      ''',
    );

    tables['TagItem'] = TableDefinition(
      name: 'TagTable',
      structure: '''
        boxId integer primary key autoincrement,
        timeId integer,
        title text not null,
        count integer,
        tags text,
        objectId text,
        createdAt text,
        updatedAt text
      ''',
    );

    tables['DailyRecord'] = TableDefinition(
      name: 'DailyRecordTable',
      structure: '''
        boxId integer primary key autoincrement, 
        timeId integer,
        dayIndex integer,
        weather text,
        coverPicture text,
        tags text,
        objectId text,
        createdAt text,
        updatedAt text
      ''',
    );

    tables['FocusEvent'] = TableDefinition(
      name: 'FocusEventTable',
      structure: '''
        boxId integer primary key autoincrement, 
        timeId integer,
        dayIndex integer,
        focusItemBoxId integer,
        note text,
        personTags text,
        placeTags text,
        tags text,
        objectId text,
        createdAt text,
        updatedAt text
      ''',
    );

    tables['TaskItem'] = TableDefinition(
      name: 'taskTable',
      structure: '''
        boxId integer primary key autoincrement,
        timeId integer,
        focusItemId integer,
        title text,
        comment text,
        placeItemId integer,
        priority integer,
        state integer,
        createDate integer,
        startDate integer,
        dueDate integer,
        completeDate integer,
        startTimeStr text,
        endTimeStr text,
        time text,
        allDay integer,
        subTasks text,
        context text,
        tags text,
        remindPlan integer,
        shareTo text,
        author integer,
        delegate integer,
        objectId text,
        createdAt text,
        updatedAt text
      ''',
    );
  }

  Future initData(GlobalStoreState store) async {
    List<FocusItem> items = [];
    items.add(FocusItem.build(title: '天气与心情', comment: '今天的天气状况与我的心情', presets: true));
    items.add(FocusItem.build(title: '随笔', comment: '记录下感想', presets: true));
    items.add(FocusItem.build(title: '我的工作', comment: '记下工作中遇到的问题，形成原因，以及采取的处置办法。多进行此类总结有利于工作能力的提升。'));
    items.add(FocusItem.build(title: '家庭圈', comment: '今天你的家庭有哪些活动值得记录？记下这美好时刻。'));
    items.add(FocusItem.build(title: '朋友圈', comment: '朋友间的趣闻和聚会也是有很多值得品味的，记下来，分享给大家。'));
    items.add(FocusItem.build(title: '购物', comment: '血拼的战报，提醒自己要多挣钱。'));
    items.add(FocusItem.build(title: '读书与知识', comment: '提升自己的知识和见识，需要大量的阅读，多花些时间看看书, 多花些时间思考。'));
    items.add(FocusItem.build(title: '健身', comment: '身体是革命的本钱，锻炼身体，保卫祖国。好身体也是快乐的源泉...'));
    items.add(FocusItem.build(title: '宠物星球', comment: '小宠物们的日常点滴。'));
    items.add(FocusItem.build(title: '流浪喵星', comment: '帮助流浪的小动物'));
    items.add(FocusItem.build(title: '饮食', comment: '每天的饮食状况'));
    items.add(FocusItem.build(title: '健康', comment: '身体的健康状况'));

    items.forEach((item){
      store.focusItemSet.addItem(item);
    });
  }

  Future upgradeDataBase(GlobalStoreState store) async {
    await openDataBase();

    await store.focusItemSet.rawLoadItemsFromDataSource();

    await store.personSet.rawLoadItemsFromDataSource();

    await store.placeSet.rawLoadItemsFromDataSource();

    await store.tagSet.rawLoadItemsFromDataSource();

    await store.taskSet.rawLoadItemsFromDataSource().then((_){
      store.taskSet.itemList.forEach((task) => store.taskCategories.allTasks.assigned(task));
    });

    await store.focusEventSet.rawLoadItemsFromDataSource();

    for (var focusEvent in store.focusEventSet.itemList) {

      int id = focusEvent.focusItemBoxId;
      if (id < 10000) {
        focusEvent.focusItemBoxId = store.focusItemSet.getTimeIdByBoxId(id);
      }

      for (var line in focusEvent.noteLines) {
        if (line.type == RichType.Task && line.expandData is int) {
          int id = line.expandData;
          if (id < 10000) {
            TaskItem task = store.taskSet.getItemFromBoxId(id);
            line.expandData = task;
            debugPrint('替换line.expandData：$id -> ${line.expandData}');
          }
        }
      }

      for (int i = 0; i < focusEvent.personKeys.keyList.length; i++) {
        var key = focusEvent.personKeys.keyList[i];
        if (key < 10000) {
          focusEvent.personKeys.keyList[i] = store.personSet.getTimeIdByBoxId(key);
        }
      }
      for (int i = 0; i < focusEvent.placeKeys.keyList.length; i++) {
        var key = focusEvent.placeKeys.keyList[i];
        if (key < 10000) {
          focusEvent.placeKeys.keyList[i] = store.placeSet.getTimeIdByBoxId(key);
        }
      }
      for (int i = 0; i < focusEvent.tagKeys.keyList.length; i++) {
        var key = focusEvent.tagKeys.keyList[i];
        if (key < 10000) {
          focusEvent.tagKeys.keyList[i] = store.tagSet.getTimeIdByBoxId(key);
        }
      }
      store.focusEventSet.rawChangeItem(focusEvent);
    }

    store.dailyRecordSet.rawLoadItemsFromDataSource().then((_){
      store.dailyRecordSet.itemList.forEach((record){
        int dayIndex = record.dayIndex;
        store.calendarMap.everyDayIndex[dayIndex].dailyRecord = record;
      });
    });
//    await closeDataBase();
//    await openDataBase();
  }
}

class DateServices {
}

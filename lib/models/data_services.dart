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

  Future upgradeDataBase() async {
    //await closeDataBase();
    //await openDataBase();

    int focusItemStep = 0;
    int personStep = 0;
    int placeStep = 0;
    int tagStep = 0;
    int taskStep = 0;
    int dailyRecordStep = 0;
    int focusEventStep = 0;

    ReferencesData<FocusItem> focusItemSet;
    ReferencesData<PersonItem> personSet;
    ReferencesData<PlaceItem> placeSet;
    ReferencesData<TagItem> tagSet;
    BasicData<TaskItem> taskSet;
    BasicData<FocusEvent> focusEventSet;
    BasicData<DailyRecord> dailyRecordSet;

    focusItemSet = ReferencesData(dataSource: this);
    personSet = ReferencesData(dataSource: this);
    placeSet = ReferencesData(dataSource: this);
    tagSet = ReferencesData(dataSource: this);
    taskSet = BasicData(dataSource: this);
    dailyRecordSet = BasicData(dataSource: this);
    focusEventSet = BasicData(dataSource: this);

    await focusItemSet.loadItemsFromDataSource();
    for (var focusItem in focusItemSet.itemList) {
      debugPrint('${focusItem.title} 生成timeId: ${focusItem.timeId}');
      focusItem.timeId = DateTime.now().millisecondsSinceEpoch * 100 + focusItemStep++;
      if (focusItemStep >= 100) focusItemStep = 0;
      await focusItemSet.rawChangeItem(focusItem);
    }

    await personSet.loadItemsFromDataSource();
    for (var person in personSet.itemList) {
      debugPrint('${person.name} 生成timeId: ${person.timeId}');
      person.timeId = DateTime.now().millisecondsSinceEpoch * 100 + personStep++;
      if (personStep >= 100) personStep = 0;
      await personSet.rawChangeItem(person);
    }

    await placeSet.loadItemsFromDataSource();
    for (var place in placeSet.itemList) {
      debugPrint('${place.title} 生成timeId: ${place.timeId}');
      place.timeId = DateTime.now().millisecondsSinceEpoch * 100 + placeStep++;
      if (placeStep >= 100) placeStep = 0;
      await placeSet.rawChangeItem(place);
    }

    await tagSet.loadItemsFromDataSource();
    for (var tag in tagSet.itemList) {
      debugPrint('${tag.title} 生成timeId: ${tag.timeId}');
      tag.timeId = DateTime.now().millisecondsSinceEpoch * 100 + tagStep++;
      if (tagStep >= 100) tagStep = 0;
      await tagSet.rawChangeItem(tag);
    }

    await taskSet.loadItemsFromDataSource();
    for (var task in taskSet.itemList) {
      debugPrint('${task.title} 生成timeId: ${task.timeId}');
      task.timeId = DateTime.now().millisecondsSinceEpoch * 100 + taskStep++;
      if (taskStep >= 100) taskStep = 0;
      await taskSet.rawChangeItem(task);
    }

    await dailyRecordSet.loadItemsFromDataSource();
    for (var dailyRecord in dailyRecordSet.itemList) {
      debugPrint('${dailyRecord.dayIndex} 生成timeId: ${dailyRecord.timeId}');
      dailyRecord.timeId = DateTime.now().millisecondsSinceEpoch * 100 + dailyRecordStep++;
      if (dailyRecordStep >= 100) dailyRecordStep = 0;
      await dailyRecordSet.rawChangeItem(dailyRecord);
    }

    await focusEventSet.loadItemsFromDataSource();
    for (var focusEvent in focusEventSet.itemList) {
      debugPrint('${focusEvent.boxId} 生成timeId: ${focusEvent.timeId}');
      focusEvent.timeId = DateTime.now().millisecondsSinceEpoch * 100 + focusEventStep++;
      if (focusEventStep >= 100) focusEventStep = 0;

      if (focusEvent.focusItemBoxId < 10000) {
        var focusItem = focusItemSet.itemList.firstWhere((focusItem)=> focusEvent.focusItemBoxId == focusItem.boxId);
        focusEvent.focusItemBoxId = focusItem.timeId;
      }

      for (var line in focusEvent.noteLines) {
        if (line.type == RichType.Task && line.expandData is int) {
          int id = line.expandData;
          int timeI = taskSet.getTimeIdByBoxId(id);
          line.expandData = taskSet.getItemFromId(timeI);
          debugPrint('替换line.expandData：$id -> ${line.expandData}');
        }
      }
      for (int i = 0; i < focusEvent.personKeys.keyList.length; i++) {
        var key = focusEvent.personKeys.keyList[i];
        if (key < 10000) {
          focusEvent.personKeys.keyList[i] = personSet.getTimeIdByBoxId(key);
        }
      }
      for (int i = 0; i < focusEvent.placeKeys.keyList.length; i++) {
        var key = focusEvent.placeKeys.keyList[i];
        if (key < 10000) {
          focusEvent.placeKeys.keyList[i] = placeSet.getTimeIdByBoxId(key);
        }
      }
      for (int i = 0; i < focusEvent.tagKeys.keyList.length; i++) {
        var key = focusEvent.tagKeys.keyList[i];
        if (key < 10000) {
          focusEvent.tagKeys.keyList[i] = tagSet.getTimeIdByBoxId(key);
        }
      }
      await focusEventSet.rawChangeItem(focusEvent);
    }
    //await closeDataBase();
    //await openDataBase();
  }
}

class DateServices {
}

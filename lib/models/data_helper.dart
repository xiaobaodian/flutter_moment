
import 'package:flutter/material.dart';
import 'package:flutter_moment/models/data_services.dart';
import 'package:flutter_moment/models/models.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_data.dart';

/// 基本数据管理类
class BasicData<T extends BoxItem> {
  BasicData({
    this.dataSource,
  });

  final DataSource dataSource;

  Map<int, T> _itemMap = Map();
  List<T> itemList = [];

  int _timeIdStep = 0;
  int get getTimeId {
    if (_timeIdStep >= 100) _timeIdStep = 0;
    return DateTime.now().millisecondsSinceEpoch * 100 + _timeIdStep++;
  }

  // 升级关键key使用
  int getTimeIdByBoxId(int id) {
    var obj = itemList.firstWhere((item) => item.boxId == id);
    return obj?.timeId ?? -1;
  }

  T getItemFromId(int id) => _itemMap[id];

  Future<List<T>> rawLoadItemsFromDataSource() async {
    await dataSource.openDataBase();
    return await dataSource.database
        .rawQuery(
        'SELECT * FROM ${dataSource.tables[BoxItem.typeName(T)].name}')
        .then((resultJson) {
      itemList = resultJson.map((jsonString) => BoxItem.itemFromJson(T, jsonString)).toList();
    });
  }

  Future<List<T>> loadItemsFromDataSource() async {
    await dataSource.openDataBase();
    return await dataSource.database
        .rawQuery(
            'SELECT * FROM ${dataSource.tables[BoxItem.typeName(T)].name}')
        .then((resultJson) {
      itemList = resultJson.map((jsonString) {
        T item = BoxItem.itemFromJson(T, jsonString);

        // TODO: 升级完关键key以后去掉
//        if (item.timeId == null || item.timeId == 0) {
//          item.timeId = getTimeId;
//          changeItem(item);
//        }

        _itemMap[item.timeId] = item;
        return item;
      }).toList();
    });
  }

  void addItemsFromList(List<T> items) {
    for (T item in items) {
      itemList.add(item);
      _itemMap[item.timeId] = item;
    }
  }

  void addItems(List<T> items) {
    for (T item in items) {
      addItem(item);
    }
  }

//  Future<int> addItem(T item) async {
//    itemList.add(item);
//    Map<String, dynamic> data = item.toJson();
//    return await dataSource.database.transaction((txn) async {
//      int id = await txn.insert(dataSource.tables[BoxItem.typeName(T)].name, data);
//      item.boxId = id;
//      _itemMap[id] = item;
//      return id;
//    });
//  }

  Future<int> addItem(T item) async {
    itemList.add(item);
    if (item.timeId == 0) {
      item.timeId = getTimeId;
      Map<String, dynamic> data = item.toJson();
      await dataSource.openDataBase();
      item.boxId = await dataSource.database
          .insert(dataSource.tables[BoxItem.typeName(T)].name, data);
      _itemMap[item.timeId] = item;
    } else {
      _itemMap[item.timeId] = item;
    }
    debugPrint('${item.runtimeType.toString()} addItem boxId = ${item.boxId} timeId = ${item.timeId}');
    return item.timeId;
  }

  /// 修改[item]的时候传进来的可能是一个副本，只有[boxId]是可靠的，所以先
  /// 通过[_itemMap]找到[itemList]中原来的实例，进行对比，如果是同一个对象，就不用
  /// 处理。否则，通过indexOf方法定位到index，然后进行替换，并把[_itemMap]也进行
  /// 替换。
  Future<int> changeItem(T item) async {
    debugPrint('${item.runtimeType.toString()}  changeItem boxId = ${item.boxId} timeId = ${item.timeId}');
    assert(item != null);

    T oldItem = _itemMap[item.timeId];
    assert(oldItem != null);

    if (oldItem != item) {
      int position = itemList.indexOf(oldItem);
      debugPrint('${T.runtimeType.toString()} itemList.indexOf(temp) = $position');
      assert(position != -1);

      itemList[position] = item;
      _itemMap[item.timeId] = item;
    }
    Map<String, dynamic> data = item.toJson();
    await dataSource.openDataBase();
    int changes = await dataSource.database.update(
        dataSource.tables[BoxItem.typeName(T)].name, data,
        where: 'boxId = ?', whereArgs: [item.boxId]);
    return changes;
  }

  Future<int> rawChangeItem(T item) async {
    debugPrint('${item.runtimeType.toString()}  rawChangeItem boxId = ${item.boxId} timeId = ${item.timeId}');
    assert(item != null);

    Map<String, dynamic> data = item.toJson();
    await dataSource.openDataBase();
    int changes = await dataSource.database.update(
        dataSource.tables[BoxItem.typeName(T)].name, data,
        where: 'boxId = ?', whereArgs: [item.boxId]);
    return changes;
  }

  /// 删除item的时候，传进来的可能是一个全新的副本，直接删除是有可能出错的。
  /// 所以需要通过传进来的[item.boxId]执行删除才能保证正确执行。
  Future<int> removeItem(T item) async {
    return await removeItemByBoxId(item.timeId);
  }

  Future<int> changeItemByBoxId(int id) async {
    T item = _itemMap[id];
    assert(item != null);
    int changes = 0;
    if (item != null) {
      Map<String, dynamic> data = item.toJson();
      await dataSource.openDataBase();
      changes = await dataSource.database.update(
          dataSource.tables[BoxItem.typeName(T)].name, data,
          where: 'boxId = ?', whereArgs: [item.boxId]);
    }
    return changes;
  }

  Future<int> removeItemByBoxId(int timeId) async {
    T item = _itemMap[timeId];
    assert(item != null);
    int changes = 0;
    if (item != null) {
      itemList.remove(item);
      _itemMap.remove(item.timeId);
      await dataSource.openDataBase();
      changes = await dataSource.database.delete(
          dataSource.tables[BoxItem.typeName(T)].name,
          where: 'boxId = ?',
          whereArgs: [item.boxId]);
    }
    return changes;
  }

  // 'dayIndex = ?' 'boxId = ?'
  Future<List<T>> findByWhere(String where, List<dynamic> whereArgs) async {
    List<T> list = [];
    await dataSource.openDataBase();
    List<Map<String, dynamic>> rawList = await dataSource.database.query(
        dataSource.tables[BoxItem.typeName(T)].name,
        where: where,
        whereArgs: whereArgs);

    debugPrint('数据库 findByWhere 返回了(${rawList.length})条数据');

    list = rawList.map((jsonString) {
      T item = BoxItem.itemFromJson(T, jsonString);
      if (item.timeId == 0) {
        item.timeId = DateTime.now().millisecondsSinceEpoch;
        changeItem(item);
      }
      _itemMap[item.timeId] = item;
      return item;
    }).toList();

    if (T == FocusEvent) {
      list.forEach((r) {
        FocusEvent e = r as FocusEvent;
        debugPrint('item : ${e.focusItemBoxId}');
      });
    }
    debugPrint('转换了(${list.length})条数据');
    return list;
  }

  bool findId(int id) {
    return _itemMap.containsKey(id);
  }
}

/// 引用属性数据类
class ReferencesData<T extends ReferencesBoxItem> extends BasicData<T> {
  ReferencesData({
    DataSource dataSource,
  }) : super(dataSource: dataSource);

  Future<List<T>> loadItemsFromDataSource() async {
    var list = await super.loadItemsFromDataSource();
    itemList.sort((one, two) => two.count.compareTo(one.count));
    return list;
  }

  int addReferences(T item) {
    item.addReferences();
    changeItem(item);
    itemList.sort((one, two) => two.count.compareTo(one.count));
    return item.count;
  }

  int minusReferences(T item) {
    item.minusReferences();
    changeItem(item);
    itemList.sort((one, two) => two.count.compareTo(one.count));
    return item.count;
  }

  int addReferencesByBoxId(int id) {
    debugPrint('增加一次对id($id)的引用');
    int sum = 0;
    T item = _itemMap[id];
    if (item != null) {
      sum = addReferences(item);
    }
    return sum;
  }

  int minusReferencesByBoxId(int id) {
    debugPrint('减去一次对id($id)的引用');
    int sum = 0;
    T item = _itemMap[id];
    if (item != null) {
      sum = minusReferences(item);
    }
    return sum;
  }

  void sort() {
    //itemList.sort((one, two) => one.count.compareTo(two.count));
    itemList.sort((one, two) => two.count.compareTo(one.count));
  }
}

class DiffKeysResult {
  DiffKeysResult({
    this.newKeys,
    this.oldKeys,
    this.unusedKeys,
  });

  List<int> unusedKeys;
  List<int> newKeys;
  List<int> oldKeys;
}

/// 标签关键字管理
///
/// 用于某个对象的标签属性，基于List<int>包装。
/// 这里只管理标签的key(Id)值，不负责标签对象本身的管理，要获得标签对象，通过[ReferencesData]的
/// [getItemFromId]方法获取。
///
/// 保存的key值不能有重值。
///
class LabelKeys {
  List<int> _keys = [];
  List<int> get keyList => _keys;

  void add(int key) {
    if (_keys.contains(key)) return;
    _keys.add(key);
  }

  void remove(int key) => _keys.remove(key);
  void removeAt(int index) => _keys.removeAt(index);
  bool contains(int key) => _keys.contains(key);

  void addOrRemove(int key) {
    if (_keys.contains(key)) {
      _keys.remove(key);
    } else {
      _keys.add(key);
    }
  }

  bool hasKeys() => _keys.isNotEmpty;

  /// 将[_keys]转换成字符串：'1|2|3|4|5'
  String toString({String pattern = '|'}) {
    String str;
    for (int i = 0; i < _keys.length; i++) {
      if (i == 0) {
        str = _keys[i].toString();
      } else {
        str = str + "$pattern${_keys[i].toString()}";
      }
    }
    return str;
  }

  /// 将字符串'1|2|3|4|5'，转换成[_keys]
  void fromString(String labelString, [String pattern = '|']) {
    if (labelString != null) {
      _keys = labelString.split(pattern).map((key) => int.parse(key)).toList();
    }
  }

  static DiffKeysResult diffKeys(List<int> oldKeys, List<int> newKeys) {
    List<int> unusedList = oldKeys.sublist(0);
    List<int> newList = [];
    List<int> oldList = [];
    for (var newKey in newKeys) {
      if (unusedList.remove(newKey)) {
        oldList.add(newKey);
      } else {
        newList.add(newKey);
      }
    }
    return DiffKeysResult(
        newKeys: newList, oldKeys: oldList, unusedKeys: unusedList);
  }

  void fromExtracting(List<RichLine> lines, List<ReferencesBoxItem> objectList,
      {bool clean = false}) {
    if (clean) {
      _keys.clear(); debugPrint('执行了 -> _keys.clear()');
    }
    for (var line in lines) {
      for (var obj in objectList) {
        debugPrint('准备从“${line.getContent()}”中查找“${obj.getLabel()}”');
        if (line.getContent().contains(obj.getLabel())) {
          debugPrint('解析：${line.getContent()}');
          debugPrint('找到了：${obj.getLabel()}');
          add(obj.timeId);
        }
      }
    }
  }

  void copyWith(LabelKeys other) {
    _keys = other._keys.sublist(0);
  }

  bool findKey(int key) {
    return _keys.contains(key);
  }
}

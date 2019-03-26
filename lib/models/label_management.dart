import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moment/models/data_services.dart';
import 'package:flutter_moment/models/models.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_data.dart';
import 'package:flutter_moment/task/task_item.dart';

class BoxSet<T extends BoxItem> {
  BoxSet({
    @required this.dataChannel,
    @required command,
    this.dataSource,
  })  : _loadCommand = 'Load${command}Items',
        _putCommand = 'Put${command}Item',
        _removeCommand = 'Remove${command}Item';

  final MethodChannel dataChannel;
  final DataSource dataSource;
  final String _loadCommand;
  final String _putCommand;
  final String _removeCommand;

  Map<int, T> _itemMap = Map();
  List<T> itemList = [];

  T getItemFromId(int id) => _itemMap[id];

  Future<T> loadItemsFromDataChannel() async {
    if (dataSource == null) {
      return dataChannel.invokeMethod(_loadCommand).then((result) {
        List<dynamic> resultJson = json.decode(result) as List;
        itemList = resultJson.map((jsonString) {
          T item = BoxItem.itemFromJson(T, jsonString);
          _itemMap[item.boxId] = item;
          return item;
        }).toList();
      });
    }
    print('T.runtimeType: (${T.runtimeType})');
    return await dataSource.database
        .rawQuery(
        'SELECT * FROM ${dataSource.tables[T.runtimeType.toString()].name}')
        .then((resultJson) {
      itemList = resultJson.map((jsonString) {
        T item = BoxItem.itemFromJson(T, jsonString);
        _itemMap[item.boxId] = item;
        return item;
      }).toList();
    });
  }

//  Future<T> loadItemsFromDataSource() async {
//
//  }

  void addItemsFromList(List<T> items) {
    for (T item in items) {
      itemList.add(item);
      _itemMap[item.boxId] = item;
    }
  }

  void addItems(List<T> items) {
    for (T item in items) {
      addItem(item);
    }
  }

  void addItem(T item) {
    itemList.add(item);

    if (dataSource != null) {
      dataSource.database.insert(
          dataSource.tables[T.runtimeType.toString()].name, item.toJson());
    } else {
      dataChannel.invokeMethod(_putCommand, json.encode(item)).then((id) {
        item.boxId = id;
        _itemMap[id] = item;
      });
    }
  }

  /// 修改[item]的时候传进来的可能是一个副本，只有[boxId]是可靠的，所以先
  /// 通过[_itemMap]找到[itemList]中原来的实例，进行对比，如果是同一个对象，就不用
  /// 处理。否则，通过indexOf方法定位到index，然后进行替换，并把[_itemMap]也进行
  /// 替换。
  void changeItem(T item) {
    T temp = _itemMap[item.boxId];
    assert(temp != null);
//    if (item.runtimeType == TaskItem) {
//      var oo = temp as TaskItem;
//      var nn = item as TaskItem;
//      debugPrint('old task(${oo.boxId}) -> (${oo.title})');
//      debugPrint('new task(${nn.boxId}) -> (${nn.title})');
//    }
    if (temp != item) {
      int position = itemList.indexOf(temp);
      assert(position != -1);
      itemList[position] = item;
      _itemMap[item.boxId] = item;
//      if (position == -1) {
//        debugPrint('index error ! -> ${item.boxId} (${item.runtimeType})');
//      } else {
//        itemList[position] = item;
//        _itemMap[item.boxId] = item;
//      }
    }
    dataChannel.invokeMethod(_putCommand, json.encode(item));
  }

  /// 删除item的时候，传进来的可能是一个全新的副本，直接删除是有可能出错的。
  /// 所以需要通过传进来的[item.boxId]执行删除才能保证正确执行。
  void removeItem(T item) {
    removeItemByBoxId(item.boxId);
  }

  void changeItemByBoxId(int id) {
    T item = _itemMap[id];
    assert(item != null);
    if (item != null) {
      dataChannel.invokeMethod(_putCommand, item.boxId.toString());
    }
  }

  void removeItemByBoxId(int id) {
    T item = _itemMap[id];
    assert(item != null);
    if (item != null) {
      itemList.remove(item);
      _itemMap.remove(item.boxId);
      dataChannel.invokeMethod(_removeCommand, item.boxId.toString());
    }
  }

  bool findId(int id) {
    return _itemMap.containsKey(id);
  }
}

/// 标签管理类
class LabelSet<T extends ReferencesBoxItem> extends BoxSet<T> {
  LabelSet({
    @required dataChannel,
    @required command,
    DataSource dataSource,
  }) : super(dataChannel: dataChannel, command: command, dataSource: dataSource);

  int addReferences(T item) {
    item.addReferences();
    changeItem(item);
    return item.references;
  }

  int minusReferences(T item) {
    item.minusReferences();
    changeItem(item);
    return item.references;
  }

  int addReferencesByBoxId(int id) {
    int sum = 0;
    T item = _itemMap[id];
    if (item != null) {
      sum = addReferences(item);
    }
    return sum;
  }

  int minusReferencesByBoxId(int id) {
    int sum = 0;
    T item = _itemMap[id];
    if (item != null) {
      sum = minusReferences(item);
    }
    return sum;
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
/// 这里只管理标签的key(Id)值，不负责标签对象本身的管理，要获得标签对象，通过[LabelSet]的
/// [getItemFromId]方法获取。
///
/// 保存的key值不能有重值。
///
class LabelKeys {
  List<int> _keys = [];

  List<int> get list => _keys;
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

  void fromExtracting(
      List<RichLine> lines, List<ReferencesBoxItem> objectList) {
    _keys.clear();
    for (var line in lines) {
      for (var obj in objectList) {
        if (line.getContent().contains(obj.getLabel())) {
          debugPrint('找到了：${obj.getLabel()}');
          add(obj.boxId);
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

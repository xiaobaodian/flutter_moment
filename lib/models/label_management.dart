import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moment/models/models.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_data.dart';

/// 标签管理类
class LabelSet<T extends BoxItem> {
  LabelSet({
    @required this.dataSource,
    @required this.loadCommand,
    @required this.putCommand,
    @required this.removeCommand,
  });

  final MethodChannel dataSource;
  final String loadCommand;
  final String putCommand;
  final String removeCommand;

  Map<int, T> itemMap = Map();
  List<T> itemList = [];

  T getItemFromId(int id) => itemMap[id];

  void loadItemsFromDataSource() {
    dataSource.invokeMethod(loadCommand).then((result) {
      List<dynamic> resultJson = json.decode(result) as List;
      itemList = resultJson.map((jsonString) {
        T item = BoxItem.itemFromJson(T, jsonString);
        itemMap[item.boxId] = item;
        return item;
      }).toList();
    });
  }

  void addItemsFromList(List<T> items) {
    for (T item in items) {
      itemList.add(item);
      itemMap[item.boxId] = item;
    }
  }

  void addItems(List<T> items) {
    for (T item in items) {
      addItem(item);
    }
  }

  void addItem(T item) {
    itemList.add(item);
    dataSource.invokeMethod(putCommand, json.encode(item)).then((id) {
      item.boxId = id;
      itemMap[id] = item;
    });
  }

  void changeItem(T item) {
    dataSource.invokeMethod(putCommand, json.encode(item));
  }

  void removeItem(T item) {
    dataSource.invokeMethod(removeCommand, item.boxId.toString());
    itemMap.remove(item.boxId);
    itemList.remove(item);
  }

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

  void changeItemByBoxId(int id) {
    T item = itemMap[id];
    if (item != null) {
      changeItem(item);
    }
  }

  void removeItemByBoxId(int id) {
    T item = itemMap[id];
    if (item != null) {
      removeItem(item);
    }
  }

  int addReferencesByBoxId(int id) {
    int sum = 0;
    T item = itemMap[id];
    if (item != null) {
      sum = addReferences(item);
    }
    return sum;
  }

  int minusReferencesByBoxId(int id) {
    int sum = 0;
    T item = itemMap[id];
    if (item != null) {
      sum = minusReferences(item);
    }
    return sum;
  }

  List<int> extractingLabelByRichLines(List<RichLine> lines) {
    List<int> list = [];
    for (var line in lines) {
      for (var item in itemList) {
        if (line.getContent().contains(item.getLabel())) {
          debugPrint('找到了：${item.getLabel()}');
          if (list.indexOf(item.boxId) == -1) {
            list.add(item.boxId);
          }
        }
      }
    }
    return list;
  }
}

class LabelKeyDiffResult {
  LabelKeyDiffResult({
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

  /// 将[_keys]转换成字符串：'1|2|3|4|5'
  String toString() {
    String str;
    for (int i = 0; i < _keys.length; i++) {
      if (i == 0) {
        str = _keys[i].toString();
      } else {
        str = str + "|${_keys[i].toString()}";
      }
    }
    return str;
  }

  /// 将字符串'1|2|3|4|5'，转换成[_keys]
  void fromString(String labelString) {
    if (labelString != null) {
      _keys = labelString.split('|').map((key) => int.parse(key)).toList();
    }
  }

  LabelKeyDiffResult diffKeys(List<int> oldKeys, List<int> newKeys) {
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
    return LabelKeyDiffResult(
        newKeys: newList, oldKeys: oldList, unusedKeys: unusedList);
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_moment/models/models.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_widget.dart';
import 'package:flutter_moment/task/task_item.dart';
import 'package:meta/meta.dart';

enum RichType {
  FocusTitle, // 焦点标题
  Title, // 标题
  SubTitle, // 子标题
  Task, // 任务
  Text, // 标准文本
  Comment, // 评论
  Reference, // 引用
  UnorderedList, // 无序列表
  OrderedLists, // 有序列表
  Image, // 图片
  Food, // 膳食
  Related, // 相关数据展示行
}

enum RichStyle {
  Normal,
  Bold,
  Italic,
}

/// 富文本的行
/// [type] 是行的类型，[fontStyle]是行的显示字体风格，一般不用设定，自动设置为默认值
/// [leading]是列表类型的前导符号，目前不用设置。如果是有序列表，将由整理方法自动设置成
/// 序号，如果是无序列表，将由整理方法设置成指定符号
class RichLine {
  RichLine({
    @required this.type,
    this.style = RichStyle.Normal,
    this.indent = 0,
    this.note = 0,
    this.content = '',
    this.expandData,
    this.visibleLevel = 0,
  });

  RichType type;
  RichStyle style;
  int indent;

  /// RichLine是[note]的文本段落，note既可以是一个class，也可以是一个Id。
  Object note;

  /// [leading]是有序列表和无序列表的缩进级别
  String leading;

  /// [content]是line的直接数据内容，都以String的形式保存，图片也是。
  /// 但当line具有[expandData]数据时，line的文本数据就在[expandData]里，所以在系统里
  /// 调用line的数据时建议采用能够自动区分[type]进行存取的[text]属性获取。
  String content;

  /// [expandData]是复杂的扩展数据，task等。存放的是对象的引用。
  Object expandData = Object();

  /// [visibleLevel]是可视级别，当为0时完全可见，当>0时，根据当前用户设置的对应级别可见。
  int visibleLevel = 0;

  /// [createTime]创建的时间
  DateTime createTime;

  /// [getContent]是能够根据line[type]进行内容存储的自定义属性。
  String getContent() {
    if (type == RichType.Task) {
      assert(expandData != null);
      TaskItem task = expandData;
      return task.title;
    }
    return content;
  }

  void setContent(String value) {
    if (type == RichType.Task) {
      assert(expandData != null);
      TaskItem task = expandData;
      task.title = value;
    } else {
      content = value;
    }
  }

  String get cleanText => getContent().replaceAll('\u0000', '');

  void copyWith(RichLine other) {
    this.type = other.type;
    this.style = other.style;
    this.indent = other.indent;
    this.content = other.content;
    this.expandData = other.expandData;
    this.visibleLevel = other.visibleLevel;
  }

  /// RichLine转换成json文本后持久化。对于[RichType.Task]类型的line，将把[TaskItem]的[boxId]
  /// 提取出来放在[tk]里面。
  /// 读取持久化数据时，如果line类型是[RichType.Task]，就先把[tk]的[boxId]值读取
  /// 到[expandData]属性，然后在装配[TaskItem]数据到[expandData]里。

  factory RichLine.fromJson(Map<String, dynamic> json) {
    return RichLine(
      type: RichType.values[json['tp']],
      style: RichStyle.values[json['sy']],
      indent: json['ent'],
      content: json['txt'],
      expandData: json['tk'],
      visibleLevel: json['vl'],
    );
  }

  Map<String, dynamic> toJson() => {
        'tp': type.index,
        'sy': style.index,
        'ent': indent,
        'txt': content,
        'tk': type == RichType.Task ? (expandData as TaskItem).boxId : 0,
        'vl': visibleLevel,
      };
}

/// 编辑器使用的line数据，里面包含了文本输入与焦点控制
class RichItem extends RichLine {
  RichItem({
    @required type,
    @required this.source,
    String content = '',
  }) : super(
          type: type,
        ) {
    if (type == RichType.Task) {
      expandData = TaskItem(
          createDate: source.dayIndex, focusItemId: source.focusItemId);
    }
    textkey = GlobalKey();
    focusNode = FocusNode();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        canChanged = true;
        source.richNote.focusIsChanging();
        String text = controller.text.replaceAll('\u0000', '');
        debugPrint(
            'Line 详细数据: controller.text -> $text, type -> ${type.toString()}');
      }
    });

    controller = TextEditingController();
    controller.addListener(() {
      correctCursorPosition();
    });
    controller.text = buildEditerText(content);
  }

  RichItem.from({
    @required RichLine richLine,
    @required this.source,
  }) : super(type: richLine.type) {
    textkey = GlobalKey();
    focusNode = FocusNode();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        canChanged = true;
        source.richNote.focusIsChanging();
        String text = controller.text.replaceAll('\u0000', '');
        debugPrint(
            'Line 详细数据: controller.text -> $text, type -> ${type.toString()}');
      }
    });

    controller = TextEditingController();
    controller.addListener(() {
      correctCursorPosition();
    });

    type = richLine.type;
    style = richLine.style;
    indent = richLine.indent;
    note = richLine.note;
    visibleLevel = richLine.visibleLevel;
    this.source = source;
    if (type == RichType.Task) {
      TaskItem oldTask = richLine.expandData;
      TaskItem newTask = TaskItem.copyWith(oldTask);
      newTask.title = buildEditerText(oldTask.title);
      this.expandData = newTask;
      controller.text = newTask.title;
      //print('复制了richLine的task数据：${newTask.title} / ${newTask.createDate}');
    } else {
      content = buildEditerText(richLine.content);
      controller.text = content;
      //print('复制了richLine的基本数据');
    }
  }

  String image;
  bool canChanged = true;
  int objectDayIndex = 0;
  int lineIndex = -1;
  RichSource source;

  Key textkey;
  TextEditingController controller;
  FocusNode focusNode;

  String get editContent => type == RichType.Image ? image : controller.text;

  void dispose() {
    controller?.dispose();
    focusNode?.dispose();
  }

  /// 修正光标位置
  void correctCursorPosition() {
    if (!canChanged || controller.text.isEmpty) return;
    var start = controller.selection.start;
    var end = controller.selection.end;

    debugPrint(
        'controller selection.start = $start  $end , controller.text.lenght = ${controller.text.length}');

    if (start == 0) {
      if (start == end) {
        // && controller.text.length >= 1
        controller.selection = TextSelection.fromPosition(TextPosition(
          affinity: TextAffinity.downstream,
          offset: 1,
        ));
      } else {
        controller.selection = TextSelection(
            baseOffset: 1, extentOffset: controller.selection.extentOffset);
      }
    }
  }

  String buildEditerText(String text) {
    String buildText;
    if (text.length >= 1 && text.substring(0, 1) == '\u0000') {
      buildText = text;
    } else {
      buildText = '\u0000' + text;
    }
    return buildText;
  }

  void changeTypeTo(RichType newType) {
    if (type == newType) return;
    if (newType == RichType.Task) {
      assert(source.richNote.store.selectedDateIndex != null);
      if (expandData is! TaskItem) {
        expandData = TaskItem(
          createDate: source.dayIndex,
          startDate: source.dayIndex,
          dueDate: source.dayIndex,
          focusItemId: source.focusItemId
        );
        debugPrint('新建了一个TaskItem记录, dayIndex：${source.dayIndex}');
      }
    }
    type = newType;
  }

  TaskItem get taskItem {
    if (type != RichType.Task) return null;
    assert(expandData is TaskItem);
    return expandData as TaskItem;
  }
}

class RichSource {
  RichSource(lineList) : assert(lineList != null) {
    this.richLineList = lineList ?? [];
  }

  RichSource.fromFocusEvent(
    this.focusEvent,
  )   : assert(focusEvent != null),
        this.richLineList = focusEvent.noteLines;
  //this.focusItemBoxId = focusEvent.focusItemBoxId,
  //this.dayIndex = focusEvent.dayIndex;

  RichSource.fromJson(
    String jsonString,
  ) : assert(jsonString != null) {
    this.richLineList = RichSource.getRichLinesFromJson(jsonString) ?? [];
  }

  static List<RichLine> getRichLinesFromJson(String jsonString) {
    if (jsonString.length == 0) return List<RichLine>();
    List<dynamic> resultJson = json.decode(jsonString) as List;
    List<RichLine> source =
        resultJson.map((item) => RichLine.fromJson(item)).toList();
    return source;
  }

  static String getJsonFromRichLine(List<RichLine> paragraphList) {
    return json.encode(paragraphList);
  }

  List<RichLine> richLineList;
  List<TaskItem> mergeRemoveTask = [];
  RichNote richNote;
  FocusEvent focusEvent;
  int get focusItemId => focusEvent.focusItemBoxId;
  int get dayIndex => focusEvent.dayIndex;

  void dispose() {
    if (!richNote.isEditable) return;
    richLineList?.forEach((paragraph) {
      RichItem item = paragraph;
      item?.dispose();
    });
  }

  void markEditerItem() {
    debugPrint('生成编辑器使用的RichItem');
    if (richNote.isNotEditable) return;
    List<RichLine> tempList = [];
    if (richLineList.length == 0) {
      tempList.add(RichItem(
        source: this,
        type: RichType.Text,
      ));
    } else {
      richLineList.forEach((it) {
        tempList.add(RichItem.from(
          richLine: it,
          source: this,
        ));
      });
    }
    richLineList = tempList;
  }

  List<RichLine> exportingRichLists() {
    /// [mergeRemoveTask]保存的是进入编辑器以后生成的复制数据，只有boxId是唯一的标识
    /// 所以删除合并后废弃的line数据附带的task，只能通过boxId来操作。
    mergeRemoveTask.forEach((task) {
      debugPrint('清理合并行后遗弃的数据：ID = ${task.boxId}');
      richNote.store.taskSet.removeItemByBoxId(task.boxId);
    });
    return _getRichLines();
  }

  List<RichLine> _getRichLines() {
    if (richNote.isNotEditable) return richLineList;
    List<RichLine> richLines = [];

    richLineList.forEach((line) async {
      RichItem item = line;
      var content = '';
      if (item.type == RichType.Task) {
        TaskItem task = item.expandData;
        task.title = item.controller.text.replaceAll('\u0000', '');
        if (item.objectDayIndex != 0) {
          /// 当[task.boxId == 0]表明[task]是刚刚转换过来的[TaskItem]数据，没有保
          /// 存过，所以[trueTask]就可以指向[task], 反之，说明[task]是原来的数据
          /// 这里是一个副本，所以需要通过[task.boxId]找到真实的实例
          var trueTask = task.boxId == 0
            ? task
            : richNote.store.taskSet.getItemFromId(task.boxId);
          trueTask
            ..startDate = item.objectDayIndex
            ..dueDate = item.objectDayIndex + (task.dueDate - task.startDate)
            ..title = task.title;
          richNote.store.addTaskToFocusEventInDailyRecord(trueTask,
              richNote.focusEvent.focusItemBoxId, item.objectDayIndex);
        } else {
          richLines.add(RichLine(
            type: item.type,
            style: item.style,
            indent: item.indent,
            note: item.note,
            //content: content,
            expandData: item.expandData,
          ));
        }
      } else {
        richLines.add(RichLine(
          type: item.type,
          style: item.style,
          indent: item.indent,
          note: item.note,
          content: item.controller.text.replaceAll('\u0000', ''),

          /// 不是[RichType.Task]类型的line也可能是task转换过来的，那样肯定携带
          /// expandData数据，让store的changeTaskItemFromFocusEvent处理
          expandData: item.expandData,
        ));
      }
    });
    print('返回了${richLines.length}行数据');
    return richLines;
  }

  String getJsonFromLineList() {
    if (richNote.isEditable) {
      return json.encode(_getRichLines());
    }
    return json.encode(richLineList);
  }

  // TODO: 判断一行是否有数据应该用isEmpty，待优化
  bool hasNote() {
    int words = 0;
    for (var line in richLineList) {
      RichItem item = line;
      String txt = item.controller.text.replaceAll('\u0000', '');
      words += txt.length;
    }
    return words > 0;
  }
}

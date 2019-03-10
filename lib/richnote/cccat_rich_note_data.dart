import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_moment/models/models.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_widget.dart';
import 'package:flutter_moment/task/TaskItem.dart';
import 'package:meta/meta.dart';

enum RichType {
  FocusTitle,     // 焦点标题
  Title,          // 标题
  SubTitle,       // 子标题
  Task,           // 任务
  Text,           // 标准文本
  Comment,        // 评论
  Reference,      // 引用
  UnorderedList,  // 无序列表
  OrderedLists,   // 有序列表
  Image,          // 图片
  Food,           // 膳食
  Related,        // 相关数据展示行
}

enum RichStyle {
  Normal,
  Bold,
  Italic,
}

/// 富文本的行
/// {type} 是行的类型，{fontStyle}是行的显示字体风格，一般不用设定，自动设置为默认值
/// (Leading)是列表类型的前导符号，目前不用设置。如果是有序列表，将由整理方法自动设置成
/// 序号，如果是无序列表，将由整理方法设置成指定符号
class RichLine {
  RichLine({
    @required this.type,
    this.style = RichStyle.Normal,
    this.indent = 0,
    this.note = 0,
    this.content = '',
    this.expandData,
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

  void copyWith(RichLine other) {
    this.type = other.type;
    this.style = other.style;
    this.indent = other.indent;
    this.content = other.content;
    this.expandData = other.expandData;
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
    );
  }

  Map<String, dynamic> toJson() => {
        'tp': type.index,
        'sy': style.index,
        'ent': indent,
        'txt': content,
        'tk': type == RichType.Task ? (expandData as TaskItem).boxId : 0,
      };
}

/// 编辑器使用的line数据，里面包含了文本输入与焦点控制
class RichItem extends RichLine {
  RichItem({
    @required type,
    @required this.source,
    @required dayIndex,
    content = '',
  }) : super(
    type: type,
  ) {
    if (type == RichType.Task) {
      expandData = TaskItem(createDate: dayIndex);
    }
    textkey = UniqueKey();
    checkBoxKey = UniqueKey();
    controller = TextEditingController();
    controller.text = '\u0000' + content;
    node = FocusNode();
    node.addListener(() {
        if (node.hasFocus) {
          canChanged = true;
        }
    });
  }

  RichItem.from({
    @required RichLine richLine,
    @required this.source,
    @required dayIndex,
  }): super(type: richLine.type){
    textkey = UniqueKey();
    checkBoxKey = UniqueKey();
    node = FocusNode();
    node.addListener(() {
      if (node.hasFocus) {
        canChanged = true;
      }
    });
    controller = TextEditingController();
    type = richLine.type;
    style = richLine.style;
    indent = richLine.indent;
    note = richLine.note;
    this.source = source;
    if (type == RichType.Task) {
      TaskItem other = richLine.expandData;
      TaskItem newTask = TaskItem.copyWith(other);
      if (dayIndex != null) newTask.createDate = dayIndex;
      newTask.title = '\u0000' + other.title;
      this.expandData = newTask;
      controller.text = newTask.title;
      print('复制了richLine的task数据：${newTask.title} / ${newTask.createDate}');
    } else {
      content = '\u0000' + richLine.content;
      controller.text = content;
      print('复制了richLine的基本数据');
    }
  }

  String image;
  bool canChanged = true;
  RichSource source;

  Key textkey;
  Key checkBoxKey;
  TextEditingController controller;
  FocusNode node;

  String get editContent => type == RichType.Image ? image : controller.text;

  void dispose() {
    controller?.dispose();
    node?.dispose();
  }

  void changeTypeTo(RichType newType) {
    if (type == newType) return;
    if (newType == RichType.Task) {
      assert(source.richNote.store.selectedDateIndex != null);
      if (expandData is! TaskItem) {
        expandData = TaskItem(createDate: source.richNote.store.selectedDateIndex);
        debugPrint('新建了一个TaskItem记录:');
      }
      TaskItem task = expandData;
      //task.title = content;
      task.createDate = source.richNote.store.selectedDateIndex;
      print('任务的日期序号：${source.richNote.store.selectedDateIndex}');
    } else {
//      if (type == RichType.Task) {
//        if (expandData is TaskItem ) {
//          TaskItem task = expandData;
//          content = task.title;
//          debugPrint('将原来Task类型的数据复制过来了');
//        }
//      }
    }
    type = newType;
  }
}

class RichSource {
  RichSource(
    paragraphList,
  ) : assert(paragraphList != null) {
    this.richLineList = paragraphList ?? [];
  }

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

  void dispose() {
    if (!richNote.isEditable) return;
    richLineList?.forEach((paragraph) {
      RichItem item = paragraph;
      item?.dispose();
    });
  }

  void markEditerItem() {
    debugPrint('生成编辑器使用的line');
    if (richNote.isNotEditable) return;
    List<RichLine> tempList = [];
    if (richLineList.length == 0) {
      tempList.add(RichItem(
        source: this,
        type: RichType.Text,
        dayIndex: richNote.store.selectedDateIndex,
      ));
    } else {
      richLineList.forEach((it) {
//          if (it.type == RichType.Task) {
//            TaskItem task = it.expandData;
//            task.title = '\u0000' + task.title;
//          }
//        tempList.add(RichItem(
//          source: this,
//          type: it.type,
//          style: it.style,
//          indent: it.indent,
//          content: '\u0000' + it.content,
//          expandData: it.expandData,
//        ));
        tempList.add(RichItem.from(
            richLine: it,
            source: this,
            dayIndex: richNote.store.selectedDateIndex,
        ));
      });
    }
    richLineList = tempList;
  }

  List<RichLine> exportingRichLists() {
    /// [mergeRemoveTask]保存的是进入编辑器以后生成的复制数据，只有boxId是唯一的标识
    /// 所以删除合并后废弃的line数据附带的task，只能通过boxId来操作。
    mergeRemoveTask.forEach((task){
      print('清理合并行遗弃的数据：ID = ${task.boxId}');
      richNote.store.removeTaskItemFromId(task.boxId);
    });
    return _getRichLines();
  }

  List<RichLine> _getRichLines() {
    List<RichLine> richLines = [];
    if (richNote.isNotEditable) return richLineList;

    richLineList.forEach((line) {
      RichItem item = line;
      var content = '';
      if (item.type == RichType.Task) {
        TaskItem task = item.expandData;
        task.title = item.controller.text.replaceAll('\u0000', '');
        richLines.add(RichLine(
          type: item.type,
          style: item.style,
          indent: item.indent,
          note: item.note,
          //content: content,
          expandData: item.expandData,
        ));
      } else {
        richLines.add(RichLine(
          type: item.type,
          style: item.style,
          indent: item.indent,
          note: item.note,
          content: item.controller.text.replaceAll('\u0000', ''),
          /// 不是[RichType.Task]类型的line也可能是task转换过来的，必须携带expandData数据
          /// 让store的changeTaskItemFromFocusEvent处理
          expandData: item.expandData,
        ));
      }
    });
    print('返回了${richLines.length}行数据');
    return richLines;
  }

  String getJsonFromParagraphList() {
    if (richNote.isEditable) {
      return json.encode(_getRichLines());
    }
    return json.encode(richLineList);
  }

  bool hasNote() {
    int words = 0;
    richLineList.forEach((line) {
      words += line.getContent().length;
    });
    return true;//words > 0;
  }
}

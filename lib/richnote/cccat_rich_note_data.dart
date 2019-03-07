import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_moment/models/models.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_widget.dart';
import 'package:flutter_moment/task/TaskItem.dart';
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
  Object expandData;

  /// [text]是能够根据line[type]进行内容存储的自定义属性。
  String get text {
    if (type == RichType.Task) {
      assert(expandData != null);
      TaskItem task = expandData;
      return task.title;
    }
    return content;
  }

  set text(String value) {
    if (type == RichType.Task) {
      assert(expandData != null);
      TaskItem task = expandData;
      task.title = value;
    } else {
      content = value;
    }
  }

  Map<int, PersonItem> persons;

  void changeTypeTo(RichType newType) {
    if (type == newType) return;
    if (newType == RichType.Task && type != RichType.Task) {
      if (expandData == null) {
        expandData = TaskItem();
      }
      TaskItem task = expandData;
      task.title = content;
    } else {
      if (newType != RichType.Task && type == RichType.Task) {
        if (expandData != null ) {
          TaskItem task = expandData;
          content = task.title;
        }
      }
    }
    type = newType;
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
    style = RichStyle.Normal,
    indent = 0,
    focusEventId = 0,
    content = '',
    expandData,
  }) : super(
          type: type,
          style: style,
          indent: indent,
          note: focusEventId,
          content: content,
          expandData: expandData,
        ) {
    if (type != RichType.Image) {
      key = GlobalKey();
      controller = TextEditingController();
      node = FocusNode();
      node.addListener(() {
        if (node.hasFocus) {
          canChanged = true;
        }
      });
      controller.text = content;
    } else {
      image = content;
    }
  }

  String image;
  bool canChanged = true;

  Key key;
  TextEditingController controller;
  FocusNode node;

  String get editContent => type == RichType.Image ? image : controller.text;

  void dispose() {
    controller?.dispose();
    node?.dispose();
  }
}

class RichSource {
  RichSource(
    paragraphList,
  ) : assert(paragraphList != null) {
    this.paragraphList = paragraphList ?? [];
  }

  RichSource.fromJson(
    String jsonString,
  ) : assert(jsonString != null) {
    this.paragraphList = RichSource.getRichLinesFromJson(jsonString) ?? [];
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

  List<RichLine> paragraphList;
  RichNote richNote;

  void dispose() {
    if (!richNote.isEditable) return;
    paragraphList?.forEach((paragraph) {
      RichItem item = paragraph;
      item?.dispose();
    });
  }

  void markToEditer() {
    debugPrint('生成编辑器使用的line');
    if (richNote.isEditable) {
      List<RichLine> tempList = [];
      if (paragraphList.length == 0) {
        tempList.add(RichItem(
          type: RichType.Text,
          content: '\u0000' + '',
        ));
      } else {
        paragraphList.forEach((it) {
          tempList.add(RichItem(
            type: it.type,
            style: it.style,
            indent: it.indent,
            content: '\u0000' + it.content,
          ));
        });
      }
      paragraphList = tempList;
    }
  }

  List<RichLine> getParagraphList() {
    List<RichLine> tempList = [];
    if (!richNote.isEditable) return paragraphList;
    paragraphList.forEach((line) {
      RichItem item = line;
      tempList.add(RichLine(
        type: item.type,
        style: item.style,
        indent: item.indent,
        note: item.note,
        content: item.controller.text.replaceAll('\u0000', ''),
      ));
    });
    return tempList;
  }

  String getJsonFromParagraphList() {
    if (richNote.isEditable) {
      return json.encode(getParagraphList());
    }
    return json.encode(paragraphList);
  }

  bool hasNote() {
    int words = 0;
    paragraphList.forEach((line) {
      words += line.content.length;
    });
    return words > 0;
  }
}

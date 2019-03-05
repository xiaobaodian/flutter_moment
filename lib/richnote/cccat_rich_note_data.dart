

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_widget.dart';
import 'package:meta/meta.dart';

enum RichType {
  Title,              // 标题
  SubTitle,           // 子标题
  Task,               // 任务
  Text,               // 标准文本
  TextBold,           // 粗体文本
  Reference,          // 引用
  UnorderedList,      // 无序列表
  OrderedLists,       // 有序列表
  SubUnorderedList,   // 无序列表
  SubOrderedLists,    // 有序列表
  Image,              // 图片
  FocusTitle,         // 焦点标题
}

enum RichStyle {
  Normal,
  Bold,
  Italic,
}

enum RichState {
  StandBy,
  Complete,
  Delete,
  Execute,
  Await,
  Archive,
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
    this.createTime = '',
    this.beginTime = '',
    this.endTime = '',
    this.state = RichState.StandBy,
  });

  RichType type;
  RichStyle style;
  int indent;
  Object note;
  String leading;

  /// line的数据内容，都以String的形式保存，图片也是。
  String content;

  String createTime, beginTime, endTime;
  RichState state;

  void copyWith(RichLine other){
    this.type = other.type;
    this.style = other.style;
    this.indent = other.indent;
    this.content = other.content;
    this.createTime = other.createTime;
    this.beginTime = other.beginTime;
    this.endTime = other.endTime;
    this.state = other.state;
  }

  factory RichLine.fromJson(Map<String, dynamic> json) {
    return RichLine(
      type: RichType.values[json['tp']],
      style: RichStyle.values[json['sy']],
      indent: json['ent'],
      content: json['txt'],
      createTime: json['ct'],
      beginTime: json['bt'],
      endTime: json['et'],
      state: RichState.values[json['cs']],
    );
  }

  Map<String, dynamic> toJson() => {
    'tp': type.index,
    'sy': style.index,
    'ent': indent,
    'txt': content,
    'ct': createTime,
    'bt': beginTime,
    'et': endTime,
    'cs': state.index,
  };
}

/// 编辑器使用的line数据，里面包含了文本输入与焦点控制
class RichItem extends RichLine {
  RichItem({
    @required RichType type,
    RichStyle style = RichStyle.Normal,
    int indent = 0,
    int focusEventId = 0,
    String content = '',
    String createTime = '',
    String beginTime = '',
    String endTime = '',
    RichState state = RichState.StandBy,
  }) : super(
    type: type,
    style: style,
    indent: indent,
    note: focusEventId,
    content: content,
    createTime: createTime,
    beginTime: beginTime,
    endTime: endTime,
    state: state,
  ) {
    if (type != RichType.Image) {
      key = GlobalKey();
      controller = TextEditingController();
      node = FocusNode();
      node.addListener((){
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

  String get editContent =>
      type == RichType.Image ? image : controller.text;

  void dispose() {
    controller?.dispose();
    node?.dispose();
  }
}

class RichSource {
  RichSource(
    paragraphList,
  ): assert(paragraphList != null) {
    this.paragraphList = paragraphList ?? [];
  }

  RichSource.fromJson(
    String jsonString,
  ): assert(jsonString != null) {
    this.paragraphList = RichSource.getRichLinesFromJson(jsonString) ?? [];
  }

  static List<RichLine> getRichLinesFromJson(String jsonString) {
    if (jsonString.length == 0) return List<RichLine>();
    List<dynamic> resultJson = json.decode(jsonString) as List;
    List<RichLine> source = resultJson.map((item) => RichLine.fromJson(item)).toList();
    return source;
  }

  static String getJsonFromRichLine(List<RichLine> paragraphList) {
    return json.encode(paragraphList);
  }

  List<RichLine> paragraphList;
  RichNote richNote;

  void dispose() {
    if (!richNote.isEditable) return;
    paragraphList?.forEach((paragraph){
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
            createTime: it.createTime,
            beginTime: it.beginTime,
            endTime: it.endTime,
            state: it.state,
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
        note: item.note,
        content: item.controller.text.replaceAll('\u0000', ''),
        createTime: item.createTime,
        beginTime: item.beginTime,
        endTime: item.endTime,
        state: item.state,
      ));
    });
    return tempList;
  }

  String getJsonFromParagraphList(){
    if (richNote.isEditable) {
      return json.encode(getParagraphList());
    }
    return json.encode(paragraphList);
  }

  bool hasNote() {
    int words = 0;
    paragraphList.forEach((line){
      words += line.content.length;
    });
    return words > 0;
  }
}

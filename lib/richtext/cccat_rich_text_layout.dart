import 'package:flutter/material.dart';
import 'package:flutter_moment/richtext/cccat_rich_text.dart';

enum RichLineType {
  Title, // 标题
  SubTitle, // 子标题
  Task, // 任务
  Text, // 标准文本
  TextBold, // 粗体文本
  Reference, // 引用
  UnorderedList, // 无序列表
  OrderedLists, // 有序列表
  Image, // 图片
}

class RichTextLayout {
  RichTextLayout(
    BuildContext context, {
    this.segmentSpacing = 12.0,
    this.listLineSpacing = 3.0,
    this.leadingSymbols = '•',
    this.titleStyle,
    this.subTitleStyle,
    this.contentStyle,
    this.contentBoldStyle,
    this.taskStyle,
    this.orderedListsStyle,
    this.unorderedListStyle,
    this.referenceStyle,
    this.imageTextStyle,
  })  : defaultTextStyle = DefaultTextStyle.of(context),
        textTheme = Theme.of(context).textTheme;

  final double segmentSpacing;
  final double listLineSpacing;
  final String leadingSymbols;
  final TextTheme textTheme;
  final DefaultTextStyle defaultTextStyle;
  final TextStyle titleStyle;
  final TextStyle subTitleStyle;
  final TextStyle contentStyle;
  final TextStyle contentBoldStyle;
  final TextStyle taskStyle;
  final TextStyle orderedListsStyle;
  final TextStyle unorderedListStyle;
  final TextStyle referenceStyle;
  final TextStyle imageTextStyle;

  /// 基础布局

  Widget richLayoutText(Widget widget) {
    return widget;
  }

  Widget richLayoutTask(Widget task, Widget time) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
            child: SizedBox(
              height: 32,
              width: 32,
              child: Checkbox(
                value: true,
                onChanged: (isSelected) {
                  isSelected = !isSelected;
                },
              ),
            ),
          ),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              task,
              time,
            ],
          )),
        ]);
  }

  Widget richLayoutList(Widget leading, Widget widget) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(3, 3, 12, 0),
            child: leading,
          ),
          Expanded(
            child: widget,
          ),
        ]);
  }

  Widget richLayoutReference(Widget widget) {
    return Container(
      child: widget,
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.black12,
        border: Border(left: BorderSide(color: Colors.black26, width: 5.0)),
      ),
    );
  }

  Widget richLayoutImage(Widget widget) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Placeholder(),
    );
  }

}

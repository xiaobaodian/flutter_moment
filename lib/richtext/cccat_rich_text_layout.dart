import 'package:flutter/material.dart';
import 'package:flutter_moment/richtext/cccat_rich_text.dart';

enum RichLineType {
  Title,            // 标题
  SubTitle,         // 子标题
  Task,             // 任务
  Text,             // 标准文本
  TextBold,         // 粗体文本
  Reference,        // 引用
  UnorderedList,    // 无序列表
  OrderedLists,     // 有序列表
  Image,            // 图片
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
  }) : defaultTextStyle = DefaultTextStyle.of(context);

  final double segmentSpacing;
  final double listLineSpacing;
  final String leadingSymbols;
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

  Widget richLayoutTask(Widget widget) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
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
          Expanded(child: widget),
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
        ]
    );
  }

  Widget richLayoutReference(Widget widget) {
    return Container(
      child: widget,
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.black12,
        border: Border(left: BorderSide(color: Colors.black26, width: 3.0)),
      ),
    );
  }

  Widget richLayoutImage(Widget widget) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Placeholder(),
    );
  }

  /// 分类布局

  Widget getTitleLayout(String title) {
    var effectiveSytle = titleStyle == null
        ? TextStyle(fontSize: 18)
        : titleStyle;
    return richLayoutText(Text(
      title,
      style: effectiveSytle,
    ));
  }

  Widget getSubTitleLayout(String subtitle) {
    var effectiveSytle = subTitleStyle == null
        ? TextStyle(fontSize: 16)
        : subTitleStyle;
    return richLayoutText(Text(
      subtitle,
      style: effectiveSytle,
    ));
  }

  Widget getContentLayout(String text) {
    var effectiveSytle = contentStyle == null
        ? TextStyle(fontSize: 14)
        : contentStyle;
    return richLayoutText(Text(
      text,
      style: effectiveSytle,
    ));
  }

  Widget getContentBoldLayout(String text) {
    var effectiveSytle = contentBoldStyle == null
        ? TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
        : contentBoldStyle;
    return richLayoutText(Text(
      text,
      style: effectiveSytle,
    ));
  }

  Widget getTaskLayout(String text) {
    var effectiveSytle = taskStyle == null
        ? TextStyle(fontSize: 14)
        : taskStyle;
    return richLayoutTask(Text(text, style: effectiveSytle));
  }

  Widget getOrderedListsLayout(String leading, String text) {
    var effectiveSytle = orderedListsStyle == null
        ? TextStyle(fontSize: 12) //defaultTextStyle.style.merge(TextStyle(fontSize: 12))
        : orderedListsStyle;
    return richLayoutList(Text('$leading.', style: effectiveSytle),
        Text(text, style: effectiveSytle, softWrap: true));
  }

  Widget getUnorderedListLayout(String text) {
    var effectiveSytle = unorderedListStyle == null
        ? TextStyle(fontSize: 12)
        : unorderedListStyle;
    return richLayoutList(Text(leadingSymbols, style: effectiveSytle),
        Text(text, style: effectiveSytle));
  }

  Widget getReferenceLayout(String text) {
    var effectiveSytle = referenceStyle == null
        ? TextStyle(fontSize: 12)
        : referenceStyle;
    return richLayoutReference(Text(text, style: effectiveSytle));
  }

  Widget getImageLayout(String image) {
    return richLayoutImage(
      Text(
        '这里是图片',
        style: TextStyle(fontSize: 12),
      ),
    );
  }

  ///

  Widget getLayoutWidget(RichTextLine item){
    Widget lineWidget;
    switch (item.type) {
      case RichLineType.Title :
        lineWidget = getTitleLayout(item.content);
        break;
      case RichLineType.SubTitle :
        lineWidget = getSubTitleLayout(item.content);
        break;
      case RichLineType.Text :
        lineWidget = getContentLayout(item.content);
        break;
      case RichLineType.TextBold :
        lineWidget = getContentBoldLayout(item.content);
        break;
      case RichLineType.Task :
        lineWidget = getTaskLayout(item.content);
        break;
      case RichLineType.OrderedLists :
        lineWidget = getOrderedListsLayout(item.leading, item.content);
        break;
      case RichLineType.UnorderedList :
        lineWidget = getUnorderedListLayout(item.content);
        break;
      case RichLineType.Reference :
        lineWidget = getReferenceLayout(item.content);
        break;
      case RichLineType.Image :
        lineWidget = getImageLayout(item.content);
        break;
    }
    return lineWidget;
  }

}

///

double getRichsegmentSpacing(RichLineType type){
  switch (type) {
    case RichLineType.Title :
      return 6.0;
      break;
    case RichLineType.SubTitle :
      return 6.0;
      break;
    case RichLineType.Text :
      return 6.0;
      break;
    case RichLineType.TextBold :
      return 6.0;
      break;
    case RichLineType.Task :
      return 6.0;
      break;
    case RichLineType.OrderedLists :
      return 3.0;
      break;
    case RichLineType.UnorderedList :
      return 3.0;
      break;
    case RichLineType.Reference :
      return 6.0;
      break;
    case RichLineType.Image :
      return 6.0;
      break;
  }
  return 6.0;
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class CCCatRichText extends StatelessWidget{
  CCCatRichText({
    this.segmentSpacing = 6.0,
    this.listLineSpacing = 3.0,
    this.leadingSymbols = '-',
  }): isEditable = false;

  CCCatRichText.editable({
    this.segmentSpacing = 6.0,
    this.listLineSpacing = 3.0,
    this.leadingSymbols = '-',
  }): isEditable = true;

  final bool isEditable;
  final double segmentSpacing;
  final double listLineSpacing;
  final String leadingSymbols;

  final List<RichTextItem> contentList = [];

  void dispose() {
    if (isEditable) {
      contentList.forEach((content) {
        content.dispose();
      });
    }
  }

  void setContent(List<RichTextLine> content) {
    content.forEach((it){
      contentList.add(RichTextItem(line: it));
    });
  }

  Widget getTitleLine(RichTextItem item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Text(item.line.content,
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget getSubTitleLine(RichTextItem item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Text(item.line.content,
        style: TextStyle(fontSize: 12),
      ),
    );
  }

  Widget getTextLine(RichTextItem item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Text(item.line.content,
        style: TextStyle(fontSize: 14),
      ),
    );
  }

  Widget getTextBoldLine(RichTextItem item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Text(item.line.content,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget getTaskLine(RichTextItem item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 60,
              height: double.infinity,
              child: Text('task', style: TextStyle(fontSize: 12)),
            ),
            Text(item.line.content, style: TextStyle(fontSize: 12),
            ),
          ]
      ),
    );
  }

  Widget getOrderedListsLine(RichTextItem item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 60,
              height: double.infinity,
              child: Text(item.line.leading, style: TextStyle(fontSize: 12)),
            ),
            Text(item.line.content, style: TextStyle(fontSize: 12),
            ),
          ]
      ),
    );
  }

  Widget getUnorderedListLine(RichTextItem item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 60,
              height: double.infinity,
              child: Text(leadingSymbols, style: TextStyle(fontSize: 12)),
            ),
            Text(item.line.content, style: TextStyle(fontSize: 12),
            ),
          ]
      ),
    );
  }

  Widget getReferenceLine(RichTextItem item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 60,
              height: double.infinity,
              child: Text(leadingSymbols, style: TextStyle(fontSize: 12)),
            ),
            Text(item.line.content, style: TextStyle(fontSize: 12),
            ),
          ]
      ),
    );
  }

  Widget getImageLine(RichTextItem item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 60,
              height: double.infinity,
              child: Text(leadingSymbols, style: TextStyle(fontSize: 12)),
            ),
            Text(item.line.content, style: TextStyle(fontSize: 12),
            ),
          ]
      ),
    );
  }

  Widget getRichLineWidget(RichTextItem item){
    Widget lineWidget;
    switch (item.line.type) {
      case RichLineType.Title :
        lineWidget = getTitleLine(item);
        break;
      case RichLineType.SubTitle :
        lineWidget = getSubTitleLine(item);
        break;
      case RichLineType.Text :
        lineWidget = getTextLine(item);
        break;
      case RichLineType.TextBold :
        lineWidget = getTextBoldLine(item);
        break;
      case RichLineType.Task :
        lineWidget = getTaskLine(item);
        break;
      case RichLineType.OrderedLists :
        lineWidget = getOrderedListsLine(item);
        break;
      case RichLineType.UnorderedList :
        lineWidget = getUnorderedListLine(item);
        break;
      case RichLineType.Reference :
        lineWidget = getReferenceLine(item);
        break;
      case RichLineType.Image :
        lineWidget = getImageLine(item);
        break;
    }
    return lineWidget;
  }

  void splitLine(BuildContext context, int index, List<String> lines) {
    RichTextLine newLine;
    if (lines.length > 1) {
      debugPrint('第二行字数：${lines[1].length}');
      contentList[index].editingController.text = lines[0];
//      setState(() {
//        newLine = RichTextLine(lines[1]);
//        richTextLine.insert(index+1, newLine);
//      });
      newLine = RichTextLine(type: contentList[index].line.type, content: lines[1]);
      var newItem = RichTextItem(line: newLine);
      contentList.insert(index + 1, newItem);
      Future.delayed(const Duration(milliseconds: 200), () {
        var focusScopeNode = FocusScope.of(context);
        focusScopeNode.requestFocus(newItem.focusNode);
      });
    }
  }

  void gotoNextLine(BuildContext context, int index) {
    if (index < contentList.length - 1) {
      var focusScopeNode = FocusScope.of(context);
      focusScopeNode.requestFocus(contentList[index+1].focusNode);
    }
  }

  void gotoLine(BuildContext context, int index) {
    var focusScopeNode = FocusScope.of(context);
    focusScopeNode.requestFocus(contentList[index].focusNode);
  }

  Widget geTextField(BuildContext context, int index) {
    var item = contentList[index];
    assert(item.editingController != null);
    assert(item.focusNode != null);
    return RawKeyboardListener(
      focusNode: item.focusNode,
      child: TextField(
        maxLines: null,
        //maxLength: 300,
        inputFormatters: [ LengthLimitingTextInputFormatter(300), ],
        autofocus: true,
        textAlign: TextAlign.justify,
        style: getDefaultTextStyle(item.line.type),
        textInputAction: TextInputAction.newline,
        focusNode: item.focusNode,
        controller: item.editingController,
        decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(2)
        ),
        onEditingComplete: () {
          //gotoNextLine(index);
          debugPrint('是不是按了回车键');
        },
        onSubmitted: (text){
          debugPrint('是不是按了回车键');
        },
        onChanged: (text) {
          if (item.canChanged) {
            item.canChanged = false;
            var line = text.split('\n');
            splitLine(context, index, line);
          } else {
            item.canChanged = true;
          }
        },
      ),
      onKey: (RawKeyEvent event) {
        debugPrint('能够捕获按键码');
        RawKeyEventDataAndroid key = event.data;
        print('KeyCode: ${key.keyCode}, CodePoint: ${key.codePoint}, '
            'Flags: ${key.flags}, MetaState: ${key.metaState}, '
            'ScanCode: ${key.scanCode}');
        if (event is RawKeyDownEvent) {
          RawKeyDownEvent rawKeyDownEvent = event;
          RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
          print(rawKeyEventDataAndroid.keyCode);
          switch (rawKeyEventDataAndroid.keyCode) {
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListView.separated(
      itemBuilder: (context, index){
        return getRichLineWidget(contentList[index]);
      },
      separatorBuilder: (context, index){},
      itemCount: contentList.length,
    );
  }
}

/// 富文本的行
/// {type} 是行的类型，{fontStyle}是行的显示字体风格，一般不用设定，自动设置为默认值
/// (Leading)是列表类型的前导符号，目前不用设置。如果是有序列表，将由整理方法自动设置成
/// 序号，如果是无序列表，将由整理方法设置成指定符号
class RichTextLine {
  RichTextLine({
    @required this.type,
    this.content,
  });

  RichLineType type;
  String leading;

  /// line的数据内容，都以String的形式保存，图片也是。
  String content;
}

class RichTextItem {
  RichTextItem({
    this.line,
  });

  final RichTextLine line;
  TextEditingController editingController;
  FocusNode focusNode;
  bool canChanged = true;

  void init() {
    editingController = TextEditingController();
    focusNode = FocusNode();
  }

  void dispose() {
    editingController?.dispose();
    focusNode?.dispose();
  }

}

TextStyle getDefaultTextStyle(RichLineType type) {
  TextStyle textStyle;
  switch (type) {
    case RichLineType.Title :
      textStyle = TextStyle(
        fontSize: 14,
        color: Colors.black87,
        textBaseline: TextBaseline.ideographic,
      );
      break;
    case RichLineType.SubTitle :
      textStyle = TextStyle(
        fontSize: 14,
        color: Colors.black87,
        textBaseline: TextBaseline.ideographic,
      );
      break;
    case RichLineType.Text :
      textStyle = TextStyle(
        fontSize: 14,
        color: Colors.black87,
        textBaseline: TextBaseline.ideographic,
      );
      break;
    case RichLineType.TextBold :
      textStyle = TextStyle(
        fontSize: 14,
        color: Colors.black87,
        fontWeight: FontWeight.bold,
        textBaseline: TextBaseline.ideographic,
      );
      break;
    case RichLineType.Task :
      textStyle = TextStyle(
        color: Colors.black87,
        fontSize: 14,
        textBaseline: TextBaseline.ideographic,
      );
      break;
    case RichLineType.OrderedLists :
      textStyle = TextStyle(
        fontSize: 12,
        color: Colors.black87,
        textBaseline: TextBaseline.ideographic,
      );
      break;
    case RichLineType.UnorderedList :
      textStyle = TextStyle(
        fontSize: 12,
        color: Colors.black87,
        textBaseline: TextBaseline.ideographic,
      );
      break;
    case RichLineType.Reference :
      textStyle = TextStyle(
        fontSize: 12,
        color: Colors.black45,
        textBaseline: TextBaseline.ideographic,
      );
      break;
    case RichLineType.Image :
      textStyle = TextStyle(
        fontSize: 12,
        color: Colors.black87,
        textBaseline: TextBaseline.ideographic,
      );
      break;
  }
  return textStyle;
}
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

class CCCatRichText extends StatefulWidget{
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

  @override
  CCCatRichTextState createState() {
    return new CCCatRichTextState();
  }
}

class CCCatRichTextState extends State<CCCatRichText> {
  final List<RichTextItem> contentList = [];

  @override
  void dispose() {
    super.dispose();
    if (widget.isEditable) {
      contentList.forEach((content) {
        content.dispose();
      });
    }
  }

  void setContent(List<RichTextLine> content) {
    content.forEach((it){
      contentList.add(RichTextItem(type: it.type, leading: it.leading, content: it.content));
    });
  }

  Widget getRichLineWidget(RichTextItem item){
    Widget lineWidget;
    switch (item.type) {
      case RichLineType.Title :
        lineWidget = getRichTextTitleLine(item.content);
        break;
      case RichLineType.SubTitle :
        lineWidget = getRichTextSubTitleLine(item.content);
        break;
      case RichLineType.Text :
        lineWidget = getRichTextTextLine(item.content);
        break;
      case RichLineType.TextBold :
        lineWidget = getRichTextTextBoldLine(item.content);
        break;
      case RichLineType.Task :
        lineWidget = getRichTextTaskLine(item.content);
        break;
      case RichLineType.OrderedLists :
        lineWidget = getRichTextOrderedListsLine(item.leading, item.content);
        break;
      case RichLineType.UnorderedList :
        lineWidget = getRichTextUnorderedListLine(item.leading, item.content);
        break;
      case RichLineType.Reference :
        lineWidget = getRichTextReferenceLine(item.content);
        break;
      case RichLineType.Image :
        lineWidget = getRichTextImageLine(item.content);
        break;
    }
    return lineWidget;
  }

  Widget getRichItemWidget(RichTextItem item){
    Widget lineWidget;
    switch (item.type) {
      case RichLineType.Title :
        lineWidget = getRichTextTitleLine(item.content);
        break;
      case RichLineType.SubTitle :
        lineWidget = getRichTextSubTitleLine(item.content);
        break;
      case RichLineType.Text :
        lineWidget = getRichTextTextLine(item.content);
        break;
      case RichLineType.TextBold :
        lineWidget = getRichTextTextBoldLine(item.content);
        break;
      case RichLineType.Task :
        lineWidget = getRichTextTaskLine(item.content);
        break;
      case RichLineType.OrderedLists :
        lineWidget = getRichTextOrderedListsLine(item.leading, item.content);
        break;
      case RichLineType.UnorderedList :
        lineWidget = getRichTextUnorderedListLine(item.leading, item.content);
        break;
      case RichLineType.Reference :
        lineWidget = getRichTextReferenceLine(item.content);
        break;
      case RichLineType.Image :
        lineWidget = getRichTextImageLine(item.content);
        break;
    }
    return lineWidget;
  }

  void splitLine(int index, List<String> lines) {
    RichTextItem oldItem = contentList[index];
    RichTextItem newItem;
    if (lines.length > 1) {
      debugPrint('第二行字数：${lines[1].length}');
      oldItem.controller.text = lines[0];
      setState(() {
        newItem = RichTextItem(type: oldItem.type, leading: oldItem.leading, content: lines[1]);
        contentList.insert(index + 1, newItem);
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        var focusScopeNode = FocusScope.of(context);
        focusScopeNode.requestFocus(newItem?.node);
      });
    }
  }

  void gotoNextLine(int index) {
    if (index < contentList.length - 1) {
      var focusScopeNode = FocusScope.of(context);
      focusScopeNode.requestFocus(contentList[index+1].node);
    }
  }

  void gotoLine(int index) {
    var focusScopeNode = FocusScope.of(context);
    focusScopeNode.requestFocus(contentList[index].node);
  }

  Widget geTextField(BuildContext context, int index) {
    var item = contentList[index];
    assert(item.controller != null);
    assert(item.node != null);
    return RawKeyboardListener(
      focusNode: item.node,
      child: TextField(
        maxLines: null,
        //maxLength: 300,
        inputFormatters: [ LengthLimitingTextInputFormatter(300), ],
        autofocus: true,
        textAlign: TextAlign.justify,
        style: getDefaultTextStyle(item.type),
        textInputAction: TextInputAction.newline,
        focusNode: item.node,
        controller: item.controller,
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
            splitLine(index, line);
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
        return getRichItemWidget(contentList[index]);
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
  String leading = '•';

  /// line的数据内容，都以String的形式保存，图片也是。
  String content;
}

class RichTextItem {
  RichTextItem({
    this.type,
    this.leading,
    String content,
  }) {
    if (type != RichLineType.Image) {
      controller = TextEditingController();
      node = FocusNode();
      controller.text = content;
    } else {
      image = content;
    }
  }

  RichLineType type;
  String leading;
  String image;
  TextEditingController controller;
  FocusNode node;
  bool canChanged = true;

  String get content => type == RichLineType.Image ? image : controller.text;

  void dispose() {
    controller?.dispose();
    node?.dispose();
  }

}

///

Widget getRichLineWidget(RichTextLine item){
  Widget lineWidget;
  switch (item.type) {
    case RichLineType.Title :
      lineWidget = getRichTextTitleLine(item.content);
      break;
    case RichLineType.SubTitle :
      lineWidget = getRichTextSubTitleLine(item.content);
      break;
    case RichLineType.Text :
      lineWidget = getRichTextTextLine(item.content);
      break;
    case RichLineType.TextBold :
      lineWidget = getRichTextTextBoldLine(item.content);
      break;
    case RichLineType.Task :
      lineWidget = getRichTextTaskLine(item.content);
      break;
    case RichLineType.OrderedLists :
      lineWidget = getRichTextOrderedListsLine(item.leading, item.content);
      break;
    case RichLineType.UnorderedList :
      lineWidget = getRichTextUnorderedListLine(item.leading, item.content);
      break;
    case RichLineType.Reference :
      lineWidget = getRichTextReferenceLine(item.content);
      break;
    case RichLineType.Image :
      lineWidget = getRichTextImageLine(item.content);
      break;
  }
  return lineWidget;
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

///

Widget getRichTextTitleLine(String title) {
  return richLayoutText(
    Text(title,
      style: TextStyle(fontSize: 18),
    )
  );
}

Widget getRichTextSubTitleLine(String subtitle) {
  return richLayoutText(
      Text(subtitle,
        style: TextStyle(fontSize: 16),
      )
  );
}

Widget getRichTextTextLine(String text) {
  return richLayoutText(
      Text(text,
        style: TextStyle(fontSize: 14),
      )
  );
}

Widget getRichTextTextBoldLine(String text) {
  return richLayoutText(
      Text(text,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      )
  );
}

Widget getRichTextTaskLine(String text) {
  return richLayoutTask(
    Text(text, style: TextStyle(fontSize: 12))
  );
}

Widget getRichTextOrderedListsLine(String leading, String text) {
  return richLayoutList(
    Text('$leading.', style: TextStyle(fontSize: 12)),
    Text(text, style: TextStyle(fontSize: 12))
  );
}

Widget getRichTextUnorderedListLine(String leading, String text) {
  return richLayoutList(
      Text(leading, style: TextStyle(fontSize: 12)),
      Text(text, style: TextStyle(fontSize: 12))
  );
}

Widget getRichTextReferenceLine(String text) {
  return richLayoutReference(
    Text(text, style: TextStyle(fontSize: 12))
  );
}

Widget getRichTextImageLine(String image) {
  return richLayoutImage(
    Text('这里是图片', style: TextStyle(fontSize: 12), ),
  );
}


/// 下面是RichText的基本排版风格布局文件

Widget richLayoutText(Widget widget) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
    child: widget,
  );
}

Widget richLayoutTask(Widget widget) {
//  CheckboxListTile(
//
//  );
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
    child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 60,
            height: double.infinity,
            child: Checkbox(
              value: false,
              onChanged: (isSelected){

              },
            ),
          ),
          widget,
        ]
    ),
  );
}

Widget richLayoutList(Widget leading, Widget widget) {  // Reference
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
    child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(3, 3, 12, 0),
            child: leading,
          ),
          widget,
        ]
    ),
  );
}

Widget richLayoutReference(Widget widget) {
  return Container(
    child: widget,
    margin: EdgeInsets.fromLTRB(16, 0, 12, 0),
    padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
    decoration: BoxDecoration(
      color: Colors.black12,
      border: Border(
          left: BorderSide(color: Colors.black26, width: 3.0)
      ),
    ),
  );
}

Widget richLayoutImage(Widget widget) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
    child: widget,
  );
}

///
/// 风格设置
///
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/models/models.dart';

enum RichLineType {
  Task,             // 任务
  Text,             // 标准文本
  TextBold,         // 粗体文本
  Reference,        // 引用
  UnorderedList,    // 无序列表
  OrderedLists,     // 有序列表
  Image,            // 图片
}

class RichTextEditerRoute extends StatefulWidget {

  final String _focusEvent;

  RichTextEditerRoute(this._focusEvent);

  @override
  RichTextEditerRouteState createState() => RichTextEditerRouteState();
}

class RichTextEditerRouteState extends State<RichTextEditerRoute> {

  var richTextLine = List<RichTextLine>();

  @override
  void initState() {
    super.initState();
    richTextLine.add(RichTextLine('一二三四五'));
    richTextLine.add(RichTextLine('二二三四五'));
    richTextLine.add(RichTextLine('三二三四五'));
    richTextLine.add(RichTextLine('四二三四五'));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void dispose() {
    super.dispose();
    richTextLine.forEach((textLine) {
      textLine.dispose();
    });
  }

  void caiLine(int index, List<String> line) {
    RichTextLine newLine;
    if (line.length > 1) {
      debugPrint('第二行字数：${line[1].length}');
      richTextLine[index].editingController.content = line[0];
      setState(() {
        newLine = RichTextLine(line[1]);
        richTextLine.insert(index+1, newLine);
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        var focusScopeNode = FocusScope.of(context);
        focusScopeNode.requestFocus(newLine.focusNode);
      });
    }
  }

  void gotoNextLine(int index) {
    if (index < richTextLine.length - 1) {
      var focusScopeNode = FocusScope.of(context);
      focusScopeNode.requestFocus(richTextLine[index+1].focusNode);
    }
  }

  void gotoLine(int index) {
    var focusScopeNode = FocusScope.of(context);
    focusScopeNode.requestFocus(richTextLine[index].focusNode);
  }

  Widget getRichLineWidget(RichLineType type, String text){
    Widget lineWidget;
    switch (type) {
      case RichLineType.Text :
        lineWidget = getTextLine(text);
        break;
      case RichLineType.TextBold :
        lineWidget = getTextBoldLine(text);
        break;
      case RichLineType.Task :
        lineWidget = Text('');
        break;
      case RichLineType.OrderedLists :
        lineWidget = Text('');
        break;
      case RichLineType.UnorderedList :
        lineWidget = getUnorderedListLine(text);
        break;
      case RichLineType.Reference :
        lineWidget = Text('');
        break;
      case RichLineType.Image :
        lineWidget = Text('');
        break;
    }
    return lineWidget;
  }

  Widget getTextLine(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(text,
        style: TextStyle(fontSize: 14),
      ),
    );
  }

  Widget getTextBoldLine(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(text,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget getOrderedListsLine(String index, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 60,
            height: double.infinity,
            child: Text(index, style: TextStyle(fontSize: 12)),
          ),
          Text(text, style: TextStyle(fontSize: 12),
          ),
        ]
      ),
    );
  }

  Widget getUnorderedListLine(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(text,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RichTextEditer'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index){
          return RawKeyboardListener(
            focusNode: richTextLine[index].focusNode,
            child: TextField(
              maxLines: null,
              //maxLength: 300,
              inputFormatters: [ LengthLimitingTextInputFormatter(300), ],
              autofocus: true,
              textAlign: TextAlign.justify,
              style: getLineTextStyle(index),
              textInputAction: TextInputAction.newline,
              focusNode: richTextLine[index].focusNode,
              controller: richTextLine[index].editingController,
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
                if (richTextLine[index].canChanged) {
                  richTextLine[index].canChanged = false;
                  var line = text.split('\n');
                  caiLine(index, line);
                } else {
                  richTextLine[index].canChanged = true;
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
        },
        itemCount: richTextLine.length,
      ),
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
  TextStyle textStyle;

  String leading;

  /// line的数据内容，都以String的形式保存，图片也是
  String content;

  void buildStyle() {
    getDefaultTextStyle(type);
  }

}

TextStyle getDefaultTextStyle(RichLineType type) {
  TextStyle textStyle;
  switch (type) {
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

mixin RichLineMixin {
  final editingController = TextEditingController();
  final focusNode = FocusNode();
  bool canChanged = true;

  void initText(String text) {
    editingController.text = text;
  }

  void dispose() {
    editingController.dispose();
    focusNode.dispose();
  }
}

TextStyle getLineTextStyle(int index) {
  TextStyle style;
  switch (index) {
    case 0: {
      style = TextStyle(
        fontSize: 18,
        color: Colors.black87,
        textBaseline: TextBaseline.ideographic,
      );
      break;
    }
    case 1: {
      style = TextStyle(
        fontSize: 16,
        color: Colors.black87,
        textBaseline: TextBaseline.ideographic,
      );
      break;
    }
    case 2: {
      style = TextStyle(
        fontSize: 12,
        color: Colors.black87,
        textBaseline: TextBaseline.ideographic,
      );
      break;
    }
    default: {
      style = TextStyle(
        fontSize: 14,
        color: Colors.black87,
        textBaseline: TextBaseline.ideographic,
      );
    }
  }
  return style;
}
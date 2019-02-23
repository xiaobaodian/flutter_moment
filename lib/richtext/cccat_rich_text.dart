import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moment/richtext/cccat_rich_text_layout.dart';

class CCCatRichText extends StatefulWidget{
  CCCatRichText({
    this.content,
    this.richTextLayout,
  }): isEditable = false;

  CCCatRichText.editable({
    this.content,
    this.richTextLayout,
  }): isEditable = true;

  final RichTextLayout richTextLayout;
  final bool isEditable;
  final List<RichTextLine> content;

  @override
  CCCatRichTextState createState() {
    return new CCCatRichTextState();
  }
}

class CCCatRichTextState extends State<CCCatRichText> {
  RichTextLayout layout;
  List<RichTextLine> lineList;
  List<RichTextItem> itemList;

  @override
  void initState(){
    super.initState();
    layout = widget.richTextLayout;
    if (widget.isEditable) {
      lineList.forEach((it){
        itemList.add(
          RichTextItem(
            type: it.type,
            leading: it.leading,
            content: it.content,
          )
        );
      });
    } else {
      lineList = widget.content;
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.isEditable) {
      itemList.forEach((item) {
        item.dispose();
      });
    }
  }

  void richOrderedList() {
    int bh = 1;
    lineList.forEach((line){
      if (line.type == RichLineType.OrderedLists) {
        line.leading = bh.toString();
        bh++;
      } else if (bh > 1) {
        bh = 1;
      }
    });
  }

  void splitLine(int index, List<String> lines) {
    RichTextItem oldItem = itemList[index];
    RichTextItem newItem;
    if (lines.length > 1) {
      debugPrint('第二行字数：${lines[1].length}');
      oldItem.controller.text = lines[0];
      setState(() {
        newItem = RichTextItem(type: oldItem.type, leading: oldItem.leading, content: lines[1]);
        itemList.insert(index + 1, newItem);
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        var focusScopeNode = FocusScope.of(context);
        focusScopeNode.requestFocus(newItem?.node);
      });
    }
  }

  void gotoNextLine(int index) {
    if (index < itemList.length - 1) {
      var focusScopeNode = FocusScope.of(context);
      focusScopeNode.requestFocus(itemList[index+1].node);
    }
  }

  void gotoLine(int index) {
    var focusScopeNode = FocusScope.of(context);
    focusScopeNode.requestFocus(itemList[index].node);
  }

  Widget geTextField(BuildContext context, int index) {
    var item = itemList[index];
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
        //style: getDefaultTextStyle(item.type),
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
    if (layout == null) {
      layout = RichTextLayout(context,
        titleStyle: TextStyle(fontSize: 20, color: Colors.red),
      );
    }
    richOrderedList();
    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemBuilder: (context, index){
        return layout.getLayoutWidget(lineList[index]);//getRichItemWidget(contentList[index]);
      },
      separatorBuilder: (context, index){
        if (lineList[index].type == RichLineType.Task) {
          if (lineList[index+1].type == RichLineType.Task) {
            return SizedBox(height: 3.0);
          }
        } else if (lineList[index].type == RichLineType.OrderedLists || lineList[index].type == RichLineType.UnorderedList) {
          if (lineList[index+1].type == RichLineType.OrderedLists || lineList[index+1].type == RichLineType.UnorderedList) {
            return SizedBox(height: 3.0, width: double.infinity,);
          }
        }
        return SizedBox(height: 12.0);
      },
      itemCount: lineList.length,
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
  String leading = '';

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

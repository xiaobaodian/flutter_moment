import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moment/richtext/cccat_rich_text_layout.dart';

class CCCatRichText extends StatefulWidget {
  CCCatRichText({
    this.content,
    this.richTextLayout,
    this.onTapLineEvent,
  }) : isEditable = false;

  CCCatRichText.editable(
      {this.content, this.richTextLayout, this.onTapLineEvent})
      : isEditable = true;

  final ValueChanged<int> onTapLineEvent;
  final RichTextLayout richTextLayout;
  final bool isEditable;
  final List<RichTextLine> content;

  @override
  CCCatRichTextState createState() {
    return new CCCatRichTextState();
  }
}

class CCCatRichTextState extends State<CCCatRichText> {
  TextTheme textTheme;
  RichTextLayout layout;
  List<RichTextLine> lineList = [];
  //List<RichTextItem> itemList;

  @override
  void initState() {
    super.initState();
    layout = widget.richTextLayout;
    if (widget.isEditable) {
      widget.content.forEach((it) {
        lineList.add(RichTextItem(
          type: it.type,
          content: '\u0000' + it.content,
        ));
      });
    } else {
      lineList = widget.content;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (layout == null) {
      layout = RichTextLayout(
        context,
        titleStyle: TextStyle(fontSize: 20, color: Colors.red),
      );
    }
    textTheme = Theme.of(context).textTheme;
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.isEditable) {
      lineList.forEach((item) {
        if (item is RichTextItem) {
          item.dispose();
        }
      });
    }
  }

  Widget getRichLineLayoutWidget(int index) {
    var item = lineList[index];
    Widget lineWidget;
    switch (item.type) {
      case RichLineType.Title:
        var effectiveSytle =
            layout.titleStyle == null ? textTheme.title : layout.titleStyle;
        if (widget.isEditable) {
          lineWidget = geTextField(index, effectiveSytle);
        } else {
          lineWidget = Text(
            item.content,
            style: effectiveSytle,
          );
        }
        break;
      case RichLineType.SubTitle:
        var effectiveSytle = layout.subTitleStyle == null
            ? textTheme.subhead
            : layout.subTitleStyle;
        if (widget.isEditable) {
          lineWidget = geTextField(index, effectiveSytle);
        } else {
          lineWidget = Text(
            item.content,
            style: effectiveSytle,
          );
        }
        break;
      case RichLineType.Text:
        var effectiveSytle =
            layout.contentStyle == null ? textTheme.body1 : layout.contentStyle;
        if (widget.isEditable) {
          lineWidget = geTextField(index, effectiveSytle);
        } else {
          lineWidget = Text(
            item.content,
            style: effectiveSytle,
          );
        }
        break;
      case RichLineType.TextBold:
        var effectiveSytle = layout.contentBoldStyle == null
            ? textTheme.body1.merge(TextStyle(fontWeight: FontWeight.bold))
            : layout.contentBoldStyle;
        if (widget.isEditable) {
          lineWidget = geTextField(index, effectiveSytle);
        } else {
          lineWidget = Text(
            item.content,
            style: effectiveSytle,
          );
        }
        break;
      case RichLineType.Task:
        var effectiveSytle =
            layout.taskStyle == null ? textTheme.body1 : layout.taskStyle;
        if (widget.isEditable) {
          lineWidget = layout.richLayoutTask(
              geTextField(index, effectiveSytle),
              Text(
                '9:20 - 10:00',
                style: textTheme.caption,
              ));
        } else {
          lineWidget = layout.richLayoutTask(
              Text(item.content, style: effectiveSytle),
              Text(
                '9:20 - 10:00',
                style: textTheme.caption,
              ));
        }
        break;
      case RichLineType.OrderedLists:
        var effectiveSytle = layout.orderedListsStyle == null
            ? textTheme.body1
            : layout.orderedListsStyle;
        if (widget.isEditable) {
          lineWidget = layout.richLayoutList(
              Text('${item.leading}.', style: effectiveSytle),
              geTextField(index, effectiveSytle));
        } else {
          lineWidget = layout.richLayoutList(
              Text('${item.leading}.', style: effectiveSytle),
              Text(item.content, style: effectiveSytle));
        }
        break;
      case RichLineType.UnorderedList:
        var effectiveSytle = layout.unorderedListStyle == null
            ? textTheme.body1
            : layout.unorderedListStyle;
        if (widget.isEditable) {
          lineWidget = layout.richLayoutList(
            Text(layout.leadingSymbols, style: effectiveSytle),
            geTextField(index, effectiveSytle),
          );
        } else {
          lineWidget = layout.richLayoutList(
              Text(layout.leadingSymbols, style: effectiveSytle),
              Text(item.content, style: effectiveSytle));
        }
        break;
      case RichLineType.Reference:
        var effectiveSytle = layout.referenceStyle == null
            ? textTheme.caption
            : layout.referenceStyle;
        if (widget.isEditable) {
          lineWidget =
              layout.richLayoutReference(geTextField(index, effectiveSytle));
        } else {
          lineWidget = layout
              .richLayoutReference(Text(item.content, style: effectiveSytle));
        }
        break;
      case RichLineType.Image:
        if (widget.isEditable) {
        } else {
          lineWidget = layout.richLayoutImage(
            Text(
              '这里是图片',
              style: TextStyle(fontSize: 12),
            ),
          );
        }
        break;
    }
    return lineWidget;
  }

  int getCurrentLineIndex() {
    int index = -1;
    for (int i = 0; i < lineList.length; i++) {
      RichTextItem item = (lineList[i]);
      if (item.node.hasFocus) {
        index = i;
        break;
      }
    }
    return index;
  }

  void gotoNextLine(int index) {
    if (index < lineList.length - 1) {
      var focusScopeNode = FocusScope.of(context);
      focusScopeNode.requestFocus((lineList[index + 1] as RichTextItem).node);
    }
  }

  void gotoLine(int index) {
    var focusScopeNode = FocusScope.of(context);
    focusScopeNode.requestFocus((lineList[index] as RichTextItem).node);
  }

  void requestFocus(FocusNode node) {
    var focusScopeNode = FocusScope.of(context);
    focusScopeNode.requestFocus(node);
  }

  void changeCurrentLineTypeTo(RichLineType type) {
    int index = getCurrentLineIndex();
    //int index = 1;
    if (index > -1) {
      RichTextItem item = lineList[index];
      /// 这个调用很重要，不然会出现断言错误。
      //item.node.unfocus();
      setState(() {
        String str = item.controller.text;
        RichTextItem newItem = RichTextItem(type: type, content: str);
        lineList.removeAt(index);
        lineList.insert(index, newItem);
        //item.type = type;
        //item.changeTypeTo(type);
        //requestFocus(newItem.node);
        Future.delayed(const Duration(milliseconds: 200), () {
          requestFocus(newItem?.node);
        });
      });
    }
  }

  void calculationOrderedList() {
    int bh = 1;
    lineList.forEach((line) {
      if (line.type == RichLineType.OrderedLists) {
        line.leading = bh.toString();
        bh++;
      } else if (bh > 1) {
        bh = 1;
      }
    });
  }

  void splitLine(int index, List<String> lines) {
    RichTextItem oldItem = lineList[index];
    RichTextItem newItem;
    RichLineType newType;
    if (lines.length > 1) {
      debugPrint('第二行字数：${lines[1].length}');
      oldItem.controller.text = lines[0];
      if (oldItem.type == RichLineType.Title ||
          oldItem.type == RichLineType.SubTitle ||
          oldItem.type == RichLineType.Reference) {
        newType = RichLineType.Text;
      } else {
        newType = oldItem.type;
      }
      setState(() {
        newItem = RichTextItem(type: newType, content: '\u0000' + lines[1]);
        newItem.controller.selection = TextSelection.fromPosition(
          TextPosition(
            offset: 1,
          )
        );
        lineList.insert(index + 1, newItem);
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        //var focusScopeNode = FocusScope.of(context);
        //focusScopeNode.requestFocus(newItem?.node);
        requestFocus(newItem?.node);
        oldItem.canChanged = true;
      });
    }
  }

  Widget geTextField(int index, TextStyle effectiveSytle) {
    var item = lineList[index] as RichTextItem;
    assert(item.controller != null);
    assert(item.node != null);
    return RawKeyboardListener(
      focusNode: item.node,
      child: TextField(
        focusNode: item.node,
        controller: item.controller,
        maxLines: null,
        //maxLength: 300,
        inputFormatters: [
          LengthLimitingTextInputFormatter(300),
        ],
        style: effectiveSytle,
        //autofocus: true,
        textAlign: TextAlign.justify,
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(
            border: InputBorder.none, contentPadding: EdgeInsets.all(0)),
        onEditingComplete: () {
          //gotoNextLine(index);
          debugPrint('onEditingComplete/是不是按了回车键');
        },
        onSubmitted: (text) {
          debugPrint('onSubmitted/是不是按了回车键');
        },
        onChanged: (text) {
          debugPrint('内容修改了：$text');
          var t = text.substring(0, 1);
          if (t == '\u0000') {
            debugPrint('神奇字符');
          } else {
            debugPrint('找到解决方法了');
            if (index > 0) {
              setState(() {
                var line = lineList[index - 1] as RichTextItem;
                var posi = line.controller.text.length;
                var newText = line.controller.text + text;
                line.controller.text = newText;
                line.controller.selection = TextSelection.fromPosition(
                  TextPosition(
                    affinity: TextAffinity.downstream,
                    offset: posi,
                  ),
                );
                lineList.removeAt(index);
                requestFocus(line.node);
              });
            }
          }
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
        RawKeyEventDataAndroid key = event.data;
        print('KeyCode: ${key.keyCode}, CodePoint: ${key.codePoint}, '
            'Flags: ${key.flags}, MetaState: ${key.metaState}, '
            'ScanCode: ${key.scanCode}');
        if (key.keyCode == 66) {
          var line = item.controller.text.split('\n');
          splitLine(index, line);
        }

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
    calculationOrderedList();
    return Column(
      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.all(16),
            itemBuilder: (context, index) {
              return InkWell(
                child: getRichLineLayoutWidget(index),
                onTap: () {
                  if (widget.onTapLineEvent != null) {
                    widget.onTapLineEvent(index);
                  }
                },
              );
            },
            separatorBuilder: (context, index) {
              if (lineList[index].type == RichLineType.Task) {
                if (lineList[index + 1].type == RichLineType.Task) {
                  return SizedBox(height: layout.listLineSpacing);
                }
              } else if (lineList[index].type == RichLineType.OrderedLists ||
                  lineList[index].type == RichLineType.UnorderedList) {
                if (lineList[index + 1].type == RichLineType.OrderedLists ||
                    lineList[index + 1].type == RichLineType.UnorderedList) {
                  return SizedBox(
                    height: layout.listLineSpacing,
                    width: double.infinity,
                  );
                }
              }
              return SizedBox(height: layout.segmentSpacing);
            },
            itemCount: lineList.length,
          ),
        ),
        Divider(
          height: 1.0,
        ),
        Container(
          //color: Colors.amber,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.format_align_justify),
                onPressed: (){
                  changeCurrentLineTypeTo(RichLineType.Text);
                },
              ),
              IconButton(
                icon: Icon(Icons.format_bold),
                onPressed: (){
                  changeCurrentLineTypeTo(RichLineType.TextBold);
                },
              ),
              IconButton(
                icon: Icon(Icons.format_list_numbered),
                onPressed: (){
                  changeCurrentLineTypeTo(RichLineType.OrderedLists);
                },
              ),
              IconButton(
                icon: Icon(Icons.format_list_bulleted),
                onPressed: (){
                  changeCurrentLineTypeTo(RichLineType.UnorderedList);
                },
              ),
              IconButton(
                icon: Icon(Icons.aspect_ratio),
                onPressed: (){
                  changeCurrentLineTypeTo(RichLineType.Reference);
                },
              ),
              IconButton(
                icon: Icon(Icons.check_box),
                onPressed: (){},
              ),
              IconButton(
                icon: Icon(Icons.photo),
                onPressed: (){},
              ),
            ],
          ),
        ),
      ],
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
    this.time,
    this.checkState,
  });

  RichLineType type;
  String leading = '';

  /// line的数据内容，都以String的形式保存，图片也是。
  String content;

  String time;
  bool checkState;
}

class RichTextItem extends RichTextLine {
  RichTextItem({
    RichLineType type,
    String content,
    String time,
    bool checkState,
  }) : super(type: type, content: content, time: time, checkState: checkState) {
    if (type != RichLineType.Image) {
      controller = TextEditingController();
      node = FocusNode();
      controller.text = content;
    } else {
      image = content;
    }
  }

  String image;
  bool canChanged = true;

  TextEditingController controller;
  FocusNode node;
  Widget field;

  String get editContent =>
      type == RichLineType.Image ? image : controller.text;

  void dispose() {
    controller?.dispose();
    node?.dispose();
  }

  void changeTypeTo(RichLineType type) {
    node = FocusNode();
    this.type = type;
  }
}

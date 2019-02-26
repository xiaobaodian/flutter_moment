import 'dart:convert';

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
    initEditable(widget.content);
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
    lineList = null;
  }

  void initEditable(List<RichTextLine> source) {
    if (widget.isEditable) {
      if (source.length == 0) {
        lineList.add(RichTextItem(
          type: RichLineType.Text,
          content: '\u0000' + '',
        ));
      } else {
        source.forEach((it) {
          lineList.add(RichTextItem(
            type: it.type,
            content: '\u0000' + it.content,
          ));
        });
      }
    } else {
      lineList = source;
    }
  }

  List<RichTextLine> getContentList() {
    List<RichTextLine> list = [];
    if (!widget.isEditable) return list;
    lineList.forEach((line) {
      RichTextItem item = line;
      list.add(RichTextLine(
        type: item.type,
        content: item.controller.text.replaceFirst('\u0000', ''),
        beginTime: item.beginTime,
        endTime: item.endTime,
        //checkState: item.checkState,
      ));
    });
//    debugPrint('list length: ${list.length}');
//    debugPrint('list[0]: ${list[0].content.length}');
//    debugPrint('RichTextLine: ${list[0].toString()}');
//    RichTextLine line = list[0];
//    String d = json.encode(list);
//    //var d = list[0].toJson();
//    debugPrint('json: $d');
    return list;
  }

  void testthis(){
    String data = getContentJsonString();
    setState(() {
      lineList.clear();
    });
    Future.delayed(const Duration(milliseconds: 3000), () {
      loadContentListFromJson(data);
      setState(() {

      });
    });
  }

  String getContentJsonString(){
    return json.encode(getContentList());
  }

  void loadContentListFromJson(String jsonString) {
    List<dynamic> resultJson = json.decode(jsonString) as List;
    List<RichTextLine> source = resultJson.map((item) => RichTextLine.fromJson(item)).toList();
    initEditable(source);
  }

  Widget getRichLineLayoutWidget(int index) {
    var item = lineList[index];
    Widget lineWidget;
    switch (item.type) {
      case RichLineType.Title:
        var effectiveSytle =
            layout.titleStyle == null ? textTheme.title : layout.titleStyle;
        if (widget.isEditable) {
          //lineWidget = geTextField(index, effectiveSytle);
          lineWidget =
              layout.richLayoutText(geTextField(index, effectiveSytle));
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
          //lineWidget = geTextField(index, effectiveSytle);
          lineWidget =
              layout.richLayoutText(geTextField(index, effectiveSytle));
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
          //lineWidget = geTextField(index, effectiveSytle);
          lineWidget =
              layout.richLayoutText(geTextField(index, effectiveSytle));
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
          //lineWidget = geTextField(index, effectiveSytle);
          lineWidget =
              layout.richLayoutText(geTextField(index, effectiveSytle));
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
            ? textTheme.body1
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

  int _getCurrentLineIndex() {
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

  void _gotoNextLine(int index) {
    if (index < lineList.length - 1) {
      var focusScopeNode = FocusScope.of(context);
      focusScopeNode.requestFocus((lineList[index + 1] as RichTextItem).node);
    }
  }

  void _gotoLine(int index) {
    var focusScopeNode = FocusScope.of(context);
    focusScopeNode.requestFocus((lineList[index] as RichTextItem).node);
  }

  void _requestFocus(FocusNode node) {
    var focusScopeNode = FocusScope.of(context);
    focusScopeNode.requestFocus(node);
  }

  void removeCurrentLine() {
    int index = _getCurrentLineIndex();
    if (index > -1) {
      setState(() {
        //requestFocus(item.node);
        //item.node.unfocus();
        lineList.removeAt(index);
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        RichTextItem item = lineList[index];
        item.controller.selection = TextSelection.fromPosition(TextPosition(
          affinity: TextAffinity.downstream,
          offset: 1,
        ));
        _requestFocus(item?.node);
      });
    }
  }

  void changeCurrentLineTypeTo(RichLineType type) {
    int index = _getCurrentLineIndex();
    if (index > -1) {
      RichTextItem item = lineList[index];
      setState(() {
        //item.node.unfocus();
        item.type = type;
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        //item.controller.selection;
        _requestFocus(item?.node);
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

  void mergeUPLine(int index, String text) {
    debugPrint('向上行合并');
    RichTextItem tempLine = lineList[index];
    if (index > 0) {
      setState(() {
        RichTextItem upLine = lineList[index - 1];
        _requestFocus(upLine.node);
        var p = upLine.controller.text.length;
        var newText = upLine.controller.text + text;
        //tempLine.controller.clear();
        upLine.controller.text = newText;
        upLine.controller.selection = TextSelection.fromPosition(
          TextPosition(affinity: TextAffinity.downstream, offset: p),
        );
        lineList.removeAt(index);
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        tempLine.dispose();
      });
    }
  }

  void splitLine(int index, List<String> lines) {
    RichTextItem oldItem = lineList[index];
    RichTextItem newItem;
    RichLineType newType;
    if (lines.length < 2) return;
    debugPrint('第一行字数：${lines[0].length}');
    debugPrint('第二行字数：${lines[1].length}');

    if (lines[0].length == 1 && lines[1].length == 0) {
      if (index == 0) return;
      setState(() {
        RichTextItem item = lineList[index];
        item.type = RichLineType.Text;
        item.controller.text = '\u0000' + '';
        item.controller.selection = TextSelection.fromPosition(
            TextPosition(affinity: TextAffinity.downstream, offset: 1));
        item.canChanged = true;
      });
    } else {
      oldItem.controller.text = lines[0];
      if (oldItem.type == RichLineType.Title ||
          oldItem.type == RichLineType.SubTitle ||
          oldItem.type == RichLineType.Reference) {
        newType = RichLineType.Text;
      } else {
        newType = oldItem.type;
      }
      debugPrint('插入新行，类型是：${newType.toString()}');
      setState(() {
        newItem = RichTextItem(type: newType, content: '\u0000' + lines[1]);
        newItem.controller.selection = TextSelection.fromPosition(TextPosition(
          affinity: TextAffinity.downstream,
          offset: 1,
        ));
        lineList.insert(index + 1, newItem);
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        //var focusScopeNode = FocusScope.of(context);
        //focusScopeNode.requestFocus(newItem?.node);
        _requestFocus(newItem?.node);
        oldItem.canChanged = true;
      });
    }
  }

  Widget geTextField(int index, TextStyle effectiveSytle) {
    var item = lineList[index] as RichTextItem;
    assert(item.controller != null);
    assert(item.node != null);
    return TextField(
      focusNode: item.node,
      controller: item.controller,
      maxLines: null,
      //maxLength: 300,
      inputFormatters: [
        LengthLimitingTextInputFormatter(300),
      ],
      style: effectiveSytle,
      autofocus: true,
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
        debugPrint('触发内容修改事件：$text, 内容长度: ${text.length}');
        debugPrint('内容长度: ${text.length}');

        if (text.length == 0) {
          mergeUPLine(index, '');
        } else {
          //var t = text.substring(0, 1);
          if (text.substring(0, 1) == '\u0000') {
            debugPrint('包含神奇字符');
            if (item.canChanged) {
              item.canChanged = false;
              var line = text.split('\n');
              if (line.length > 1) {
                splitLine(index, line);
                debugPrint('处理拆分行');
              }
            } else {
              item.canChanged = true;
            }
          } else {
            mergeUPLine(index, text);
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
                icon: Icon(Icons.clear_all),
                onPressed: () {
                  removeCurrentLine();
                },
              ),
              IconButton(
                icon: Icon(Icons.reorder),
                onPressed: () {
                  changeCurrentLineTypeTo(RichLineType.Text);
                },
              ),
              IconButton(
                icon: Icon(Icons.format_bold),
                onPressed: () {
                  changeCurrentLineTypeTo(RichLineType.TextBold);
                },
              ),
              IconButton(
                icon: Icon(Icons.format_list_numbered),
                onPressed: () {
                  changeCurrentLineTypeTo(RichLineType.OrderedLists);
                },
              ),
              IconButton(
                icon: Icon(Icons.format_list_bulleted),
                onPressed: () {
                  changeCurrentLineTypeTo(RichLineType.UnorderedList);
                },
              ),
              IconButton(
                icon: Icon(Icons.aspect_ratio),
                onPressed: () {
                  changeCurrentLineTypeTo(RichLineType.Reference);
                },
              ),
              IconButton(
                icon: Icon(Icons.check_box),
                onPressed: () {
                  changeCurrentLineTypeTo(RichLineType.Task);
                },
              ),
              IconButton(
                icon: Icon(Icons.photo),
                onPressed: () {
                  //getContentList();
                  testthis();
                },
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
    this.focusEventId = 0,
    this.content = '',
    this.beginTime,
    this.endTime,
    this.checkState = 0,
  });

  int focusEventId;
  RichLineType type;
  String leading = '';

  /// line的数据内容，都以String的形式保存，图片也是。
  String content;

  String beginTime, endTime;
  int checkState;

  factory RichTextLine.fromJson(Map<String, dynamic> json) {
    return RichTextLine(
      type: RichLineType.values[json['type']],
      focusEventId: json['focusEventId'],
      content: json['content'],
      beginTime: json['beginTime'],
      endTime: json['endTime'],
      checkState: json['checkState'],
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.index,
    'focusEventId': focusEventId,
    'content': content,
    'beginTime': '9:00',
    'endTime': '11:00',
    'checkState': checkState,
  };
}

class RichTextItem extends RichTextLine {
  RichTextItem({
    RichLineType type,
    int focusEventId,
    String content,
    beginTime,
    endTime,
    int checkState,
  }) : super(
            type: type,
            focusEventId: focusEventId,
            content: content,
            beginTime: beginTime,
            endTime: endTime,
            checkState: checkState) {
    if (type != RichLineType.Image) {
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

  TextEditingController controller;
  FocusNode node;

  String get editContent =>
      type == RichLineType.Image ? image : controller.text;

  void dispose() {
    controller?.dispose();
    node?.dispose();
  }
}

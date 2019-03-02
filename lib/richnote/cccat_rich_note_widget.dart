import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_data.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_layout.dart';

class RichNote extends StatefulWidget {
  RichNote({
    this.richSource,
    this.richNoteLayout,
    this.onTapLine,
  }): isEditable = false, isFixed = false,
  assert(richSource.paragraphList != null) {
    richSource.richNote = this;
  }

  RichNote.editable({
    this.richSource,
    this.richNoteLayout,
    this.onTapLine
  }): isEditable = true, isFixed = false {
    richSource.richNote = this;
    debugPrint('RichNote.editable 模式初始化');
    richSource.markToEditer();
  }

  RichNote.fixed({
    this.richSource,
    this.richNoteLayout,
    this.onTapLine
  }): isFixed = true, isEditable = false;

  final bool isEditable;
  final bool isFixed;
  final ValueChanged<int> onTapLine;
  final RichNoteLayout richNoteLayout;
  final RichSource richSource;

  @override
  RichNoteState createState() {
    return new RichNoteState();
  }
}

class RichNoteState extends State<RichNote> {
  TextTheme textTheme;
  RichNoteLayout layout;
  RichSource source;
  //List<RichLine> paragraphList;
  //List<RichTextItem> itemList;

  @override
  void initState() {
    super.initState();
    layout = widget.richNoteLayout;
    source = widget.richSource;
    //paragraphList = widget.richSource.paragraphList;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    textTheme = Theme.of(context).textTheme;
    if (layout == null) {
      layout = RichNoteLayout(
        context,
        titleStyle: textTheme.title.merge(TextStyle(color: Theme.of(context).primaryColor)),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.isEditable) {
      source.paragraphList.forEach((item) {
        if (item is RichItem) {
          item.dispose();
        }
      });
      source.paragraphList = null;
    }
  }

  Widget buildParagraphLayoutWidget(int index) {
    var item = source.paragraphList[index];
    Widget paragraphWidget;
    switch (item.type) {
      case RichType.FocusTitle:
        var effectiveSytle =
        layout.titleStyle == null ? textTheme.title : layout.titleStyle;
        if (widget.isEditable) {
          paragraphWidget =
              layout.richLayoutText(buildTextField(index, effectiveSytle));
        } else {
          paragraphWidget = Text(
            item.content,
            style: effectiveSytle,
          );
        }
        break;
      case RichType.Title:
        var effectiveSytle =
            layout.titleStyle == null ? textTheme.title : layout.titleStyle;
        if (widget.isEditable) {
          paragraphWidget =
              layout.richLayoutText(buildTextField(index, effectiveSytle));
        } else {
          paragraphWidget = Text(
            item.content,
            style: effectiveSytle,
          );
        }
        break;
      case RichType.SubTitle:
        var effectiveSytle = layout.subTitleStyle == null
            ? textTheme.subhead
            : layout.subTitleStyle;
        if (widget.isEditable) {
          //lineWidget = geTextField(index, effectiveSytle);
          paragraphWidget =
              layout.richLayoutText(buildTextField(index, effectiveSytle));
        } else {
          paragraphWidget = Text(
            item.content,
            style: effectiveSytle,
          );
        }
        break;
      case RichType.Text:
        var effectiveSytle =
            layout.contentStyle == null ? textTheme.body1 : layout.contentStyle;
        if (widget.isEditable) {
          //lineWidget = geTextField(index, effectiveSytle);
          paragraphWidget =
              layout.richLayoutText(buildTextField(index, effectiveSytle));
        } else {
          paragraphWidget = Text(
            item.content,
            style: effectiveSytle,
          );
        }
        break;
      case RichType.TextBold:
        var effectiveSytle = layout.contentBoldStyle == null
            ? textTheme.body1.merge(TextStyle(fontWeight: FontWeight.bold))
            : layout.contentBoldStyle;
        if (widget.isEditable) {
          //lineWidget = geTextField(index, effectiveSytle);
          paragraphWidget =
              layout.richLayoutText(buildTextField(index, effectiveSytle));
        } else {
          paragraphWidget = Text(
            item.content,
            style: effectiveSytle,
          );
        }
        break;
      case RichType.Task:
        var effectiveSytle =
            layout.taskStyle == null ? textTheme.body1 : layout.taskStyle;
        if (widget.isEditable) {
          paragraphWidget = layout.richLayoutTask(
              buildTextField(index, effectiveSytle),
              Text(
                '9:20 - 10:00',
                style: textTheme.caption,
              ));
        } else {
          paragraphWidget = layout.richLayoutTask(
              Text(item.content, style: effectiveSytle),
              Text(
                '9:20 - 10:00',
                style: textTheme.caption,
              ));
        }
        break;
      case RichType.SubOrderedLists:
      case RichType.OrderedLists:
        var effectiveSytle = layout.orderedListsStyle == null
            ? textTheme.body1
            : layout.orderedListsStyle;
        if (widget.isEditable) {
          paragraphWidget = layout.richLayoutList(
              Text('${item.leading}.', style: effectiveSytle),
              buildTextField(index, effectiveSytle));
        } else {
          paragraphWidget = layout.richLayoutList(
              Text('${item.leading}.', style: effectiveSytle),
              Text(item.content, style: effectiveSytle));
        }
        break;
      case RichType.SubUnorderedList:
      case RichType.UnorderedList:
        var effectiveSytle = layout.unorderedListStyle == null
            ? textTheme.body1
            : layout.unorderedListStyle;
        if (widget.isEditable) {
          paragraphWidget = layout.richLayoutList(
            Text(layout.leadingSymbols, style: effectiveSytle),
            buildTextField(index, effectiveSytle),
          );
        } else {
          paragraphWidget = layout.richLayoutList(
              Text(layout.leadingSymbols, style: effectiveSytle),
              Text(item.content, style: effectiveSytle));
        }
        break;
      case RichType.Reference:
        var effectiveSytle = layout.referenceStyle == null
            ? textTheme.body1
            : layout.referenceStyle;
        if (widget.isEditable) {
          paragraphWidget =
              layout.richLayoutReference(buildTextField(index, effectiveSytle));  //richLayoutReference
        } else {
          paragraphWidget = layout
              .richLayoutReference(Text(item.content, style: effectiveSytle));
        }
        break;
      case RichType.Image:
        if (widget.isEditable) {
        } else {
          paragraphWidget = layout.richLayoutImage(
            Text(
              '这里是图片',
              style: TextStyle(fontSize: 12),
            ),
          );
        }
        break;
    }
    return paragraphWidget;
  }

  Widget buildSeparatorWidget(int index) {
    if (source.paragraphList[index].type == RichType.Task) {
      if (source.paragraphList[index + 1].type == RichType.Task) {
        return SizedBox(height: layout.listLineSpacing);
      }
    } else if (source.paragraphList[index].type == RichType.OrderedLists ||
        source.paragraphList[index].type == RichType.UnorderedList) {
      if (source.paragraphList[index + 1].type == RichType.OrderedLists ||
          source.paragraphList[index + 1].type == RichType.UnorderedList) {
        return SizedBox(
          height: layout.listLineSpacing,
          width: double.infinity,
        );
      }
    } else if (source.paragraphList[index].type == RichType.Title ||
        source.paragraphList[index + 1].type == RichType.Title) {
      return SizedBox(height: 12);
    }
    return SizedBox(height: layout.segmentSpacing);
  }

  int _getCurrentLineIndex() {
    int index = -1;
    for (int i = 0; i < source.paragraphList.length; i++) {
      RichItem item = (source.paragraphList[i]);
      if (item.node.hasFocus) {
        index = i;
        break;
      }
    }
    return index;
  }

  void _requestFocus(FocusNode node) {
    var focusScopeNode = FocusScope.of(context);
    focusScopeNode.requestFocus(node);
  }

  void removeCurrentLine() {
    if (source.paragraphList.length == 1) return;
    int index = _getCurrentLineIndex();
    if (index > -1) {
      RichItem tempItem = source.paragraphList[index];
      setState(() {
        //requestFocus(item.node);
        //item.node.unfocus();
        source.paragraphList.removeAt(index);
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        tempItem.dispose();
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        RichItem item = source.paragraphList[index];
        item.controller.selection = TextSelection.fromPosition(TextPosition(
          affinity: TextAffinity.downstream,
          offset: 1,
        ));
        _requestFocus(item?.node);
      });
    }
  }

  void changeCurrentLineTypeTo(RichType type) {
    int index = _getCurrentLineIndex();
    if (index > -1) {
      RichItem item = source.paragraphList[index];
      setState(() {
        item.type = type;
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        _requestFocus(item?.node);
      });
    }
  }

  void calculationOrderedList() {
    int bh = 1;
    source.paragraphList?.forEach((line) {
      if (line.type == RichType.OrderedLists) {
        line.leading = bh.toString();
        bh++;
      } else if (bh > 1) {
        bh = 1;
      }
    });
  }

  void mergeUPLine(int index, String text) {
    debugPrint('向上行合并');
    RichItem tempLine = source.paragraphList[index];
    if (index > 0) {
      setState(() {
        RichItem upLine = source.paragraphList[index - 1];
        _requestFocus(upLine.node);
        var p = upLine.controller.text.length;
        var newText = upLine.controller.text + text;
        upLine.canChanged = false;
        upLine.controller.text = newText;
        upLine.controller.selection = TextSelection.fromPosition(
          TextPosition(affinity: TextAffinity.downstream, offset: p),
        );
        source.paragraphList.removeAt(index);
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        tempLine.dispose();
      });
    }
  }

  void splitLine(int index, List<String> lines) {
    if (lines.length < 2) return;

    RichItem oldItem = source.paragraphList[index];
    RichItem newItem;
    RichType newType;
    debugPrint('第一行字数：${lines[0].length}');
    debugPrint('第二行字数：${lines[1].length}');

    var upTxt = lines[0].replaceAll('\u0000', '');

    if (upTxt.length == 0 && lines[1].length == 0) {
      if (index == 0) return;
      setState(() {
        RichItem item = source.paragraphList[index];
        item.canChanged = false;
        item.type = RichType.Text;
        item.controller.text = '\u0000' + '';
        item.controller.selection = TextSelection.fromPosition(
            TextPosition(affinity: TextAffinity.downstream, offset: 1));
        //item.canChanged = true;
      });
    } else {
      oldItem.canChanged = false;
      oldItem.controller.text = lines[0];
      oldItem.controller.selection = TextSelection.fromPosition(TextPosition(
        affinity: TextAffinity.downstream,
        offset: lines[0].length,
      ));
      if (oldItem.type == RichType.Title ||
          oldItem.type == RichType.SubTitle ||
          oldItem.type == RichType.Reference) {
        newType = RichType.Text;
      } else {
        newType = oldItem.type;
      }
      debugPrint('插入新行，类型是：${newType.toString()}');
      setState(() {
        newItem = RichItem(type: newType, content: '\u0000' + lines[1]);
        newItem.canChanged = false;
        newItem.controller.selection = TextSelection.fromPosition(TextPosition(
          affinity: TextAffinity.downstream,
          offset: 1,
        ));
        source.paragraphList.insert(index + 1, newItem);
        Future.delayed(const Duration(milliseconds: 50), () {
          _requestFocus(newItem?.node);
        });
      });

    }
  }

  Widget buildTextField(int index, TextStyle effectiveSytle) {
    var item = source.paragraphList[index] as RichItem;
    assert(item.controller != null);
    assert(item.node != null);
    return TextField(
      key: item.key,
      focusNode: item.node,
      controller: item.controller,
      maxLines: null,
      inputFormatters: [
        LengthLimitingTextInputFormatter(300),
      ],
      style: effectiveSytle,
      autofocus: true,
      textAlign: TextAlign.justify,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
          border: InputBorder.none, contentPadding: EdgeInsets.all(0)),
      onChanged: (text) {
        debugPrint('触发内容修改事件：$text, 内容长度: ${text.length}');
        debugPrint('内容长度: ${text.length}');
        if (text.length == 0 || (text.substring(0, 1) != '\u0000')) {
          mergeUPLine(index, text ?? '');
        } else if (item.canChanged) {
          debugPrint('回车位置: ${text.indexOf('\n')}');
          if (text.indexOf('\n') > 0) splitLine(index, text.split('\n'));
        } else {
          item.canChanged = true;
        }
      },
    );
  }

  List<Widget> buildFixedBody(){
    List<Widget> bodyItems = [];
    int listLength = source.paragraphList.length;
    for (int index = 0; index < listLength; index++) {
      bodyItems.add(buildParagraphLayoutWidget(index));
      if (index < listLength -1)
        bodyItems.add(buildSeparatorWidget(index));
    }
    return bodyItems;
  }

  List<Widget> buildBody(){
    List<Widget> bodyItems = [];
    bodyItems.add(
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.all(16),
            itemBuilder: (context, index) {
              return InkWell(
                child: buildParagraphLayoutWidget(index),
                onTap: () {
                  if (widget.onTapLine != null) {
                    widget.onTapLine(index);
                  }
                },
              );
            },
            separatorBuilder: (context, index) {
              return buildSeparatorWidget(index);
            },
            itemCount: source.paragraphList.length,
          ),
        )
    );
    if (widget.isEditable) {
      bodyItems.add(
        Divider(
          height: 1.0,
        )
      );
      bodyItems.add(
        SizedBox(
          height: 48,
          width: double.infinity,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.clear_all),
                tooltip: '删除当前段落文本',
                onPressed: () {
                  removeCurrentLine();
                },
              ),
              IconButton(
                icon: Icon(Icons.reorder),
                onPressed: () {
                  changeCurrentLineTypeTo(RichType.Text);
                },
              ),
              IconButton(
                icon: Icon(Icons.format_bold),
                onPressed: () {
                  changeCurrentLineTypeTo(RichType.TextBold);
                },
              ),
              IconButton(
                icon: Icon(Icons.format_list_numbered),
                onPressed: () {
                  changeCurrentLineTypeTo(RichType.OrderedLists);
                },
              ),
              IconButton(
                icon: Icon(Icons.format_list_bulleted),
                onPressed: () {
                  changeCurrentLineTypeTo(RichType.UnorderedList);
                },
              ),
              IconButton(
                icon: Icon(Icons.aspect_ratio),
                onPressed: () {
                  changeCurrentLineTypeTo(RichType.Reference);
                },
              ),
              IconButton(
                icon: Icon(Icons.check_box),
                onPressed: () {
                  changeCurrentLineTypeTo(RichType.Task);
                },
              ),
              IconButton(
                icon: Icon(Icons.photo),
                onPressed: () {
                  //getContentList();
                },
              ),
            ],
          ),
        ),
      );
    }
    return bodyItems;
  }

  @override
  Widget build(BuildContext context) {
    calculationOrderedList();
    if (widget.isFixed) {
      return Column(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: buildFixedBody(),
      );
    }
    return Column(
      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: buildBody(),
    );
  }
}
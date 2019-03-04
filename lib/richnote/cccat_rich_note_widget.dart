import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/models/models.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_data.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_layout.dart';

class RichNote extends StatefulWidget {
  RichNote({
    this.richSource,
    this.richNoteLayout,
    this.onTapLine,
    this.onLongTapLine,
    this.store,
  })  : isEditable = false,
        isFixed = false,
        assert(richSource.paragraphList != null) {
    richSource.richNote = this;
  }

  RichNote.editable({
    this.richSource,
    this.richNoteLayout,
    this.onTapLine,
    this.onLongTapLine,
    this.store,
  })  : isEditable = true,
        isFixed = false {
    richSource.richNote = this;
    debugPrint('RichNote.editable 模式初始化');
    richSource.markToEditer();
  }

  RichNote.fixed({
    this.richSource,
    this.richNoteLayout,
    this.onTapLine,
    this.onLongTapLine,
    this.store,
  })  : isFixed = true,
        isEditable = false {
    richSource.richNote = this;
  }

  final bool isEditable;
  final bool isFixed;
  final ValueChanged<int> onTapLine;
  final ValueChanged<int> onLongTapLine;
  final RichNoteLayout richNoteLayout;
  final RichSource richSource;
  final GlobalStoreState store;

  @override
  RichNoteState createState() {
    return RichNoteState();
  }
}

class RichNoteState extends State<RichNote> {
  TextTheme textTheme;
  RichNoteLayout layout;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    layout = widget.richNoteLayout;
    textTheme = Theme.of(context).textTheme;
    if (layout == null) {
      layout = RichNoteLayout(
        context,
        titleStyle: textTheme.title
            .merge(TextStyle(color: Theme.of(context).primaryColor)),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.isEditable) {
      widget.richSource.paragraphList.forEach((item) {
        if (item is RichItem) {
          item.dispose();
        }
      });
      widget.richSource.paragraphList = null;
    }
  }

  Widget buildParagraphLayoutWidget(int index) {
    var item = widget.richSource.paragraphList[index];
    Widget paragraphWidget;
    switch (item.type) {
      case RichType.FocusTitle:
        var effectiveSytle =
            layout.titleStyle == null ? textTheme.title : layout.titleStyle;
        if (widget.isEditable) {
          paragraphWidget =
              layout.richLayoutText(buildTextField(index, effectiveSytle));
        } else {
          paragraphWidget = layout.richLayoutTitle(Text(
              widget.store.getFocusTitleFrom(int.parse(item.content)),
              style: effectiveSytle));
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
          paragraphWidget =
              layout.richLayoutText(buildTextField(index, effectiveSytle));
        } else {
          paragraphWidget =
              layout.richLayoutText(Text(item.content, style: effectiveSytle));
        }
        break;
      case RichType.TextBold:
        var effectiveSytle = layout.contentBoldStyle == null
            ? textTheme.body1.merge(TextStyle(fontWeight: FontWeight.bold))
            : layout.contentBoldStyle;
        if (widget.isEditable) {
          paragraphWidget =
              layout.richLayoutText(buildTextField(index, effectiveSytle));
        } else {
          paragraphWidget =
              layout.richLayoutText(Text(item.content, style: effectiveSytle));
        }
        break;
      case RichType.Task:
        var effectiveSytle =
            layout.taskStyle == null ? textTheme.body1 : layout.taskStyle;
        if (widget.isEditable) {
          paragraphWidget = layout.richLayoutTask(
              Checkbox(
                value: widget.richSource.paragraphList[index].checkState,
                onChanged: (isSelected){
                  setState(() {
                    widget.richSource.paragraphList[index].checkState = isSelected;
                  });
                }
              ),
              buildTextField(index, effectiveSytle),
              Text(
                '9:20 - 10:00',
                style: textTheme.caption,
              ));
        } else {
          paragraphWidget = layout.richLayoutTask(
            Checkbox(
              value: widget.richSource.paragraphList[index].checkState,
              onChanged: (isSelected){
                setState(() {
                  widget.richSource.paragraphList[index].checkState = isSelected;

//                  List<RichLine> tempList = [];
                  FocusEvent event = widget.richSource.paragraphList[index].note;
//                  widget.richSource.paragraphList.forEach((line){
//                    if (line.note == event && line.type != RichType.FocusTitle) {
//                      tempList.add(line);
//                    }
//                  });
                  //event.note = RichSource.getJsonFromRichLine(event);//widget.richSource.getParagraphJsonString(tempList);
                  widget.store.changeFocusEvent(event);
                });
              }
            ),
            Text(item.content, style: effectiveSytle),
            Text(
              '9:20 - 10:00',
              style: textTheme.caption,
            ));
        }
        break;
      case RichType.OrderedLists:
        var effectiveSytle = layout.orderedListsStyle == null
            ? textTheme.body1
            : layout.orderedListsStyle;
        if (widget.isEditable) {
          paragraphWidget = layout.richLayoutList(
              Text(item.leading, style: effectiveSytle),
              buildTextField(index, effectiveSytle));
        } else {
          paragraphWidget = layout.richLayoutList(
              Text(item.leading, style: effectiveSytle),
              Text(item.content, style: effectiveSytle));
        }
        break;
      case RichType.SubOrderedLists:
        var effectiveSytle = layout.orderedListsStyle == null
            ? textTheme.body1
            : layout.orderedListsStyle;
        if (widget.isEditable) {
          paragraphWidget = layout.richLayoutSubList(
              Text(item.leading, style: effectiveSytle),
              buildTextField(index, effectiveSytle));
        } else {
          paragraphWidget = layout.richLayoutSubList(
              Text(item.leading, style: effectiveSytle),
              Text(item.content, style: effectiveSytle));
        }
        break;
      case RichType.UnorderedList:
        var effectiveSytle = layout.unorderedListStyle == null
            ? textTheme.body1
            : layout.unorderedListStyle;
        if (widget.isEditable) {
          paragraphWidget = layout.richLayoutList(
            Text(item.leading, style: effectiveSytle),
            buildTextField(index, effectiveSytle),
          );
        } else {
          paragraphWidget = layout.richLayoutList(
              Text(item.leading, style: effectiveSytle),
              Text(item.content, style: effectiveSytle));
        }
        break;
      case RichType.SubUnorderedList:
        var effectiveSytle = layout.unorderedListStyle == null
            ? textTheme.body1
            : layout.unorderedListStyle;
        if (widget.isEditable) {
          paragraphWidget = layout.richLayoutSubList(
            Text(item.leading, style: effectiveSytle),
            buildTextField(index, effectiveSytle),
          );
        } else {
          paragraphWidget = layout.richLayoutSubList(
              Text(item.leading, style: effectiveSytle),
              Text(item.content, style: effectiveSytle));
        }
        break;
      case RichType.Reference:
        var effectiveSytle = layout.referenceStyle == null
            ? textTheme.body1
            : layout.referenceStyle;
        if (widget.isEditable) {
          paragraphWidget = layout.richLayoutReference(
              buildTextField(index, effectiveSytle)); //richLayoutReference
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
    final current = widget.richSource.paragraphList[index];
    final next = widget.richSource.paragraphList[index + 1];
    const List<RichType> listType = [
      RichType.OrderedLists,
      RichType.UnorderedList,
      RichType.SubOrderedLists,
      RichType.SubUnorderedList
    ];
    if (current.type == RichType.Task && next.type == RichType.Task) {
      return SizedBox(height: layout.listLineSpacing);
    } else if (listType.indexOf(current.type) > -1 &&
        listType.indexOf(next.type) > -1) {
      return SizedBox(
        height: layout.listLineSpacing,
        width: double.infinity,
      );
    } else if (current.type == RichType.FocusTitle) {
      return SizedBox(height: 12);
    } else if (next.type == RichType.FocusTitle) {
      return Column(
        children: <Widget>[
          SizedBox(height: 12),
          Divider(),
        ],
      );
    }
    return SizedBox(height: layout.segmentSpacing);
  }

  int _getCurrentLineIndex() {
    int index = -1;
    for (int i = 0; i < widget.richSource.paragraphList.length; i++) {
      RichItem item = (widget.richSource.paragraphList[i]);
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
    if (widget.richSource.paragraphList.length == 1) return;
    int index = _getCurrentLineIndex();
    if (index > -1) {
      RichItem tempItem = widget.richSource.paragraphList[index];
      setState(() {
        widget.richSource.paragraphList.removeAt(index);
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        tempItem.dispose();
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        RichItem item = widget.richSource.paragraphList[index];
        item.controller.selection = TextSelection.fromPosition(TextPosition(
          affinity: TextAffinity.downstream,
          offset: 1,
        ));
        _requestFocus(item?.node);
      });
    }
  }

  RichType getCurrentRichType() {
    RichType type;
    int index = _getCurrentLineIndex();
    if (index > -1) {
      RichItem item = widget.richSource.paragraphList[index];
      type = item.type;
    }
    return type;
  }

  void changeParagraphTypeTo(RichType type) {
    int index = _getCurrentLineIndex();
    if (index > -1) {
      RichItem item = widget.richSource.paragraphList[index];
      setState(() {
        item.type = type;
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        _requestFocus(item?.node);
      });
    }
  }

  void calculationOrderedList() {
    int ybh = 1, ebh = 1;
    widget.richSource.paragraphList?.forEach((line) {
      if (line.type == RichType.OrderedLists) {
        line.leading = '$ybh.';
        ybh++;
        ebh = 1;
      } else if (line.type == RichType.SubOrderedLists) {
        line.leading = '$ebh.';
        ebh++;
      } else if (line.type == RichType.UnorderedList) {
        line.leading = '-'; // •
        ybh = 1;
        ebh = 1;
      } else if (line.type == RichType.SubUnorderedList) {
        line.leading = '•'; //▪ ●
      } else {
        ybh = 1;
        ebh = 1;
      }
    });
  }

  void mergeUPLine(int index, String text) {
    debugPrint('向上行合并');
    RichItem tempLine = widget.richSource.paragraphList[index];
    if (index > 0) {
      setState(() {
        RichItem upLine = widget.richSource.paragraphList[index - 1];
        _requestFocus(upLine.node);
        var p = upLine.controller.text.length;
        var newText = upLine.controller.text + text;
        upLine.canChanged = false;
        upLine.controller.text = newText;
        upLine.controller.selection = TextSelection.fromPosition(
          TextPosition(affinity: TextAffinity.downstream, offset: p),
        );
        widget.richSource.paragraphList.removeAt(index);
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        tempLine.dispose();
      });
    }
  }

  void splitLine(int index, List<String> lines) {
    if (lines.length < 2) return;

    RichItem oldItem = widget.richSource.paragraphList[index];
    RichItem newItem;
    RichType newType;
    debugPrint('第一行字数：${lines[0].length}');
    debugPrint('第二行字数：${lines[1].length}');

    var upTxt = lines[0].replaceAll('\u0000', '');

    if (upTxt.length == 0 && lines[1].length == 0) {
      if (index == 0) return;
      setState(() {
        RichItem item = widget.richSource.paragraphList[index];
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
        widget.richSource.paragraphList.insert(index + 1, newItem);
        Future.delayed(const Duration(milliseconds: 50), () {
          _requestFocus(newItem?.node);
        });
      });
    }
  }

  Widget buildTextField(int index, TextStyle effectiveSytle) {
    var item = widget.richSource.paragraphList[index] as RichItem;
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

  List<Widget> buildFixedBody() {
    List<Widget> bodyItems = [];
    int listLength = widget.richSource.paragraphList.length;
    for (int index = 0; index < listLength; index++) {
      bodyItems.add(buildParagraphLayoutWidget(index));
      if (index < listLength - 1) bodyItems.add(buildSeparatorWidget(index));
    }
    return bodyItems;
  }

  List<Widget> buildBody() {
    List<Widget> bodyItems = [];
    bodyItems.add(Expanded(
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
            onLongPress: () {
              if (widget.onLongTapLine != null) {
                widget.onLongTapLine(index);
              }
            },
          );
        },
        separatorBuilder: (context, index) {
          return buildSeparatorWidget(index);
        },
        itemCount: widget.richSource.paragraphList.length,
      ),
    ));
    if (widget.isEditable) {
      bodyItems.add(Divider(
        height: 1.0,
      ));
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
                  changeParagraphTypeTo(RichType.Text);
                },
              ),
              IconButton(
                icon: Icon(Icons.format_bold),
                onPressed: () {
                  changeParagraphTypeTo(RichType.TextBold);
                },
              ),
              IconButton(
                icon: Icon(Icons.format_list_numbered),
                onPressed: () {
                  RichType type = getCurrentRichType();
                  if (type == RichType.SubUnorderedList) {
                    changeParagraphTypeTo(RichType.SubOrderedLists);
                  } else {
                    changeParagraphTypeTo(RichType.OrderedLists);
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.format_list_bulleted),
                onPressed: () {
                  RichType type = getCurrentRichType();
                  if (type == RichType.SubOrderedLists) {
                    changeParagraphTypeTo(RichType.SubUnorderedList);
                  } else {
                    changeParagraphTypeTo(RichType.UnorderedList);
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.format_indent_increase),
                onPressed: () {
                  RichType type = getCurrentRichType();
                  if (type == RichType.OrderedLists) {
                    changeParagraphTypeTo(RichType.SubOrderedLists);
                  } else if (type == RichType.UnorderedList) {
                    changeParagraphTypeTo(RichType.SubUnorderedList);
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.format_indent_decrease),
                onPressed: () {
                  RichType type = getCurrentRichType();
                  if (type == RichType.SubOrderedLists) {
                    changeParagraphTypeTo(RichType.OrderedLists);
                  } else if (type == RichType.SubUnorderedList) {
                    changeParagraphTypeTo(RichType.UnorderedList);
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.aspect_ratio),
                onPressed: () {
                  changeParagraphTypeTo(RichType.Reference);
                },
              ),
              IconButton(
                icon: Icon(Icons.check_box),
                onPressed: () {
                  changeParagraphTypeTo(RichType.Task);
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

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_data.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_layout.dart';
import 'package:flutter_moment/task/TaskItem.dart';

class RichNote extends StatefulWidget {
  RichNote({
    this.richSource,
    this.richNoteLayout,
    this.onTapLine,
    this.onLongTapLine,
    this.store,
  })  : isEditable = false,
        isFixed = false,
        assert(richSource.richLineList != null) {
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
    richSource.markEditerItem();
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

  final maxIndent = 1;
  bool get isNotEditable => !isEditable;

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
      widget.richSource.richLineList.forEach((item) {
        if (item is RichItem) {
          item.dispose();
        }
      });
      widget.richSource.richLineList = null;
    }
  }

  Widget buildParagraphLayoutWidget(int index) {
    var item = widget.richSource.richLineList[index];
    Widget paragraphWidget;
    switch (item.type) {
      case RichType.FocusTitle:
        var effectiveSytle = layout.titleStyle == null
            ? textTheme.title.merge(mergeRichStyle(item.style))
            : layout.titleStyle;
        if (widget.isEditable) {
          paragraphWidget =
              layout.richLayoutText(_buildTextField(index, effectiveSytle));
        } else {
          paragraphWidget = layout.richLayoutTitle(Text(
              widget.store.getFocusTitleFrom(int.parse(item.getContent())),
              style: effectiveSytle));
        }
        break;
      case RichType.Title:
        var effectiveSytle = layout.titleStyle == null
            ? textTheme.title.merge(mergeRichStyle(item.style))
            : layout.titleStyle;
        if (widget.isEditable) {
          paragraphWidget =
              layout.richLayoutText(_buildTextField(index, effectiveSytle));
        } else {
          paragraphWidget = Text(
            item.getContent(),
            style: effectiveSytle,
          );
        }
        break;
      case RichType.SubTitle:
        var effectiveSytle = layout.subTitleStyle == null
            ? textTheme.subhead.merge(mergeRichStyle(item.style))
            : layout.subTitleStyle;
        if (widget.isEditable) {
          paragraphWidget =
              layout.richLayoutText(_buildTextField(index, effectiveSytle));
        } else {
          paragraphWidget = Text(
            item.getContent(),
            style: effectiveSytle,
          );
        }
        break;
      case RichType.Text:
        var effectiveSytle = layout.contentStyle == null
            ? textTheme.body1.merge(mergeRichStyle(item.style))
            : layout.contentStyle;
        if (widget.isEditable) {
          paragraphWidget =
              layout.richLayoutText(_buildTextField(index, effectiveSytle));
        } else {
          paragraphWidget =
              layout.richLayoutText(Text(item.getContent(), style: effectiveSytle));
        }
        break;
      case RichType.Task:
        RichLine richLine = widget.richSource.richLineList[index];
        TaskItem task = richLine.expandData;
        var effectiveSytle = layout.taskStyle == null
            ? textTheme.body1.merge(mergeRichStyle(item.style))
            : layout.taskStyle;
        if (widget.isEditable) {
          paragraphWidget = layout.richLayoutTask(
              Checkbox(
                key: (richLine as RichItem).checkBoxKey ,
                value: task.state == TaskState.Complete,
                onChanged: (isSelected) {
                  setState(() {
                    task.state =
                        isSelected ? TaskState.Complete : TaskState.StandBy;
                  });
                }),
              _buildTextField(index, effectiveSytle),
              Text(
                '9:20 - 10:00',
                style: textTheme.caption,
              ));
        } else {
          paragraphWidget = layout.richLayoutTask(
              Checkbox(
                  value: task.state == TaskState.Complete,
                  onChanged: (isSelected) {
                    setState(() {
                      task.state =
                          isSelected ? TaskState.Complete : TaskState.StandBy;
                      widget.store.changeTaskItem(task);
                    });
                  }),
              Text(item.getContent(), style: effectiveSytle),
              Text(
                '9:20 - 10:00',
                style: textTheme.caption,
              ));
        }
        break;
      case RichType.OrderedLists:
        var effectiveSytle = layout.orderedListsStyle == null
            ? textTheme.body1.merge(mergeRichStyle(item.style))
            : layout.orderedListsStyle;
        if (widget.isEditable) {
          paragraphWidget = layout.richLayoutList(
              item.indent,
              Text(item.leading, style: effectiveSytle),
              _buildTextField(index, effectiveSytle));
        } else {
          paragraphWidget = layout.richLayoutList(
              item.indent,
              Text(item.leading, style: effectiveSytle),
              Text(item.getContent(), style: effectiveSytle));
        }
        break;
      case RichType.UnorderedList:
        var effectiveSytle = layout.unorderedListStyle == null
            ? textTheme.body1.merge(mergeRichStyle(item.style))
            : layout.unorderedListStyle;
        if (widget.isEditable) {
          paragraphWidget = layout.richLayoutList(
            item.indent,
            Text(item.leading, style: effectiveSytle),
            _buildTextField(index, effectiveSytle),
          );
        } else {
          paragraphWidget = layout.richLayoutList(
              item.indent,
              Text(item.leading, style: effectiveSytle),
              Text(item.getContent(), style: effectiveSytle));
        }
        break;
      case RichType.Reference:
        var effectiveSytle = layout.referenceStyle == null
            ? textTheme.body1.merge(mergeRichStyle(item.style))
            : layout.referenceStyle;
        if (widget.isEditable) {
          paragraphWidget = layout.richLayoutReference(
              _buildTextField(index, effectiveSytle)); //richLayoutReference
        } else {
          paragraphWidget = layout
              .richLayoutReference(Text(item.getContent(), style: effectiveSytle));
        }
        break;
      case RichType.Comment:
        var effectiveSytle = layout.referenceStyle == null
            ? textTheme.body1.merge(mergeRichStyle(item.style))
            : layout.referenceStyle;
        if (widget.isEditable) {
          paragraphWidget =
              layout.richLayoutComment(_buildTextField(index, effectiveSytle));
        } else {
          paragraphWidget = layout
              .richLayoutComment(Text(item.getContent(), style: effectiveSytle));
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
      case RichType.Food:
        break;
      case RichType.Related:
        paragraphWidget = Text(item.content,
          style: textTheme.caption,
        );
        break;
    }
    return paragraphWidget;
  }

  TextStyle mergeRichStyle(RichStyle style) {
    TextStyle mergeStyle;
    switch (style) {
      case RichStyle.Normal:
        mergeStyle = TextStyle(fontWeight: FontWeight.normal);
        break;
      case RichStyle.Bold:
        mergeStyle = TextStyle(fontWeight: FontWeight.bold);
        break;
      case RichStyle.Italic:
        mergeStyle = TextStyle(fontStyle: FontStyle.italic);
    }
    return mergeStyle;
  }

  Widget buildSeparatorWidget(int index) {
    final current = widget.richSource.richLineList[index];
    final next = widget.richSource.richLineList[index + 1];
    const List<RichType> listType = [
      RichType.OrderedLists,
      RichType.UnorderedList,
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
    for (int i = 0; i < widget.richSource.richLineList.length; i++) {
      RichItem item = (widget.richSource.richLineList[i]);
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
    if (widget.richSource.richLineList.length == 1) return;
    int index = _getCurrentLineIndex();
    if (index > -1) {
      RichItem tempItem = widget.richSource.richLineList[index];
      if (tempItem.type == RichType.Task) {
        widget.store.removeTaskItem(tempItem.expandData);
      }
      setState(() {
        widget.richSource.richLineList.removeAt(index);
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        tempItem.dispose();
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        RichItem item = widget.richSource.richLineList[index];
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
      RichItem item = widget.richSource.richLineList[index];
      type = item.type;
    }
    return type;
  }

  RichItem getCurrentRichItem() {
    RichItem item;
    int index = _getCurrentLineIndex();
    if (index > -1) {
      item = widget.richSource.richLineList[index];
    }
    return item;
  }

  void changeParagraphTypeTo(RichType type) {
    int index = _getCurrentLineIndex();
    if (index > -1) {
      RichItem item = widget.richSource.richLineList[index];
      setState(() {
        item.changeTypeTo(type);
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        _requestFocus(item?.node);
      });
    }
  }

  void changeLineStyleTo(RichStyle style) {
    int index = _getCurrentLineIndex();
    if (index > -1) {
      RichItem item = widget.richSource.richLineList[index];
      setState(() {
        if (item.style == style) {
          item.style = RichStyle.Normal;
          debugPrint('恢复为标准风格');
        } else {
          item.style = style;
          debugPrint('设置为黑体风格');
        }
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        _requestFocus(item?.node);
      });
    }
  }

  void calculationOrderedList() {
    const unorderedLeading = ['-', '•']; // • ▪ ●
    int ybh = 1, ebh = 1;
    widget.richSource.richLineList?.forEach((line) {
      if (line.type == RichType.OrderedLists) {
        if (line.indent == 0) {
          line.leading = '$ybh.';
          ybh++;
          ebh = 1;
        } else if (line.indent == 1) {
          line.leading = '$ebh.';
          ebh++;
        }
      } else {
        ybh = 1;
        ebh = 1;
        if (line.type == RichType.UnorderedList) {
          line.leading = unorderedLeading[line.indent];
        }
      }
    });
  }

  void mergeUPLine(int index, String text) {
    debugPrint('向上行合并');
    RichItem tempLine = widget.richSource.richLineList[index];
    if (index > 0) {
      setState(() {
        RichItem upLine = widget.richSource.richLineList[index - 1];
        _requestFocus(upLine.node);
        var p = upLine.controller.text.length;
        var newText = upLine.controller.text + text;
        upLine.canChanged = false;
        upLine.controller.text = newText;
        upLine.controller.selection = TextSelection.fromPosition(
          TextPosition(affinity: TextAffinity.downstream, offset: p),
        );
        if (tempLine.type == RichType.Task) {
          TaskItem task = tempLine.expandData;
          if (task.boxId > 0) {
            widget.richSource.mergeRemoveTask.add(task);
          }
        }
        widget.richSource.richLineList.removeAt(index);
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        tempLine.dispose();
      });
    }
  }

  void splitLine(int index, List<String> lines) {
    if (lines.length < 2) return;

    RichItem oldItem = widget.richSource.richLineList[index];
    RichItem newItem;
    RichType newType;
    int indent = 0;
    debugPrint('第一行字数：${lines[0].length}');
    debugPrint('第二行字数：${lines[1].length}');

    var upTxt = lines[0].replaceAll('\u0000', '');

    if (upTxt.length == 0 && lines[1].length == 0) {  // 处理在空行上按回车键后转换成text类型
      if (index == 0) return;
      setState(() {
        oldItem.canChanged = false;
        oldItem.type = RichType.Text;
        oldItem.controller.text = '\u0000' + '';
        oldItem.controller.selection = TextSelection.fromPosition(
            TextPosition(affinity: TextAffinity.downstream, offset: 1));
        //item.canChanged = true;
      });
    } else {
      oldItem.canChanged = false;
      oldItem.controller.text = '\u0000' + lines[0];
      oldItem.controller.selection = TextSelection.fromPosition(TextPosition(
        affinity: TextAffinity.downstream,
        offset: oldItem.controller.text.length,
      ));
      if (oldItem.type == RichType.Title ||
          oldItem.type == RichType.SubTitle ||
          oldItem.type == RichType.Reference ||
          oldItem.type == RichType.Comment) {
        newType = RichType.Text;
      } else {
        newType = oldItem.type;
        if (oldItem.type == RichType.OrderedLists ||
            oldItem.type == RichType.UnorderedList) {
          indent = oldItem.indent;
        }
      }
      setState(() {
        newItem = RichItem(
          source: widget.richSource,
          type: newType,
          content: lines[1],
          dayIndex: widget.store.selectedDateIndex,
        );
        newItem.canChanged = false;
        newItem.controller.selection = TextSelection.fromPosition(TextPosition(
          affinity: TextAffinity.downstream,
          offset: 1,
        ));
        widget.richSource.richLineList.insert(index + 1, newItem);
        Future.delayed(const Duration(milliseconds: 50), () {
          _requestFocus(newItem?.node);
        });
      });
    }
  }

  Widget _buildTextField(int index, TextStyle effectiveSytle) {
    var item = widget.richSource.richLineList[index] as RichItem;
    assert(item.controller != null);
    assert(item.node != null);
    return TextField(
      key: item.textkey,
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

  List<Widget> _buildFixedBody() {
    List<Widget> bodyItems = [];
    int listLength = widget.richSource.richLineList.length;
    for (int index = 0; index < listLength; index++) {
      bodyItems.add(buildParagraphLayoutWidget(index));
      if (index < listLength - 1) bodyItems.add(buildSeparatorWidget(index));
    }
    return bodyItems;
  }

  List<Widget> _buildBody() {
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
        itemCount: widget.richSource.richLineList.length,
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
                color: Colors.black87,
                tooltip: '删除当前段落文本',
                onPressed: () {
                  removeCurrentLine();
                },
              ),
              IconButton(
                icon: Icon(Icons.reorder),
                color: Colors.black87,
                onPressed: () {
                  changeParagraphTypeTo(RichType.Text);
                },
              ),
              IconButton(
                icon: Icon(Icons.format_bold),
                color: Colors.black87,
                onPressed: () {
                  changeLineStyleTo(RichStyle.Bold);
                },
              ),
              IconButton(
                icon: Icon(Icons.format_list_numbered),
                color: Colors.black87,
                onPressed: () {
                  final item = getCurrentRichItem();
                  if (item.type == RichType.OrderedLists) {
                    changeParagraphTypeTo(RichType.Text);
                  } else {
                    changeParagraphTypeTo(RichType.OrderedLists);
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.format_list_bulleted),
                color: Colors.black87,
                onPressed: () {
                  final item = getCurrentRichItem();
                  if (item.type == RichType.UnorderedList) {
                    changeParagraphTypeTo(RichType.Text);
                  } else {
                    changeParagraphTypeTo(RichType.UnorderedList);
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.format_indent_increase),
                color: Colors.black87,
                onPressed: () {
                  var item = getCurrentRichItem();
                  if (item.type == RichType.OrderedLists ||
                      item.type == RichType.UnorderedList) {
                    if (item.indent < widget.maxIndent) {
                      setState(() {
                        item.indent++;
                      });
                    }
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.format_indent_decrease),
                color: Colors.black87,
                onPressed: () {
                  var item = getCurrentRichItem();
                  if (item.type == RichType.OrderedLists ||
                      item.type == RichType.UnorderedList) {
                    if (item.indent > 0) {
                      setState(() {
                        item.indent--;
                      });
                    }
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.insert_comment),
                color: Colors.black87,
                onPressed: () {
                  final item = getCurrentRichItem();
                  if (item.type == RichType.Comment) {
                    changeParagraphTypeTo(RichType.Text);
                  } else {
                    changeParagraphTypeTo(RichType.Comment);
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.check_box),
                color: Colors.black87,
                onPressed: () {
                  final item = getCurrentRichItem();
                  if (item.type == RichType.Task) {
                    changeParagraphTypeTo(RichType.Text);
                  } else {
                    changeParagraphTypeTo(RichType.Task);
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.photo),
                color: Colors.black87,
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildFixedBody(),
      );
    }
    return Column(
      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _buildBody(),
    );
  }
}

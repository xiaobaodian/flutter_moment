import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/models/helper_chinese_string.dart';
import 'package:flutter_moment/models/data_helper.dart';
import 'package:flutter_moment/models/models.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_data.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_layout.dart';
import 'package:flutter_moment/task/task_item.dart';
import 'package:flutter_moment/widgets/cccat_divider_ext.dart';
import 'package:flutter_moment/widgets/cccat_list_tile.dart';
import 'package:flutter_moment/widgets/gender_label_choice_dialog.dart';

class RichNoteTapObject {
  RichNoteTapObject(
    this.index,
    this.richLine,
  );
  int index;
  RichLine richLine;
}

enum BarType {
  FormatBar,
  LabelBar
}

enum LabelType {
  Person,
  Place,
  Tag
}

class RichNote extends StatefulWidget {
  RichNote({
    @required this.store,
    @required this.richSource,
    this.richNoteLayout,
    this.onTap,
    this.onLongTap,
  })  : isEditable = false,
        isFixed = false,
        focusEvent = null,
        assert(richSource.richLineList != null) {
    richSource.richNote = this;
  }

  RichNote.editable({
    @required this.store,
    @required this.richSource,
    //@required this.focusEvent,
    this.richNoteLayout,
    this.onTap,
    this.onLongTap,
  })  : isEditable = true,
        isFixed = false,
        focusEvent = richSource.focusEvent {
    richSource.richNote = this;
    debugPrint('RichNote.editable 模式初始化');
    richSource.markEditerItem();
  }

  RichNote.fixed({
    @required this.store,
    @required this.richSource,
    this.richNoteLayout,
    this.onTap,
    this.onLongTap,
  })  : isFixed = true,
        isEditable = false,
        focusEvent = null {
    richSource.richNote = this;
  }

  final bool isEditable;
  final bool isFixed;
  final ValueChanged<RichNoteTapObject> onTap;
  final ValueChanged<RichNoteTapObject> onLongTap;
  final RichNoteLayout richNoteLayout;
  final RichSource richSource;
  final GlobalStoreState store;
  final FocusEvent focusEvent;

  final _maxIndent = 1;
  bool get isNotEditable => !isEditable;

  @override
  RichNoteState createState() => RichNoteState();
}

class RichNoteState extends State<RichNote> {
  TextTheme textTheme;
  RichNoteLayout layout;
  BarType barType;

  @override
  void initState() {
    super.initState();
    barType = BarType.FormatBar;
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

  Widget buildLineLayoutWidget(int index) {
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
              widget.store.getFocusTitleBy(int.parse(item.getContent())),
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
          paragraphWidget = layout
              .richLayoutText(Text(item.getContent(), style: effectiveSytle));
        }
        break;
      case RichType.Task:
        TaskItem task = item.expandData;
        if (task == null) {
          item.type = RichType.Text;
          item.content = '这里丢失了任务数据';
          break;
        }
        Widget checkBox = Checkbox(
          value: task.state == TaskState.Complete,
          onChanged: (isSelected) {
            setState(() {
              task.state =
              isSelected ? TaskState.Complete : TaskState.StandBy;
              if (widget.isNotEditable) {
                widget.store.taskSet.changeItem(task);
              }
            });
          }
        );
        var effectiveSytle = layout.taskStyle == null
            ? textTheme.body1.merge(mergeRichStyle(item.style))
            : layout.taskStyle;
        if (task.state == TaskState.Complete) {
          effectiveSytle = effectiveSytle.merge(TextStyle(
              color: Colors.black54,
              decoration: TextDecoration.lineThrough,
              decorationStyle: TextDecorationStyle.solid,
          ));
        }
        if (widget.isEditable) {
          paragraphWidget = layout.richLayoutTask(
            checkBox,
            _buildTextField(index, effectiveSytle),
            Text(
              '全天',
              style: textTheme.caption,
            )
          );
        } else {
          paragraphWidget = layout.richLayoutTask(
            checkBox,
            Text(item.getContent(), style: effectiveSytle),
            Text(
              '全天',
              style: textTheme.caption,
            )
          );
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
            _buildTextField(index, effectiveSytle)
          );
        } else {
          paragraphWidget = layout.richLayoutList(
            item.indent,
            Text(item.leading, style: effectiveSytle),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 3, 0, 3),
              child: Text(item.getContent(), style: effectiveSytle),
            )
          );
        }
        break;
      case RichType.UnorderedList:
        var effectiveSytle = layout.unorderedListStyle == null
            ? textTheme.body1.merge(mergeRichStyle(item.style))
            : layout.unorderedListStyle;
        if (widget.isEditable) {
          paragraphWidget = layout.richLayoutList(
            item.indent,
            Text(item.leading,
                style: effectiveSytle
                    .merge(TextStyle(color: Colors.black54, fontSize: 12))),
            _buildTextField(index, effectiveSytle),
          );
        } else {
          paragraphWidget = layout.richLayoutList(
              item.indent,
              Text(item.leading,
                  style: effectiveSytle
                      .merge(TextStyle(color: Colors.black54, fontSize: 10))),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 3, 0, 3),
                child: Text(item.getContent(), style: effectiveSytle),
              ));
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
          paragraphWidget = layout.richLayoutReference(
              Text(item.getContent(), style: effectiveSytle));
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
          paragraphWidget = layout.richLayoutComment(
              Text(item.getContent(), style: effectiveSytle));
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
        IconData iconData;
        if (item.indent == 0) {
          iconData = Icons.people;
        } else if (item.indent == 1) {
          iconData = Icons.map;
        } else if (item.indent == 2) {
          iconData = Icons.label;
        } else {
          iconData = Icons.favorite_border;
        }
        paragraphWidget = Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              iconData,
              size: 16,
              color: Theme.of(context).accentColor,
            ),
            Text('   '),
            Text(item.content, style: textTheme.caption),
          ],
        );
        break;
    }
    return paragraphWidget;
  }

  TextStyle mergeRichStyle(RichStyle style) {
    TextStyle mergeStyle;
    switch (style) {
      case RichStyle.Normal:
        mergeStyle = TextStyle(
          fontWeight: FontWeight.normal,
          textBaseline: TextBaseline.ideographic,
        );
        break;
      case RichStyle.Bold:
        mergeStyle = TextStyle(
          fontWeight: FontWeight.bold,
          textBaseline: TextBaseline.ideographic,
        );
        break;
      case RichStyle.Italic:
        mergeStyle = TextStyle(
          fontStyle: FontStyle.italic,
          textBaseline: TextBaseline.ideographic,
        );
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
          //Divider(),
          DividerExt(thickness: 6, color: Color.fromARGB(127, 235, 235, 235),),
        ],
      );
    } else if (current.type != RichType.Related && next.type == RichType.Related) {
      double right = MediaQuery.of(context).size.width * 0.8;
      return Padding(
        padding: EdgeInsets.fromLTRB(16, 12, right, 12),
        child: Divider(height: 1,),
      );
    }
    return SizedBox(height: layout.segmentSpacing);
  }

  int _getCurrentLineIndex() {
    int index = -1;
    for (int i = 0; i < widget.richSource.richLineList.length; i++) {
      RichItem item = (widget.richSource.richLineList[i]);
      if (item.focusNode.hasFocus) {
        index = i;
        break;
      }
    }
    return index;
  }

  FocusNode _getCurrentFocusNode() {
    FocusNode node;
    for (int i = 0; i < widget.richSource.richLineList.length; i++) {
      RichItem item = (widget.richSource.richLineList[i]);
      if (item.focusNode.hasFocus) {
        node = item.focusNode;
        break;
      }
    }
    return node;
  }

  RichItem _getCurrentRichItem() {
    RichItem item;
    for (int i = 0; i < widget.richSource.richLineList.length; i++) {
      item = (widget.richSource.richLineList[i]);
      if (item.focusNode.hasFocus) break;
    }
    return item;
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
        //widget.store.removeTaskItem(tempItem.expandData);
        TaskItem task = tempItem.expandData;
        widget.store.taskSet.removeItem(task);
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
        _requestFocus(item?.focusNode);
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
        _requestFocus(item?.focusNode);
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
        _requestFocus(item?.focusNode);
      });
    }
  }

  void calculationOrderedList() {
    const unorderedLeading = ['●', '○']; // ■ ○●◇◆
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
        //tempLine.focusNode.unfocus();
        RichItem upLine = widget.richSource.richLineList[index - 1];
        var p = upLine.controller.text.length;
        var newText = upLine.controller.text + text;
        upLine.canChanged = false;
        upLine.controller.text = newText;
        upLine.controller.selection = TextSelection.fromPosition(
          TextPosition(affinity: TextAffinity.downstream, offset: p),
        );
        _requestFocus(upLine.focusNode);
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
    } else {
      tempLine.canChanged = false;
      String text = tempLine.controller.text.replaceAll('\u0000', '');
      tempLine.controller.text = '\u0000' + text;
      tempLine.controller.selection = TextSelection.fromPosition(TextPosition(
        affinity: TextAffinity.downstream,
        offset: 1,
      ));
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

    if (upTxt.length == 0 && lines[1].length == 0) {
      // 处理在空行上按回车键后转换成text类型
      if (index == 0) return;
      setState(() {
        oldItem.type = RichType.Text;
        oldItem.canChanged = false;
        oldItem.controller.text = '\u0000' + '';
        oldItem.controller.selection = TextSelection.fromPosition(
            TextPosition(affinity: TextAffinity.downstream, offset: 1));
        //item.canChanged = true;
      });
    } else {
      //以后转换成识别是否拥有焦点然后处理内容后去掉一下这句 ???存疑
      oldItem.canChanged = false;
      oldItem.controller.text = lines[0];
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
      newItem = RichItem(
        source: widget.richSource,
        type: newType,
        content: lines[1], // 加入'\u0000'在RichItem内部完成
      );
      newItem.controller.selection =
          TextSelection.fromPosition(TextPosition(
            affinity: TextAffinity.downstream,
            offset: 1,
          ));
      newItem.indent = indent;
      newItem.canChanged = false;
      setState(() {
        widget.richSource.richLineList.insert(index + 1, newItem);
      });
      Future.delayed(const Duration(milliseconds: 100),(){
        _requestFocus(newItem?.focusNode);
      });
    }
  }

  Widget _buildTextField(int index, TextStyle effectiveSytle) {
    var item = widget.richSource.richLineList[index] as RichItem;
    assert(item.controller != null);
    assert(item.focusNode != null);
    return TextField(
      key: item.textkey,
      focusNode: item.focusNode,
      controller: item.controller,
      maxLines: null,
      inputFormatters: [
        LengthLimitingTextInputFormatter(300),
      ],
      style: effectiveSytle.merge(TextStyle(locale: const Locale('zh', 'CH'))),
      autofocus: true,
      textAlign: TextAlign.start,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.fromLTRB(0, 3, 0 ,3)
      ),
      onChanged: (text) {

        //debugPrint('触发内容修改事件：$text, 内容长度: ${text.length}');
        //debugPrint('内容长度: ${text.length}');

        if (index == 0 && text.isEmpty) {
          item.canChanged = false;
          item.controller.text = '\u0000';
          item.controller.selection = TextSelection.fromPosition(TextPosition(
            affinity: TextAffinity.downstream,
            offset: 1,
          ));
        } else if (index == 0 && text.substring(0, 1) != '\u0000') {
          item.canChanged = false;
          var temp = item.controller.text.replaceAll('\u0000', '');
          item.controller.text = '\u0000' + temp;
          item.controller.selection = TextSelection.fromPosition(TextPosition(
            affinity: TextAffinity.downstream,
            offset: 1,
          ));
        } else if (text.length == 0 || (text.substring(0, 1) != '\u0000')) {
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
      bodyItems.add(InkWell(
        child: buildLineLayoutWidget(index),
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap(RichNoteTapObject(
                index, widget.richSource.richLineList[index]));
          }
        },
        onLongPress: () {
          if (widget.onLongTap != null) {
            widget.onLongTap(RichNoteTapObject(
                index, widget.richSource.richLineList[index]));
          }
        },
      ));
      if (index < listLength - 1) bodyItems.add(buildSeparatorWidget(index));
    }
    return bodyItems;
  }

  Widget _buildFormatIconsBar() {
    return ListView(
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
              if (item.indent < widget._maxIndent) {
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
          icon: Icon(Icons.aspect_ratio),
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
    );
  }

  void editLabels(LabelType type) {
    String title;
    List<ReferencesBoxItem> labels;
    LabelKeys labelKeys;
    Map<int, String> titleMap = Map<int, String>();
    String clipText = '';

    RichItem item = _getCurrentRichItem();
    var currentFocusNode = item.focusNode;
    int p = item.controller.selection.start;

    switch (type) {
      case LabelType.Person:
        title = '人物';
        labels = widget.store.personSet.itemList;
        labelKeys = widget.focusEvent.personKeys;
        break;
      case LabelType.Place:
        title = '位置';
        labels = widget.store.placeSet.itemList;
        labelKeys = widget.focusEvent.placeKeys;
        break;
      case LabelType.Tag:
        title = '标签';
        labels = widget.store.tagSet.itemList;
        labelKeys = widget.focusEvent.tagKeys;
        break;
    }
    bool offstageAddButton = true;
    List<ReferencesBoxItem> resultList = [];
    resultList.addAll(labels);
    TextEditingController controller = TextEditingController();
    String newLabel;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        double width = MediaQuery.of(context).size.width * 0.85;
        double height = MediaQuery.of(context).size.height * 0.5;
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                children: <Widget>[
                  Container(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextField(
                              controller: controller,
                              //autofocus: true,
                              decoration: InputDecoration(
                                icon: Icon(Icons.search),
                                hintText: '点击此处搜索或加入新的$title',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.fromLTRB(0, 3, 0, 3)
                              ),
                              onChanged: (text){
                                if (text.isEmpty) {
                                  setDialogState((){
                                    resultList.clear();
                                    resultList.addAll(labels);
                                    offstageAddButton = true;
                                  });
                                } else {
                                  resultList.clear();
                                  labels.forEach((label){
                                    if (label.getLabel().contains(controller.text)) {
                                      resultList.add(label);
                                    }
                                  });
                                  setDialogState((){
                                    if (resultList.isEmpty) {
                                      offstageAddButton = false;
                                      newLabel = text;
                                    } else {
                                      offstageAddButton = true;
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        Offstage(
                          offstage: offstageAddButton,
                          child: IconButton(
                            icon: Icon(Icons.clear),
                            color: Theme.of(context).accentColor,
                            onPressed: () {
                              controller.clear();
                              setDialogState((){
                                resultList.clear();
                                resultList.addAll(labels);
                                offstageAddButton = true;
                              });
                            },
                          ),
                        ),
                        Offstage(
                          offstage: offstageAddButton,
                          child: IconButton(
                            icon: Icon(Icons.add),
                            color: Theme.of(context).accentColor,
                            onPressed: (){
                              controller.clear();
                              resultList.clear();
                              resultList.addAll(labels);
                              offstageAddButton = true;
                              if (type == LabelType.Person) {
                                PersonItem person = PersonItem(name: newLabel);
                                widget.store.personSet.addItem(person).then((id){
                                  titleMap[id] = person.name;
                                  setDialogState((){
                                    resultList.add(person);
                                    clipText = StringExt.listStringToString(titleMap.values.toList());
                                  });
                                });
                              } else if (type == LabelType.Place) {
                                PlaceItem place = PlaceItem(title: newLabel);
                                widget.store.placeSet.addItem(place).then((id){
                                  titleMap[id] = place.title;
                                  setDialogState((){
                                    //resultList.clear();
                                    //resultList.addAll(labels);
                                    resultList.add(place);
                                    clipText = StringExt.listStringToString(titleMap.values.toList());
                                  });
                                });
                              } else {
                                TagItem tag = TagItem(title: newLabel);
                                widget.store.tagSet.addItem(tag).then((id){
                                  setDialogState((){
                                    resultList.add(tag);
                                    labelKeys.addOrRemove(tag.boxId);
                                  });
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5.0
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: width,
                      height: height,
                      child: ListView.builder(
                        itemCount: resultList.length,
                        itemBuilder: (context, index) {
                          var item = resultList[index];
                          bool isSelected = labelKeys.findKey(item.boxId);
                          String labelText = resultList[index].getLabel();
                          CatListTile catListTile;
                          if (type != LabelType.Tag) {
                            catListTile = CatListTile(
                              title: Text(labelText),
                              selected: isSelected,
                              onTap: (){
                                if (titleMap.containsKey(item.boxId)) {
                                  titleMap.remove(item.boxId);
                                } else {
                                  titleMap[item.boxId] = labelText;
                                }
                                setDialogState((){
                                  clipText = StringExt.listStringToString(titleMap.values.toList());
                                });
                              },
                            );
                          } else {
                            catListTile = CatListTile(
                              leading: SizedBox(
                                height: 32,
                                width: 32,
                                child: Checkbox(
                                  value: isSelected,
                                  onChanged: (selected) {
                                    setDialogState((){
                                      labelKeys.addOrRemove(item.boxId);
                                      //clipText = StringExt.listIntToString(labelKeys.keyList);
                                    });
                                  },
                                ),
                              ),
                              title: Text(labelText),
                              selected: isSelected,
                              onTap: (){
                                setDialogState((){
                                  labelKeys.addOrRemove(item.boxId);
                                  //clipText = StringExt.listIntToString(labelKeys.keyList);
                                });
                              },
                            );
                          }
                          return catListTile;
                        },
                      ),
                    ),
                  ),
                  Offstage(
                    offstage: type == LabelType.Tag,
                    child: Container(
                      height: 48,
                      width: double.infinity,
                      color: Color.fromARGB(127, 245, 245, 245),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(16, 6, 6, 6),
                              child: Text(clipText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.input),
                            color: Theme.of(context).accentColor,
                            onPressed: (){
                              Navigator.of(context).pop(clipText);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 1,),
                ],
              );
            }
          ),
          actions: <Widget>[
//            Offstage(
//              offstage: type == LabelType.Tag,
//              child: FlatButton(
//                child: Text('返回'),
//                onPressed: () {
//                  Navigator.of(context).pop(null);
//                },
//              ),
//            ),
            FlatButton(
              child: Text('返回'),//type == LabelType.Tag ? Text('返回') : Text('插入'),
              onPressed: () {
                //Navigator.of(context).pop(clipText);
                Navigator.of(context).pop(null);
              },
            ),
          ],
        );
      }
    ).then((result) {
      if (result != null) {
        if (type == LabelType.Tag) {
          debugPrint('确认了（${widget.focusEvent.tagKeys.keyList.length}）个标签');
        } else {
          if (currentFocusNode != null) {
            String clipText = result;
            String clearText = item.controller.text.replaceAll('\u0000', '');
            String before = clearText.substring(0, p - 1);
            String after = clearText.substring(p - 1);
            String newText = '\u0000' + before + clipText + after;
            item.canChanged = false;
            item.controller.text = newText;
            FocusScope.of(context).requestFocus(currentFocusNode);
            item.controller.selection = TextSelection.fromPosition(TextPosition(
              affinity: TextAffinity.downstream,
              offset: p + clipText.length,
            ));
          } else {
            Clipboard.setData(new ClipboardData(text: result));
          }
        }
      }
    });
  }


  Widget _buildLabelIconsBar() {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.people),
          onPressed: (){
            editLabels(LabelType.Person);
          },
        ),
        IconButton(
          icon: Icon(Icons.place),
          onPressed: (){
            editLabels(LabelType.Place);
          },
        ),
        IconButton(
          icon: Icon(Icons.label),
          onPressed: (){
            editLabels(LabelType.Tag);
          },
        ),
      ],
    );
  }

  Widget _getIconsBar() {
    Widget bar;
    if (barType == BarType.FormatBar) {
      bar = Row(
        children: <Widget>[
          Expanded(
            child: _buildFormatIconsBar(),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  offset: Offset(-8, 0),
                  color: Colors.black54,
                  spreadRadius: -8,
                  blurRadius: 5.0,
                ),
              ]
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: (){
                setState(() {
                  barType = BarType.LabelBar;
                });
              },
            ),
          ),
        ],
      );
    } else {
      bar = Row(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    offset: Offset(8, 0),
                    color: Colors.black54,
                    spreadRadius: -8,
                    blurRadius: 5.0,
                  ),
                ]
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: (){
                setState(() {
                  barType = BarType.FormatBar;
                });
              },
            ),
          ),
          Expanded(
            child: _buildLabelIconsBar(),
          ),
        ],
      );
    }
    return bar;
  }

  List<Widget> _buildBody() {
    List<Widget> bodyItems = [];
    bodyItems.add(Expanded(
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: InkWell(
              child: buildLineLayoutWidget(index),
              onTap: () {
                if (widget.onTap != null) {
                  widget.onTap(RichNoteTapObject(
                      index, widget.richSource.richLineList[index]));
                }
              },
              onLongPress: () {
                if (widget.onLongTap != null) {
                  widget.onLongTap(RichNoteTapObject(
                      index, widget.richSource.richLineList[index]));
                }
              },
            ),
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
          child: _getIconsBar(),
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

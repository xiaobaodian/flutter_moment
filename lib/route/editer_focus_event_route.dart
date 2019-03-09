import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/models/models.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_data.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_widget.dart';

class EditerFocusEventRoute extends StatefulWidget {

  final FocusEvent _focusEvent;

  EditerFocusEventRoute(this._focusEvent);

  @override
  EditerFocusEventRouteState createState() => EditerFocusEventRouteState();
}

class EditerFocusEventRouteState extends State<EditerFocusEventRoute> {
  //final focusEventController = TextEditingController();
  String routeTitle;
  RichSource richSource;
  RichNote richNote;

  @override
  void initState() {
    super.initState();
    //focusEventController.text = widget._focusEvent.note;
    //richSource = RichSource.fromJson(widget._focusEvent.note);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var store = GlobalStore.of(context);
    routeTitle = store.getFocusTitleFrom(widget._focusEvent.focusItemBoxId);
    richSource = RichSource(widget._focusEvent.noteLines);
    richNote = RichNote.editable(
      richSource: richSource,
      store: store,
    );
  }

  @override
  void dispose() {
    super.dispose();
    //focusEventController.dispose();
    richSource.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('生成编辑窗');
    return Scaffold(
      appBar: AppBar(
        title: Text('今日$routeTitle'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: (){
              // 删除数据时传入任意一个整数（这里是-1），前一个页面收到返回之后判断一下
              // 类型，如果是整数型就执行删除。
              Navigator.of(context).pop(-1);
            },
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: (){
              if (richSource.hasNote()) {
                FocusEvent focus = FocusEvent();
                focus.copyWith(widget._focusEvent);
                focus.noteLines = richSource.exportingRichLists();
                //focus.note = richSource.getJsonFromParagraphList();
                Navigator.of(context).pop(focus);
              } else {
                Navigator.of(context).pop(null);
              }
            },
          ),
        ],
      ),
      body: richNote,
    );
  }

}
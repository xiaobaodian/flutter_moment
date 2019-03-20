import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/models/models.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_data.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_widget.dart';
import 'package:flutter_moment/widgets/cccat_list_tile.dart';

class EditerFocusEventRoute extends StatefulWidget {
  final FocusEvent _focusEvent;

  EditerFocusEventRoute(this._focusEvent);

  @override
  EditerFocusEventRouteState createState() => EditerFocusEventRouteState();
}

class EditerFocusEventRouteState extends State<EditerFocusEventRoute> {
  //final focusEventController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String routeTitle;
  RichSource richSource;
  RichNote richNote;
  String dateTitle;

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
    routeTitle = store.getFocusTitleBy(widget._focusEvent.focusItemBoxId);
    dateTitle = store.calendarMap.getChineseTermOfDate(widget._focusEvent.dayIndex);
    richSource = RichSource(widget._focusEvent.noteLines,
      focusItemBoxId: widget._focusEvent.focusItemBoxId,
      dayIndex: widget._focusEvent.dayIndex,
    );
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

  void openEndDrawer() {
    //_scaffoldKey.currentState.openEndDrawer();
//    _scaffoldKey.currentState.showSnackBar(
//        SnackBar(
//          content: Text('hello'),
//          backgroundColor: Colors.yellow,
//        )
//    );
    print('q = w');
    Builder(
      builder: (BuildContext context) {
        var q = Scaffold.of(context);
        var w = _scaffoldKey.currentState;
        print('q = w ?');
        print('q = w ? => ${q==w}');
      },
    );
    //Scaffold.of(context).openEndDrawer();
  }

  void removeFocusEventItem(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('将要删除'),
            content: Text('确实需要删除 <$routeTitle> 吗？'),
            actions: <Widget>[
              FlatButton(
                child: Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
              ),
              FlatButton(
                child: Text('确认'),
                onPressed: () {
                  Navigator.of(context).pop(1);
                },
              ),
            ],
          );
        }
    ).then((result) {
      if (result != null) {
        // 删除数据时传入任意一个整数（这里是-1），前一个页面收到返回之后判断一下
        // 类型，如果是整数型就执行删除。
        Navigator.of(context).pop(-1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('生成编辑窗');
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(routeTitle),
            Text(dateTitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white54,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.place),
            onPressed: () {
              _scaffoldKey.currentState.openEndDrawer();
//              Builder(
//                builder: (BuildContext context) {
//                  Scaffold.of(context).openEndDrawer();
//                },
//              );
            },
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              if (richSource.hasNote()) {
                FocusEvent focus = FocusEvent();
                focus.copyWith(widget._focusEvent);
                focus.noteLines = richSource.exportingRichLists();
                //focus.note = richSource.getJsonFromParagraphList();
                PassingObject<FocusEvent> focusEventPassingObject = PassingObject(
                  oldObject: widget._focusEvent,
                  newObject: focus,
                );
                Navigator.of(context).pop(focusEventPassingObject);
              } else {
                Navigator.of(context).pop(-1);
              }
            },
          ),
          PopupMenuButton(
            onSelected: (int v){
              if (v == 1) {
                removeFocusEventItem(context);
              } else if (v == 2) {
                openEndDrawer();
              }
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<int>>[
                PopupMenuItem(
                  value: 1,
                  //enabled: !_hideEditButton,
                  child: CatListTile(
                    leading: Icon(Icons.delete),
                    leadingSpace: 24,
                    contentPadding: EdgeInsets.fromLTRB(8, 8, 0, 8),
                    title: Text('删除'),
                  ),
                ),
                PopupMenuDivider(height: 1),
                PopupMenuItem(
                  value: 2,
                  //enabled: !_hideDeleteButton,
                  child: CatListTile(
                    leading: Icon(Icons.people),
                    leadingSpace: 24,
                    contentPadding: EdgeInsets.fromLTRB(8, 8, 0, 8),
                    title: Text(''),
                    trailText: Text('2'),
                  ),
                ),
                PopupMenuDivider(height: 1),
                PopupMenuItem(
                  value: 3,
                  //enabled: !_hideDeleteButton,
                  child: CatListTile(
                    leading: Icon(Icons.place),
                    leadingSpace: 24,
                    contentPadding: EdgeInsets.fromLTRB(8, 8, 0, 8),
                    title: Text(''),
                    trailText: Text('2'),
                  ),
                ),
                PopupMenuDivider(height: 1),
                PopupMenuItem(
                  value: 4,
                  //enabled: !_hideDeleteButton,
                  child: CatListTile(
                    leading: Icon(Icons.label),
                    leadingSpace: 24,
                    contentPadding: EdgeInsets.fromLTRB(8, 8, 0, 8),
                    title: Text(''),
                    trailText: Text('2'),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: richNote,
      endDrawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text('ksdkjshdjksds'),
            ),
            ListTile(
              title: Text('ksdkjshdjksds'),
            ),
            ListTile(
              title: Text('ksdkjshdjksds'),
            ),
            ListTile(
              title: Text('ksdkjshdjksds'),
            ),
          ],
        ),
      ),
    );
  }
}

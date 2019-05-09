import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/models/models.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_data.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_widget.dart';
import 'package:flutter_moment/widgets/cccat_list_tile.dart';

class EditerFocusEventRoute extends StatefulWidget {
  EditerFocusEventRoute(this.store, this._focusEvent);

  final FocusEvent _focusEvent;
  final GlobalStoreState store;

  @override
  EditerFocusEventRouteState createState() => EditerFocusEventRouteState();
}

class EditerFocusEventRouteState extends State<EditerFocusEventRoute> {
  //final focusEventController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RichNoteState> _richNoteKey = GlobalKey<RichNoteState>();
  //GlobalStoreState _store;
  FocusEvent _editerFocusEvent = FocusEvent();
  String _routeTitle;
  String _dateTitle;
  RichSource richSource;
  RichNote richNote;

  @override
  void initState() {
    super.initState();
    _editerFocusEvent.copyWith(widget._focusEvent);
    richSource = RichSource.fromFocusEvent(_editerFocusEvent);
    richNote = RichNote.editable(
      key: _richNoteKey,
      richSource: richSource,
      store: widget.store,
    );
    _routeTitle = widget.store.getFocusTitleBy(widget._focusEvent.focusItemBoxId);
    _dateTitle = widget.store.calendarMap.getChineseTermOfDate(widget._focusEvent.dayIndex);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
//    _store = GlobalStore.of(context);
//    _routeTitle = _store.getFocusTitleBy(widget._focusEvent.focusItemBoxId);
//    _dateTitle = _store.calendarMap.getChineseTermOfDate(widget._focusEvent.dayIndex);
    //_editerFocusEvent.copyWith(widget._focusEvent);
    //richSource = RichSource.fromFocusEvent(_editerFocusEvent);
//    richNote = RichNote.editable(
//      key: _richNoteKey,
//      richSource: richSource,
//      store: _store,
//    );
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

  Future saveFocusEventItem() async {
    /// 首先判断编辑器里面有没有内容
    if (richSource.hasNote()) {
      _editerFocusEvent.noteLines = richNote.exportingRichLists();
      /// 如果编辑器里面只有一个准备转移其他日期的任务，导出到noteLines后，noteLines
      /// 就为空，这是就应该删除该focusEvent
      if (_editerFocusEvent.noteLines.isNotEmpty) {
        if (_editerFocusEvent.boxId == 0) {
          widget.store.addFocusEventToSelectedDay(_editerFocusEvent);
        } else {
          PassingObject<FocusEvent> passingObject = PassingObject(
            oldObject: widget._focusEvent,
            newObject: _editerFocusEvent,
          );
          widget.store.changeFocusEventAndTasks(passingObject);
          widget._focusEvent.copyWith(_editerFocusEvent);
        }
        return ;
      }
      widget._focusEvent.copyWith(_editerFocusEvent);
    }
    /// [richSource.hasNote()]为false时，表明内容为空，执行下面部分。
    /// [widget._focusEvent.boxId] > 0 是原来存在的focusEvent，当用户删除所有内
    /// 容后执行保存动作，说明用户需要删除。[widget._focusEvent.boxId] = 0 时，说
    /// 明是刚刚新建的focusEvent，没有内容就退出就是放弃的新建，不需要执行删除。
    if (widget._focusEvent.boxId > 0) {
      await widget.store.removeFocusEventAndTasks(widget._focusEvent);
    }
  }

  void removeFocusEventItem(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('将要删除'),
          content: Text('确实需要删除 <$_routeTitle> 吗？'),
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
                widget.store.removeFocusEventAndTasks(widget._focusEvent);
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
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('生成编辑窗');

    return WillPopScope(
      onWillPop: () async {
        if (widget.store.prefs.autoSave) {
          saveFocusEventItem();
        } else {
          widget.store.checkDailyRecord();
        }
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(_routeTitle),
              Text(_dateTitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: widget.store.prefs.autoSave ? Icon(Icons.cancel) : Icon(Icons.save),
              onPressed: () {
                if (widget.store.prefs.autoSave) {
                  Navigator.of(context).pop(-1);
                  widget.store.checkDailyRecord();
                } else {
                  saveFocusEventItem();
                  Navigator.of(context).pop();
                }
//                if (richSource.hasNote()) {
//                  //FocusEvent newFocusEvent = richSource.focusEvent;
//                  // 原来是下面的方法，但是当新建一个focusEvent进来编辑时，执行到这里
//                  // richNote.focusEvent != richNote.focusEvent，但是如果是编辑一个
//                  // focusEvent时，这里的richNote.focusEvent == richNote.focusEvent
//                  // 具体原因以后排查。
//                  // newFocusEvent.copyWith(widget._focusEvent);
//                  //newFocusEvent.copyWith(richNote.focusEvent);
//                  _editerFocusEvent.noteLines = richSource.exportingRichLists();
//                  PassingObject<FocusEvent> focusEventPassingObject = PassingObject(
//                    oldObject: widget._focusEvent,
//                    newObject: _editerFocusEvent,
//                  );
//                  Navigator.of(context).pop(focusEventPassingObject);
//                } else {
//                  Navigator.of(context).pop(-1);
//                }
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
                    height: 64,
                    child: CatListTile(
                      leading: Icon(Icons.delete),
                      leadingSpace: 24,
                      contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      title: Text('删除'),
                    ),
                  ),
                  PopupMenuDivider(height: 1),
                  PopupMenuItem(
                    value: 2,
                    //enabled: !_hideEditButton,
                    height: 64,
                    child: CatListTile(
                      leading: Icon(Icons.add_to_home_screen),
                      leadingSpace: 24,
                      contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      title: Text('移动'),
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
      ),
    );
  }
}

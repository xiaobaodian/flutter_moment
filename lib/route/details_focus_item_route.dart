import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moment/calendar_tools.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/models/models.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_data.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_widget.dart';
import 'package:flutter_moment/route/editer_focus_event_route.dart';
import 'package:flutter_moment/route/editer_focus_item_route.dart';
import 'package:flutter_moment/widgets/cccat_list_tile.dart';

class FocusItemDetailsRoute extends StatefulWidget {
  final FocusItem _focusItem;

  FocusItemDetailsRoute(this._focusItem);

  @override
  FocusItemDetailsRouteState createState() => FocusItemDetailsRouteState();
}

class FocusItemDetailsRouteState extends State<FocusItemDetailsRoute> {
  GlobalStoreState _store;
  bool _hideEditButton, _hideDeleteButton;

  @override
  void initState() {
    super.initState();
    _hideEditButton = widget._focusItem.systemPresets ? true : false;
    _hideDeleteButton = widget._focusItem.systemPresets || widget._focusItem.isNotReferences ? true : false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = GlobalStore.of(context);
    widget._focusItem.detailsList = _store.getFocusEventsFromFocusItemId(widget._focusItem.boxId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void editFocusItem(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
      return EditerFocusItemRoute(widget._focusItem);
    })).then((resultItem){
      if (resultItem != null) {
        if (resultItem is int) {
          Navigator.of(context).pop();
        } else {
          final focusItem = resultItem as FocusItem;
          // focusItem是编辑路由新生成的实例，只携带了修改的数据，所以必须对widget._focusItem进行修改
          widget._focusItem.title = focusItem.title;
          widget._focusItem.comment = focusItem.comment;
          _store.changeFocusItem(widget._focusItem);
        }
      }
    });
  }

  void removeFocusItem(BuildContext context) {
    debugPrint('focus item boxId: ${widget._focusItem.boxId}');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('将要删除'),
          content: Text('确实需要删除 <${widget._focusItem.title}> 吗？'),
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
        _store.removeFocusItem(widget._focusItem);
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget._focusItem.title}'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.description),
            onPressed: (){
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context){
                  return SimpleDialog(
                    contentPadding: EdgeInsets.all(16),
                    children: <Widget>[
                      Text('${widget._focusItem.title} 说明'),
                      Divider(),
                      Text(widget._focusItem.comment),
                    ],
                  );
                },
              );
            },
          ),
          PopupMenuButton(
            onSelected: (int v){
              if (v == 1) {
                editFocusItem(context);
              } else if (v == 2) {
                removeFocusItem(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<int>>[
                PopupMenuItem(
                  value: 1,
                  enabled: !_hideEditButton,
                  child: CatListTile(
                    leading: Icon(Icons.edit),
                    leadingSpace: 24,
                    contentPadding: EdgeInsets.fromLTRB(8, 8, 0, 8),
                    title: Text('编辑'),
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  enabled: !_hideDeleteButton,
                  child: CatListTile(
                    leading: Icon(Icons.delete),
                    leadingSpace: 24,
                    contentPadding: EdgeInsets.fromLTRB(8, 8, 0, 8),
                    title: Text('删除'),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: buildBody(context, _store),
    );
  }

  Widget buildBody(BuildContext context, GlobalStoreState store) {
    final detailsList = widget._focusItem.detailsList;
    if (detailsList.isEmpty) {
      return Center(child: Text('还没有记录'));
    }
    return ListView.builder(
      itemCount: detailsList.length,
      itemBuilder: (context, index){
        debugPrint('生成卡片: $index');
        final date = store.calendarMap.getDateFromIndex(detailsList[index].dayIndex);
        final str = DateTimeExt.chineseDateString(date);
        Widget content = RichNote.fixed(
          richSource: RichSource.fromJson(detailsList[index].note),
        );
        return Card(
          margin: EdgeInsets.all(6),
          child: InkWell(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,0,0,8),
                    child: Text(str,
                      style: TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: content,
                  ),
                  //Text(detailsList[index].note),
                ],
              ),
            ),
            onTap: (){
              FocusEvent event = detailsList[index];
              var dailyRecord = store.getDailyRecord(event.dayIndex);
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return EditerFocusEventRoute(event);
              })).then((resultItem) {
                if (resultItem is FocusEvent) {
                  dailyRecord.richLines.clear();
                  event.copyWith(resultItem);
                  store.changeFocusEvent(event);
                } else if (resultItem is int) {
                  dailyRecord
                    ..richLines.clear()
                    ..focusEvents.remove(event);
                  store.removeFocusEvent(event);
                }
              });
            },
          ),
        );
      },
    );
  }

}
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moment/calendar_tools.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/models/enums.dart';
import 'package:flutter_moment/models/helper_file.dart';
import 'package:flutter_moment/models/models.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_data.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_widget.dart';
import 'package:flutter_moment/route/editer_focus_event_route.dart';
import 'package:flutter_moment/route/editer_focus_item_route.dart';
import 'package:flutter_moment/route/editer_person_item_route.dart';
import 'package:flutter_moment/route/editer_place_item_route.dart';
import 'package:flutter_moment/route/editer_tage_item_route.dart';

class TagItemDetailsRoute extends StatefulWidget {
  final TagItem _tagItem;

  TagItemDetailsRoute(this._tagItem);

  @override
  TagItemDetailsRouteState createState() => TagItemDetailsRouteState();
}

class TagItemDetailsRouteState extends State<TagItemDetailsRoute> {
  GlobalStoreState _store;
  bool _hideDeleteButton;

  @override
  void initState() {
    super.initState();
    _hideDeleteButton = widget._tagItem.isNotReferences ? true : false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = GlobalStore.of(context);
    widget._tagItem.detailsList =
        _store.getFocusEventsFromTagItemId(widget._tagItem.boxId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void removeTagItem(BuildContext context) {
    debugPrint('TagItem BoxId: ${widget._tagItem.boxId}');
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('将要删除'),
            content: Text('确实需要删除 <${widget._tagItem.title}> 吗？'),
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
        }).then((result) {
      if (result != null) {
        Navigator.of(context).pop();
        _store.tagSet.removeItem(widget._tagItem);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._tagItem.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return EditerTagItemRoute(widget._tagItem);
              })).then((resultItem) {
                if (resultItem is TagItem) {
                  widget._tagItem.copyWith(resultItem);
                  _store.tagSet.changeItem(widget._tagItem);
                }
              });
            },
          ),
          Offstage(
            offstage: _hideDeleteButton,
            child: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                removeTagItem(context);
              },
            ),
          ),
        ],
      ),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    final detailsList = widget._tagItem.detailsList;
    if (detailsList.isEmpty) {
      return Center(child: Text('还没有记录'));
    }
    return ListView.separated(
      itemCount: detailsList.length,
      itemBuilder: (context, index) {
        final date =
            _store.calendarMap.getDateFromIndex(detailsList[index].dayIndex);
        final str = DateTimeExt.chineseDateString(date);
        Widget content = RichNote.fixed(
          store: _store,
          richSource: RichSource(detailsList[index].noteLines),
          onTap: (tapObject) {
            var richLine = tapObject.richLine;
            FocusEvent event = richLine.note;
            DailyRecord dailyRecord = _store.getDailyRecord(event.dayIndex);
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (BuildContext context) {
              return EditerFocusEventRoute(event);
            })).then((resultItem) {
              if (resultItem is PassingObject<FocusEvent>) {
                dailyRecord.richLines.clear();
                Future(() {
                  _store.changeFocusEventAndTasks(resultItem);
                }).then((_) {
                  event.copyWith(resultItem.newObject);
                });
              } else if (resultItem is int) {
                dailyRecord.richLines.clear();
                _store.removeFocusEventAndTasks(event);
              }
            });
          },
        );
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                child: Text(
                  str,
                  style: TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: content,
              ),
              //Text(detailsList[index].note),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) {
        return Divider(
          height: 1,
        );
      },
    );
  }
}

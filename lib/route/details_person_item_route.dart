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

class PersonItemDetailsRoute extends StatefulWidget {

  final PersonItem _personItem;

  PersonItemDetailsRoute(this._personItem);

  @override
  PersonItemDetailsRouteState createState() => PersonItemDetailsRouteState();
}

class PersonItemDetailsRouteState extends State<PersonItemDetailsRoute> {
  GlobalStoreState _store;
  bool _hideDeleteButton;

  @override
  void initState() {
    super.initState();
    _hideDeleteButton = widget._personItem.isNotReferences ? true : false;
  }

  @override
  void didChangeDependencies() {  //getFocusEventsFromPersonItemId
    super.didChangeDependencies();
    _store = GlobalStore.of(context);
    widget._personItem.detailsList = _store.getFocusEventsFromPersonItemId(widget._personItem.boxId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void removePersonItem(BuildContext context) {
    debugPrint('PersonItem BoxId: ${widget._personItem.boxId}');
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('将要删除'),
            content: Text('确实需要删除 <${widget._personItem.name}> 吗？'),
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
        _store.removePersonItem(widget._personItem);
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            SizedBox(
              width: 32,
              height: 32,
              child: CircleAvatar(
                backgroundImage: widget._personItem.getImage(mode: EImageMode.Light).image,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16,0,0,0),
              child: Text(widget._personItem.name),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                return EditerPersonItemRoute(widget._personItem);
              })).then((resultItem){
                if (resultItem is PersonItem) {
                  String oldName = widget._personItem.name;
                  String newName = resultItem.name;
                  if (oldName != newName) {
                    print('person name is change');
                    for (var event in widget._personItem.detailsList) {
                      for (var line in event.noteLines) {
                        String dec = line.getContent().replaceAll(oldName, newName);
                        line.setContent(dec);
                      }
                      _store.changeFocusEventAndTasks(PassingObject(newObject: event));
                    }
                  }
                  widget._personItem.copyWith(resultItem);
                  _store.changePersonItem(widget._personItem);
                  //_platformDataSource.invokeMethod("PutPersonItem", json.encode(widget._personItem));
                }
              });
            },
          ),
          Offstage(
            offstage: _hideDeleteButton,
            child: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                removePersonItem(context);
              },
            ),
          ),
        ],
      ),
      body: buildBody(context, _store),
    );
  }

  Widget buildBody(BuildContext context, GlobalStoreState store) {
    //var dailyRecord = store.calendarMap.getDailyRecordFromIndex(dayIndex);
    final detailsList = widget._personItem.detailsList;
    if (detailsList.isEmpty) {
      return Center(child: Text('还没有记录'));
    }
    return ListView.separated(
      itemCount: detailsList.length,
      itemBuilder: (context, index){
        final date = store.calendarMap.getDateFromIndex(detailsList[index].dayIndex);
        final str = DateTimeExt.chineseDateString(date);
        Widget content = RichNote.fixed(
          store: _store,
          richSource: RichSource(detailsList[index].noteLines),
          onTapLine: (tapObject) {
            var richLine = tapObject.richLine;
            FocusEvent event = richLine.note;
            //FocusEvent event = detailsList[index];
            DailyRecord dailyRecord = store.getDailyRecord(event.dayIndex);
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (BuildContext context) {
              return EditerFocusEventRoute(event);
            })).then((resultItem) {
              if (resultItem is PassingObject<FocusEvent>) {
                dailyRecord.richLines.clear();
                Future(() {
                  store.changeFocusEventAndTasks(resultItem);
                }).then((_) {
                  event.copyWith(resultItem.newObject);
                });
              } else if (resultItem is int) {
                dailyRecord.richLines.clear();
                store.removeFocusEventAndTasks(event);
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
                padding: const EdgeInsets.fromLTRB(0,0,0,8),
                child: Text(str,
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
      separatorBuilder: (context, index){
        return Divider(height: 1,);
      },
    );
  }

}
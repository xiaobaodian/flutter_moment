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

class PlaceItemDetailsRoute extends StatefulWidget {
  final PlaceItem _placeItem;

  PlaceItemDetailsRoute(this._placeItem);

  @override
  PlaceItemDetailsRouteState createState() => PlaceItemDetailsRouteState();
}

class PlaceItemDetailsRouteState extends State<PlaceItemDetailsRoute> {
  GlobalStoreState _store;
  bool _hideDeleteButton;

  @override
  void initState() {
    super.initState();
    _hideDeleteButton = widget._placeItem.isNotReferences ? true : false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = GlobalStore.of(context);
    widget._placeItem.detailsList =
        _store.getFocusEventsFromPlaceItemId(widget._placeItem.boxId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void removePlaceItem(BuildContext context) {
    debugPrint('PlaceItem BoxId: ${widget._placeItem.boxId}');
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('将要删除'),
            content: Text('确实需要删除 <${widget._placeItem.title}> 吗？'),
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
        _store.placeSet.removeItem(widget._placeItem);
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
                backgroundImage:
                    widget._placeItem.getImage(mode: EImageMode.Light).image,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
              child: Text(widget._placeItem.title),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return EditerPlaceItemRoute(widget._placeItem);
              })).then((resultItem) {
                if (resultItem is PlaceItem) {
                  String oldTitle = widget._placeItem.title;
                  String newTitle = resultItem.title;
                  if (oldTitle != newTitle) {
                    print('place title is change');
                    for (var event in widget._placeItem.detailsList) {
                      for (var line in event.noteLines) {
                        print('line content: ${line.getContent()}');
                        if (line.type == RichType.Task)
                          print('line is task type');
                        String dec =
                            line.getContent().replaceAll(oldTitle, newTitle);
                        line.setContent(dec);
                      }
                      _store.changeFocusEventAndTasks(
                          PassingObject(newObject: event));
                    }
                  }
                  widget._placeItem.copyWith(resultItem);
                  _store.placeSet.changeItem(widget._placeItem);
                }
              });
            },
          ),
          Offstage(
            offstage: _hideDeleteButton,
            child: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                removePlaceItem(context);
              },
            ),
          ),
        ],
      ),
      body: buildBody(context, _store),
    );
  }

  Widget buildBody(BuildContext context, GlobalStoreState store) {
    final detailsList = widget._placeItem.detailsList;
    if (detailsList.isEmpty) {
      return Center(child: Text('还没有记录'));
    }
    return ListView.separated(
      itemCount: detailsList.length,
      itemBuilder: (context, index) {
        final date =
            store.calendarMap.getDateFromIndex(detailsList[index].dayIndex);
        final str = DateTimeExt.chineseDateString(date);
        Widget content = RichNote.fixed(
          store: _store,
          richSource: RichSource(detailsList[index].noteLines),
          onTap: (tapObject) {
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

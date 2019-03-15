import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/models/enums.dart';
import 'package:flutter_moment/models/helper_file.dart';
import 'package:flutter_moment/models/models.dart';
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
  static const _platformDataSource = const MethodChannel('DataSource');
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
        }
    ).then((result) {
      if (result != null) {
        //_store.removePlaceItem(widget._placeItem);
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
                backgroundImage: widget._placeItem.getImage(mode: EImageMode.Light).image,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16,0,0,0),
              child: Text(widget._placeItem.title),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                return EditerPlaceItemRoute(widget._placeItem);
              })).then((resultItem){
                if (resultItem is PlaceItem) {
                  widget._placeItem.copyWith(resultItem);
                  _platformDataSource.invokeMethod("PutPlaceItem", json.encode(widget._placeItem));
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
      body: ListView(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,0,0,8),
                    child: Text('2019/1/18',
                      style: TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                  ),
                  Text('这里是内容提要，这里是内容提要，这里是内容提要，这里是内容提要，这里是内容提要'),
                ],
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,0,0,8),
                    child: Text('2019/1/18',
                      style: TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                  ),
                  Text('这里是内容提要，这里是内容提要，这里是内容提要，这里是内容提要，这里是内容提要'),
                ],
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,0,0,8),
                    child: Text('2019/1/18',
                      style: TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                  ),
                  Text('这里是内容提要，这里是内容提要，这里是内容提要，这里是内容提要，这里是内容提要'),
                ],
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,0,0,8),
                    child: Text('2019/1/18',
                      style: TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                  ),
                  Text('这里是内容提要，这里是内容提要，这里是内容提要，这里是内容提要，这里是内容提要'),
                ],
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,0,0,8),
                    child: Text('2019/1/18',
                      style: TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                  ),
                  Text('这里是内容提要，这里是内容提要，这里是内容提要，这里是内容提要，这里是内容提要'),
                ],
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,0,0,8),
                    child: Text('2019/1/18',
                      style: TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                  ),
                  Text('这里是内容提要，这里是内容提要，这里是内容提要，这里是内容提要，这里是内容提要'),
                ],
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,0,0,8),
                    child: Text('2019/1/18',
                      style: TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                  ),
                  Text('这里是内容提要，这里是内容提要，这里是内容提要，这里是内容提要，这里是内容提要'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
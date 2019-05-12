import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moment/models/models.dart';

class EditerFocusItemRoute extends StatefulWidget {

  final FocusItem _focusItem;

  EditerFocusItemRoute(this._focusItem);

  @override
  EditerFocusItemRouteState createState() => EditerFocusItemRouteState();
}

class EditerFocusItemRouteState extends State<EditerFocusItemRoute> {
  final focusController = TextEditingController();
  final commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    focusController.text = widget._focusItem.title;
    commentController.text = widget._focusItem.comment;
  }

  @override
  void dispose() {
    super.dispose();
    focusController.dispose();
    commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String routeTitle = widget._focusItem.title.length == 0 ? '新增焦点' : '编辑焦点';
    return Scaffold(
      appBar: AppBar(
        title: Text(routeTitle),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: (){
              if (focusController.text.length > 0) {
                Navigator.of(context).pop(FocusItem(
                  title: focusController.text,
                  comment: commentController.text
                ));
              } else {
                Navigator.of(context).pop(null);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
                child: TextField(
                  controller: focusController,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(
                    color: Colors.black87,
                    fontStyle: FontStyle.normal,
                    fontSize: 16,
                    textBaseline: TextBaseline.ideographic,
                  ),
                  decoration: InputDecoration(
                    //icon: Icon(Icons.adjust),
                    labelText: '焦点',
                  ),
                ),
              ),
              TextField(
                maxLines: null,
                keyboardType: TextInputType.multiline,
                controller: commentController,
                style: TextStyle(
                  color: Colors.black87,
                  fontStyle: FontStyle.normal,
                  fontSize: 16,
                  textBaseline: TextBaseline.ideographic
                ),
                decoration: InputDecoration(
                  //contentPadding: EdgeInsets.fromLTRB(0,3,0,3),
                  //focusedBorder: InputBorder.none,
                  //enabledBorder: InputBorder.none,
                  //icon: Icon(Icons.comment),
                  labelText: '注释',
                  helperText: '这是对焦点的简要描述',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
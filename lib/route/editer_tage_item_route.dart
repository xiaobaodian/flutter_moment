import 'package:flutter/material.dart';
import 'package:flutter_moment/models/models.dart';

class EditerTagItemRoute extends StatefulWidget {

  final TagItem _tagItem;

  EditerTagItemRoute(this._tagItem);

  @override
  EditerTagItemRouteState createState() => EditerTagItemRouteState();
}

class EditerTagItemRouteState extends State<EditerTagItemRoute> {
  final titleController = TextEditingController();
  TagItem newTag = TagItem();

  @override
  void initState() {
    super.initState();
    titleController.text = widget._tagItem.title;
    newTag.copyWith(widget._tagItem);
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String routeTitle = widget._tagItem.hasTitle() ? '编辑标签' : '新增标签';
    TextStyle style = TextStyle(
      color: Colors.black87,
      fontStyle: FontStyle.normal,
      fontSize: 16,
      textBaseline: TextBaseline.ideographic,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(routeTitle),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: (){
              if (titleController.text.length > 0) {
                newTag.title = titleController.text;
                Navigator.of(context).pop(newTag);
              } else {
                Navigator.of(context).pop(null);
              }
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
              child: TextField(
                controller: titleController,
                autofocus: true,
                textInputAction: TextInputAction.next,
                style: style,
                decoration: InputDecoration(
                  //icon: Icon(Icons.adjust),
                  labelText: '标题',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
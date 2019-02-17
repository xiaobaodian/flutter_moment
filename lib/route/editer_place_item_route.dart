import 'package:flutter/material.dart';
import 'package:flutter_moment/models/models.dart';

class EditerPlaceItemRoute extends StatefulWidget {

  final PlaceItem _placeItem;

  EditerPlaceItemRoute(this._placeItem);

  @override
  EditerPlaceItemRouteState createState() => EditerPlaceItemRouteState();
}

class EditerPlaceItemRouteState extends State<EditerPlaceItemRoute> {

  final titleController = TextEditingController();
  final addressController = TextEditingController();
  final addressNode = FocusNode();

  @override
  void initState() {
    super.initState();
    titleController.text = widget._placeItem.title;
    addressController.text = widget._placeItem.address;
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String routeTitle = widget._placeItem.hasTitle() ? '编辑位置' : '新增位置';
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
                Navigator.of(context).pop(PlaceItem(
                  title: titleController.text,
                  address: addressController.text,
                ));
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
                onEditingComplete: (){
                  FocusScope.of(context).requestFocus(addressNode);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
              child: TextField(
                controller: addressController,
                focusNode: addressNode,
                autofocus: true,
                textInputAction: TextInputAction.done,
                style: style,
                decoration: InputDecoration(
                  //icon: Icon(Icons.adjust),
                  labelText: '地址',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/models/models.dart';

class EditerFocusEventRoute extends StatefulWidget {

  final FocusEvent _focusEvent;

  EditerFocusEventRoute(this._focusEvent);

  @override
  EditerFocusEventRouteState createState() => EditerFocusEventRouteState();
}

class EditerFocusEventRouteState extends State<EditerFocusEventRoute> {

  final focusEventController = TextEditingController();
  String routeTitle;

  @override
  void initState() {
    super.initState();
    focusEventController.text = widget._focusEvent.note;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var store = GlobalStore.of(context);
    routeTitle = store.getFocusTitleFrom(widget._focusEvent.focusItemBoxId);
  }

  @override
  void dispose() {
    super.dispose();
    focusEventController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('今日$routeTitle'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: (){
              // 删除数据时传入任意一个整数（这里是-1），前一个页面收到返回之后判断一下
              // 类型，如果是整数型就执行删除。
              Navigator.of(context).pop(-1);
            },
          ),
          IconButton(
            icon: Icon(Icons.done),
            onPressed: (){
              if (focusEventController.text.length > 0) {
                FocusEvent focus = FocusEvent();
                focus.copyWith(widget._focusEvent);
                focus.note = focusEventController.text;
                Navigator.of(context).pop(focus);
              } else {
                Navigator.of(context).pop(null);
              }
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: TextField(
                  maxLines: null,
                  //maxLength: 300,
                  inputFormatters: [ LengthLimitingTextInputFormatter(300), ],
                  controller: focusEventController,
                  autofocus: true,
                  textInputAction: TextInputAction.newline,
                  style: TextStyle(
                    color: Colors.black87,
                    fontStyle: FontStyle.normal,
                    fontSize: 16,
                    textBaseline: TextBaseline.ideographic,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '输入内容...',
                    contentPadding: EdgeInsets.all(16)
                  ),
                ),
              ),
            ),
            Divider(
              height: 1.0,
            ),
            Container(
              //color: Colors.amber,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.list),
                    onPressed: (){},
                  ),
                  IconButton(
                    icon: Icon(Icons.photo),
                    onPressed: (){},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
import 'package:flutter/material.dart';
import 'package:flutter_moment/task/task_item.dart';

import '../global_store.dart';

class EditerTaskItemRoute extends StatefulWidget {
  EditerTaskItemRoute(this.store, this.taskItem);

  final TaskItem taskItem;
  final GlobalStoreState store;

  @override
  EditerTaskItemRouteState createState() => EditerTaskItemRouteState();
}

class EditerTaskItemRouteState extends State<EditerTaskItemRoute> {
  final titleController = TextEditingController();
  final commentController = TextEditingController();
  final addressNode = FocusNode();
  TaskItem newTask;

  @override
  void initState() {
    super.initState();
    newTask = TaskItem.from(widget.taskItem);
    titleController.text = widget.taskItem.title;
    commentController.text = widget.taskItem.comment;
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String routeTitle = widget.taskItem.isNew ? '编辑任务' : '新增任务';
    TextStyle style = TextStyle(
      color: Colors.black87,
      fontStyle: FontStyle.normal,
      fontSize: 16,
      textBaseline: TextBaseline.ideographic,
    );
    var startDateTxt = widget.store.calendarMap.getChineseTermOfDate(newTask.startDate);
    return Scaffold(
      appBar: AppBar(
        title: Text(routeTitle),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: (){
              if (titleController.text.length > 0) {
                newTask.title = titleController.text;
                newTask.comment = commentController.text;
                Navigator.of(context).pop(newTask);
              } else {
                Navigator.of(context).pop(null);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
                child: SizedBox(
                  height: 32,
                  width: 32,
                  child: Checkbox(
                    value: newTask.state == TaskState.Complete,
                    onChanged: (isCheck) {
                      newTask.state = isCheck ? TaskState.Complete : TaskState.StandBy;
                    },
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: titleController,
                  decoration: InputDecoration(border: InputBorder.none),
                ),
              ),
            ],
          ),
          Divider(height: 3,),
          ListTile(
            title: Text('日期'),
            trailing: Text(startDateTxt),
          ),
          Divider(height: 3,),
        ],
      ),
    );
  }

}
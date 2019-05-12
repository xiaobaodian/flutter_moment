
import 'package:flutter/material.dart';
import 'package:flutter_moment/global_store.dart';

class SetTaskSubItemRoute extends StatefulWidget {

  @override
  SetTaskSubItemRouteState createState() => SetTaskSubItemRouteState();
}

class SetTaskSubItemRouteState extends State<SetTaskSubItemRoute> {
  GlobalStoreState _store;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('任务'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
        child: buildBody(context, _store),
      ),
    );
  }

  Widget buildBody(BuildContext context, GlobalStoreState store) {
    TextStyle subStyle = Theme.of(context).textTheme.caption.merge(TextStyle(
      fontSize: 12,
    ));
    return ListView(
      children: <Widget>[
        ListTile(
          title: Text('优先显示逾期页'),
          subtitle: Text('当有逾期的任务时，优先显示逾期页面', style: subStyle,),
          trailing: Switch(
            value: _store.prefs.priorityDisplayOverdueTasks,
            onChanged: (value) {
              setState(() {
                _store.prefs.priorityDisplayOverdueTasks = value;
              });
            },
          ),
        ),
        Divider(height: 3,),
        ListTile(
          title: Text('保存已完成的任务'),
          subtitle: Text('已完成的任务不自动删除', style: subStyle,),
          trailing: Switch(
            value: _store.prefs.saveCompleteTasks,
            onChanged: (value) {
              setState(() {
                _store.prefs.saveCompleteTasks = value;
              });
            },
          ),
        ),
      ],
    );
  }

}
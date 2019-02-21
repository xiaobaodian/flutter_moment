import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/models/models.dart';
import 'package:flutter_moment/widgets/cat_richtext.dart';

class RichTextEditerRoute extends StatefulWidget {

  final String _focusEvent;

  RichTextEditerRoute(this._focusEvent);

  @override
  RichTextEditerRouteState createState() => RichTextEditerRouteState();
}

class RichTextEditerRouteState extends State<RichTextEditerRoute> {

  var richTextLine = List<RichTextLine>();

  @override
  void initState() {
    super.initState();
    richTextLine.add(RichTextLine(type: RichLineType.Text, content: '一二三四五'));
    richTextLine.add(RichTextLine(type: RichLineType.Text, content: '二二三四五'));
    richTextLine.add(RichTextLine(type: RichLineType.Text, content: '三二三四五'));
    richTextLine.add(RichTextLine(type: RichLineType.Text, content: '四二三四五'));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RichTextEditer'),
      ),
      body: CCCatRichText(),
    );
  }

}
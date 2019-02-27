import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/richtext/cccat_rich_note_data.dart';
import 'package:flutter_moment/richtext/cccat_rich_note_widget.dart';
import 'package:flutter_moment/richtext/cccat_rich_note_layout.dart';

class RichTextEditerRoute extends StatefulWidget {
  final String _focusEvent;

  RichTextEditerRoute(this._focusEvent);

  @override
  RichTextEditerRouteState createState() => RichTextEditerRouteState();
}

class RichTextEditerRouteState extends State<RichTextEditerRoute> {
  var richTextLine = List<RichLine>();
  RichSource richSource;

  @override
  void initState() {
    super.initState();
    //reassemble();
    richSource = RichSource(richTextLine);
  }

  @override
  void reassemble() {
    super.reassemble();
    richTextLine.add(RichLine(type: RichLineType.Title, content: '这是标题'));
    richTextLine.add(RichLine(type: RichLineType.SubTitle, content: '这是副标题'));
    richTextLine.add(RichLine(type: RichLineType.Text, content: '循礼门小龙坎火锅，这里是位置的地址'));
    richTextLine.add(RichLine(type: RichLineType.Task, content: '这是一个任务，去循礼门小龙坎火锅。'));
//    richTextLine.add(RichTextLine(type: RichLineType.Task, content: '这是第二个任务。去循礼门小龙坎火锅，这里是位置的地址，去循礼门小龙坎火锅，这里是位置的地址。'));
    richTextLine.add(RichLine(type: RichLineType.UnorderedList, content: '这里是无序列表'));
    richTextLine.add(RichLine(type: RichLineType.UnorderedList, content: '这里是无序列表，这里是无序列表，这里是无序列表，这里是无序列表。'));
    richTextLine.add(RichLine(type: RichLineType.UnorderedList, content: '这里是无序列表'));
    richTextLine.add(RichLine(type: RichLineType.Text, content: '这里是普通的文本，用于对事物的描述。这里是普通的文本，用于对事物的描述。这里是普通的文本，用于对事物的描述。这里是普通的文本，用于对事物的描述。'));
    richTextLine.add(RichLine(type: RichLineType.OrderedLists, content: '这里是有序列表'));
    richTextLine.add(RichLine(type: RichLineType.OrderedLists, content: '这里是有序列表，这里是有序列表，这里是有序列表。这里是有序列表，这里是有序列表，这里是有序列表。'));
    richTextLine.add(RichLine(type: RichLineType.OrderedLists, content: '这里是有序列表'));
    richTextLine.add(RichLine(type: RichLineType.TextBold, content: '这是粗体文本演示'));
    //richTextLine.add(RichTextLine(type: RichLineType.Image, content: '这是图片的说明'));
    richTextLine.add(RichLine(type: RichLineType.Reference, content: '这里是引用或需要特别说明的文本。这里是引用或需要特别说明的文本。这里是引用或需要特别说明的文本。'));
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
      body: RichNote.editable(
        richSource: richSource,
        onTapLineEvent: (index) {
          print('($index) ${richTextLine[index].content}');
        },
      ),
    );
  }
}

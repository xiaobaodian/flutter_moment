import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/richtext/cat_richtext.dart';
import 'package:flutter_moment/richtext/rich_text_layout.dart';

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

  }

  @override
  void reassemble() {
    super.reassemble();
    richTextLine.add(RichTextLine(type: RichLineType.Title, content: '这是标题'));
    richTextLine.add(RichTextLine(type: RichLineType.SubTitle, content: '这是副标题'));
    richTextLine.add(RichTextLine(type: RichLineType.Text, content: '循礼门小龙坎火锅，这里是位置的地址'));
    richTextLine.add(RichTextLine(type: RichLineType.UnorderedList, content: '这里是无序列表'));
    richTextLine.add(RichTextLine(type: RichLineType.UnorderedList, content: '这里是无序列表，这里是无序列表，这里是无序列表，这里是无序列表。'));
    richTextLine.add(RichTextLine(type: RichLineType.UnorderedList, content: '这里是无序列表'));
    richTextLine.add(RichTextLine(type: RichLineType.Text, content: '这里是普通的文本，用于对事物的描述。这里是普通的文本，用于对事物的描述。这里是普通的文本，用于对事物的描述。这里是普通的文本，用于对事物的描述。'));
    richTextLine.add(RichTextLine(type: RichLineType.OrderedLists, content: '这里是有序列表'));
    richTextLine.add(RichTextLine(type: RichLineType.OrderedLists, content: '这里是有序列表，这里是有序列表，这里是有序列表。这里是有序列表，这里是有序列表，这里是有序列表。'));
    richTextLine.add(RichTextLine(type: RichLineType.OrderedLists, content: '这里是有序列表'));
    richTextLine.add(RichTextLine(type: RichLineType.Reference, content: '这里是引用或需要特别说明的文本。这里是引用或需要特别说明的文本。这里是引用或需要特别说明的文本。'));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void dispose() {
    super.dispose();
  }

  void richOrderedList() {
    int bh = 1;
    richTextLine.forEach((line){
      if (line.type == RichLineType.OrderedLists) {
        line.leading = bh.toString();
        bh++;
      } else if (bh > 1) {
        bh = 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var layout = RichTextLayout(context,
      titleStyle: TextStyle(fontSize: 20, color: Colors.red),
    );
    richOrderedList();
    return Scaffold(
      appBar: AppBar(
        title: Text('RichTextEditer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemBuilder: (context, index) {
            //return getRichLineWidget(richTextLine[index]);
            return layout.getLayoutWidget(richTextLine[index]);
          },
          separatorBuilder: (context, index) {
            if (index == richTextLine.length) {
              return SizedBox(height: 12.0);
            } else if (richTextLine[index].type == RichLineType.OrderedLists || richTextLine[index].type == RichLineType.UnorderedList) {
              if (richTextLine[index+1].type == RichLineType.OrderedLists || richTextLine[index+1].type == RichLineType.UnorderedList) {
                return SizedBox(height: 3.0, width: double.infinity,);
              }
            }
            return SizedBox(height: 12.0);
          },
          itemCount: richTextLine.length),
      ),
    );
  }
}

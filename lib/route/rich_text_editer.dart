import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/models/models.dart';

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
    richTextLine.add(RichTextLine('一二三四五'));
    richTextLine.add(RichTextLine('二二三四五'));
    richTextLine.add(RichTextLine('三二三四五'));
    richTextLine.add(RichTextLine('四二三四五'));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void dispose() {
    super.dispose();
    richTextLine.forEach((textLine) {
      textLine.dispose();
    });
  }

  void caiLine(int index, List<String> line) {
    RichTextLine newLine;
    if (line.length > 1) {
      debugPrint('第二行字数：${line[1].length}');
      richTextLine[index].editingController.text = line[0];
      setState(() {
        newLine = RichTextLine(line[1]);
        richTextLine.insert(index+1, newLine);
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        var focusScopeNode = FocusScope.of(context);
        focusScopeNode.requestFocus(newLine.focusNode);
      });
    }
  }

  void gotoNextLine(int index) {
    if (index < richTextLine.length - 1) {
      var focusScopeNode = FocusScope.of(context);
      focusScopeNode.requestFocus(richTextLine[index+1].focusNode);
    }
  }

  void gotoLine(int index) {
    var focusScopeNode = FocusScope.of(context);
    focusScopeNode.requestFocus(richTextLine[index].focusNode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RichTextEditer'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index){
          return RawKeyboardListener(
            focusNode: richTextLine[index].focusNode,
            child: TextField(
              maxLines: null,
              //maxLength: 300,
              inputFormatters: [ LengthLimitingTextInputFormatter(300), ],
              autofocus: true,
              textAlign: TextAlign.justify,
              style: getLineTextStyle(index),
              textInputAction: TextInputAction.newline,
              focusNode: richTextLine[index].focusNode,
              controller: richTextLine[index].editingController,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(2)
              ),
              onEditingComplete: () {
                //gotoNextLine(index);
                debugPrint('是不是按了回车键');
              },
              onSubmitted: (text){
                debugPrint('是不是按了回车键');
              },
              onChanged: (text) {
                if (richTextLine[index].canChanged) {
                  richTextLine[index].canChanged = false;
                  var line = text.split('\n');
                  caiLine(index, line);
                } else {
                  richTextLine[index].canChanged = true;
                }
              },
            ),
            onKey: (RawKeyEvent event) {
              debugPrint('能够捕获按键码');
              if (event is RawKeyDownEvent) {
                RawKeyDownEvent rawKeyDownEvent = event;
                RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
                print(rawKeyEventDataAndroid.keyCode);
                switch (rawKeyEventDataAndroid.keyCode) {
                }
              }
            },
          );
        },
        itemCount: richTextLine.length,
      ),
    );
  }

}

class RichTextLine {

  bool canChanged = true;

  String fontStyle;
  int lineStyle;
  var editingController = TextEditingController();
  final focusNode = FocusNode();

  RichTextLine(String text) {
//    editingController.addListener((){
//    });
    editingController.text = text;
  }

  void initText(String text) {
    editingController.text = text;
  }

  void dispose() {
    editingController.dispose();
    focusNode.dispose();
  }
}

TextStyle getLineTextStyle(int index) {
  TextStyle style;
  switch (index) {
    case 0: {
      style = TextStyle(
        fontSize: 18,
        color: Colors.black87,
        textBaseline: TextBaseline.ideographic,
      );
      break;
    }
    case 1: {
      style = TextStyle(
        fontSize: 16,
        color: Colors.black87,
        textBaseline: TextBaseline.ideographic,
      );
      break;
    }
    case 2: {
      style = TextStyle(
        fontSize: 12,
        color: Colors.black87,
        textBaseline: TextBaseline.ideographic,
      );
      break;
    }
    default: {
      style = TextStyle(
        fontSize: 14,
        color: Colors.black87,
        textBaseline: TextBaseline.ideographic,
      );
    }
  }
  return style;
}
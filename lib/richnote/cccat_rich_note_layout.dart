import 'package:flutter/material.dart';

class RichNoteLayout {
  RichNoteLayout(
    BuildContext context, {
    this.segmentSpacing = 9.0,
    this.listLineSpacing = 0.0,
    this.leadingSymbols = '•',
    this.titleStyle,
    this.subTitleStyle,
    this.contentStyle,
    this.contentBoldStyle,
    this.taskStyle,
    this.orderedListsStyle,
    this.unorderedListStyle,
    this.referenceStyle,
    this.imageTextStyle,
  })  : defaultTextStyle = DefaultTextStyle.of(context),
        textTheme = Theme.of(context).textTheme;

  final double segmentSpacing;
  final double listLineSpacing;
  final String leadingSymbols;
  final TextTheme textTheme;
  final DefaultTextStyle defaultTextStyle;
  final TextStyle titleStyle;
  final TextStyle subTitleStyle;
  final TextStyle contentStyle;
  final TextStyle contentBoldStyle;
  final TextStyle taskStyle;
  final TextStyle orderedListsStyle;
  final TextStyle unorderedListStyle;
  final TextStyle referenceStyle;
  final TextStyle imageTextStyle;

  Widget richLayoutTitle(Widget content) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        content,
      ],
    );
  }

  Widget richLayoutText(Widget content) {
    return content;
//    return Row(
//      mainAxisAlignment: MainAxisAlignment.start,
//      crossAxisAlignment: CrossAxisAlignment.center,
//      children: <Widget>[
//        Expanded(child: content),
//      ],
//    );
  }

  Widget richLayoutTask(Widget checkbox, Widget task, Widget label) {
    double p = task is TextField ? 2.5 : 5.5;
    List<Widget> widgets = [
      Padding(
        padding: EdgeInsets.fromLTRB(0, p, 0, 0),
        child: task,
      ),
      if (label != null) Padding (
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: label,
      ),
    ];
//    List<Widget> widgets = [];
//    widgets.add(
//        Padding(
//          padding: EdgeInsets.fromLTRB(0, p, 0, 0),
//          child: task,
//        )
//    );
//    if (label != null) {
//      widgets.add(
//        Padding (
//          padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
//          child: label,
//        )
//      );
//    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
          child: SizedBox(
            width: 32,
            height: 32,
            child: checkbox,
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgets
          ),
        ),
      ],
    );
  }

  Widget richLayoutList(int indent, Widget leading, Widget content) {
    const left = const [3.0, 30.0, 53.0];
    TextStyle textStyle;
    if (content is Text) {
      textStyle = content.style.merge(TextStyle(color: Colors.white12));
    } else if (content is TextField) {
      textStyle = content.style.merge(TextStyle(color: Colors.white12));
    } else {
      textStyle = TextStyle(color: Colors.white12);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(left[indent], 2.5, 12, 0),
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: <Widget>[
              Text('猫', style: textStyle),
              leading,
            ],
          ),
        ),
        Expanded(
          child: content,
        ),
      ],
    );
  }

  Widget richLayoutReference(Widget content) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 245, 245, 245),
        border: Border(left: BorderSide(color: Colors.black26, width: 5.0)),
      ),
      child: content,
    );
  }

  Widget richLayoutComment(Widget content) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 245, 245, 245),
        border: Border(left: BorderSide(color: Colors.black26, width: 5.0)),
      ),
      child: content,
    );
  }

  Widget richLayoutImage(Widget widget) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Placeholder(),
    );
  }
}

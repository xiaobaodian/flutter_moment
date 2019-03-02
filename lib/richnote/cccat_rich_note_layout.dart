import 'package:flutter/material.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_widget.dart';

class RichNoteLayout {
  RichNoteLayout(
    BuildContext context, {
    this.segmentSpacing = 8.0,
    this.listLineSpacing = 3.0,
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

  Widget richLayoutText(Widget content) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(child: content),
      ],
    );
  }

  Widget richLayoutTask(Widget task, Widget time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
          child: SizedBox(
            width: 32,
            height: 32,
            child: Checkbox(
              value: true,
              onChanged: (isSelected) {
                isSelected = !isSelected;
              },
            ),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              task,
              Offstage(
                offstage: false,
                child: time,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget richLayoutList(Widget leading, Widget content) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(3, 1, 12, 0),
          child: Center(child: leading),
        ),
        Expanded(
          child: content,
        ),
      ],
    );
  }

  Widget richLayoutSubList(Widget leading, Widget content) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 1, 12, 0),
          child: leading,
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
        color: Colors.black12,
        border: Border(left: BorderSide(color: Colors.black26, width: 5.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Offstage(
            offstage: true,
            child: Text(''),
          ),
          Offstage(
            offstage: true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
              child: Checkbox(
                value: true,
                onChanged: (isSelected) {},
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                content,
                Offstage(
                  offstage: true,
                  child: Text(''),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget richLayoutComment(Widget content) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        border: Border(left: BorderSide(color: Colors. blue, width: 5.0)),
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

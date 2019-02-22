import 'package:flutter/material.dart';

class RichTextLayout {
  RichTextLayout({
    this.segmentSpacing = 12.0,
    this.listLineSpacing = 3.0,
    this.leadingSymbols = '•',
    this.titleStyle,
  });

  final double segmentSpacing;
  final double listLineSpacing;
  final String leadingSymbols;
  final TextStyle titleStyle;

  Widget richLayoutText(Widget widget) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: widget,
    );
  }

  Widget richLayoutTask(Widget widget) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 60,
              height: double.infinity,
              child: Checkbox(
                value: false,
                onChanged: (isSelected){

                },
              ),
            ),
            widget,
          ]
      ),
    );
  }

  Widget richLayoutList(Widget leading, Widget widget) {  // Reference
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(3, 3, 12, 0),
              child: leading,
            ),
            widget,
          ]
      ),
    );
  }

  Widget richLayoutReference(Widget widget) {
    return Container(
      child: widget,
      margin: EdgeInsets.fromLTRB(16, 0, 12, 0),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.black12,
        border: Border(
            left: BorderSide(color: Colors.black26, width: 3.0)
        ),
      ),
    );
  }

  Widget richLayoutImage(Widget widget) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Placeholder(),
    );
  }
}
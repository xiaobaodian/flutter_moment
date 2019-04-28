import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

typedef bool HasSameHeader(int a, int b);

class CCCatHeaderListView extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder headerBuilder;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsets padding;
  final HasSameHeader hasSameHeader;
  final itemExtend;

  CCCatHeaderListView({
    Key key,
    this.itemCount,
    @required this.itemExtend,
    @required this.headerBuilder,
    @required this.itemBuilder,
    @required this.hasSameHeader,
    this.padding,
  }) : super(key: key);

  @override
  _CCCatHeaderListViewState createState() => _CCCatHeaderListViewState();
}


class _CCCatHeaderListViewState extends State<CCCatHeaderListView> {
  int currentPosition = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          child: Opacity(
            opacity: _shouldShowHeader(currentPosition) ? 0.0 : 1.0,
            child: widget.headerBuilder(context, currentPosition >= 0 ? currentPosition : 0),
          ),
          top: 0.0 + (widget.padding?.top ?? 0),
          left: 0.0 + (widget.padding?.left ?? 0),
        ),
        ListView.builder(
          padding: widget.padding,
          itemCount: widget.itemCount,
          itemExtent: widget.itemExtend,
          controller: _getScrollController(),
          itemBuilder: (BuildContext context, int index) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FittedBox(
                  child: Opacity(
                    opacity: _shouldShowHeader(index) ? 1.0 : 0.0,
                    child: widget.headerBuilder(context, index),
                  ),
                ),
                Expanded(child: widget.itemBuilder(context, index))
              ],
            );
          }
        ),
      ],
    );
  }

  bool _shouldShowHeader(int position) {
    if(position < 0){
      return true;
    }
    if (position == 0 && currentPosition < 0) {
      return true;
    }
    if (position != 0 &&
        position != currentPosition &&
        !widget.hasSameHeader(position, position - 1)
    ) {
      return true;
    }
    if (position != widget.itemCount -1 &&
        !widget.hasSameHeader(position, position + 1) &&
        position == currentPosition
    ) {
      return true;
    }
    return false;
  }

  ScrollController _getScrollController() {
    var controller = new ScrollController();
    controller.addListener(() {
      var pixels = controller.offset;
      var newPosition = (pixels / widget.itemExtend).floor();
      if (newPosition != currentPosition) {
        setState(() {
          currentPosition = newPosition;
        });
      }
    });
    return controller;
  }
}
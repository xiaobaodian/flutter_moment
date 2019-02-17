import 'dart:ui';
import 'package:flutter/material.dart';

class CustomCalendar extends CustomPainter {

  BuildContext _buildContext;
  double _layoutWidth, _layoutHeight = 0;

  CustomCalendar(this._buildContext) {
    _layoutWidth = MediaQuery.of(_buildContext).size.width;
  }

  @override
  void paint(Canvas canvas, Size size) {
    
    var rect = Offset.zero & size;

    //canvas.drawRect(rect, Paint()..color = Colors.blue);
    canvas.drawCircle(Offset(size.width/2,size.height/2), 30, Paint()..color = Colors.cyan);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }

}
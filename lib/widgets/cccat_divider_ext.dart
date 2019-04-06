import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/painting.dart';

//import 'theme.dart';

class DividerExt extends StatelessWidget {
  const DividerExt({
    Key key,
    this.height = 16.0,
    this.thickness = 0,
    this.indent = 0.0,
    this.color
  }) : assert(height >= 0.0),
        super(key: key);

  final double height;
  final double thickness;

  final double indent;
  final Color color;

  static BorderSide createBorderSide(BuildContext context, { Color color, double width = 0.0 }) {
    assert(width != null);
    return BorderSide(
      color: color ?? Theme.of(context).dividerColor,
      width: width,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height + thickness,
      child: Center(
        child: Container(
          height: 0.0,
          margin: EdgeInsetsDirectional.only(start: indent),
          decoration: BoxDecoration(
            border: Border(
              bottom: createBorderSide(context, color: color, width: thickness),
            ),
          ),
        ),
      ),
    );
  }
}
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


  /// The divider's height extent.
  ///
  /// The divider itself is always drawn as one device pixel thick horizontal
  /// line that is centered within the height specified by this value.
  ///
  /// A divider with a [height] of 0.0 is always drawn as a line with a height
  /// of exactly one device pixel, without any padding around it.
  final double height;
  final double thickness;

  /// The amount of empty space to the left of the divider.
  final double indent;
  final Color color;

  /// Computes the [BorderSide] that represents a divider of the specified
  /// color, or, if there is no specified color, of the default
  /// [ThemeData.dividerColor] specified in the ambient [Theme].
  ///
  /// The `width` argument can be used to override the default width of the
  /// divider border, which is usually 0.0 (a hairline border).
  ///
  /// {@tool sample}
  ///
  /// This example uses this method to create a box that has a divider above and
  /// below it. This is sometimes useful with lists, for instance, to separate a
  /// scrollable section from the rest of the interface.
  ///
  /// ```dart
  /// DecoratedBox(
  ///   decoration: BoxDecoration(
  ///     border: Border(
  ///       top: Divider.createBorderSide(context),
  ///       bottom: Divider.createBorderSide(context),
  ///     ),
  ///   ),
  ///   // child: ...
  /// )
  /// ```
  /// {@end-tool}
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
      height: height,
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
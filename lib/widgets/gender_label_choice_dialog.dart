import 'package:flutter/material.dart';

class GenderLabelDialog extends Dialog {
  GenderLabelDialog({
    Key key,
    @required this.title,
    @required this.child,
  }) : super(key: key);
  final title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: ShapeDecoration(
                color: Color(0xFFFFFFFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(7.0),
                  )
                )
              ),
              margin: const EdgeInsets.all(12.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 35, 16, 28),
                    child: Center(
                      child: Text(title,
                        style: TextStyle(
                          fontSize: 20.0,
                        )
                      ),
                    )
                  ),
                  Divider(),
                  TextField(),
                  Divider(),
                  child,
                ]
              )
            )
          ]
        )
      )
    );
  }
}
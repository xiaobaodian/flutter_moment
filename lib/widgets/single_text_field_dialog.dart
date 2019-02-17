import 'package:flutter/material.dart';

class SingleTextFieldDialog extends Dialog {
  final Icon icon;
  final String title;
  final String text;
  final ValueChanged<String> onTextChangeEvent;

  SingleTextFieldDialog({
    Key key,
    this.icon,
    @required this.title,
    @required this.text,
    @required this.onTextChangeEvent,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    final _controller = TextEditingController();
    final _focusNode = FocusNode();
    _controller.text = text;
    return Padding(
        padding: const EdgeInsets.fromLTRB(12, 120, 12 ,60),
        child: Material(
            type: MaterialType.transparency,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.fromLTRB(16,16,16,16),
                    decoration: ShapeDecoration(
                        color: Color(0xFFFFFFFF),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(7.0),)
                        )
                    ),
                    margin: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
//                        TextField(
//                          controller: _controller,
//                          focusNode: _focusNode,
//                          autofocus: true,
//                          maxLines: 1,
//                          textInputAction: TextInputAction.done,
//                          decoration: InputDecoration(
//                            icon: icon, //Icon(Icons.person)
//                            labelText: title,
//                            //border: InputBorder.none,
//                          ),
//                          onEditingComplete: () {
//                            //Navigator.of(context).pop(_controller.text);
//                            _focusNode.unfocus();
//                            onTextChangeEvent(_controller.text);
//                            //_controller.dispose();
//                          },
//                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              FlatButton(
                                child: Text('放弃'),
                                onPressed: (){
                                  //Navigator.of(context).pop(null);
                                  onTextChangeEvent(null);
                                },
                              ),
                              FlatButton(
                                child: Text('确认'),
                                onPressed: (){
                                  //Navigator.of(context).pop(_controller.text);
                                  onTextChangeEvent(_controller.text);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
            )
        )
    );
  }
}
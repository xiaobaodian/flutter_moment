import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/models/helper_file.dart';
import 'package:flutter_moment/models/helper_file_image.dart';
import 'package:flutter_moment/models/models.dart';
import 'package:flutter_moment/route/trim_photo_route.dart';
import 'package:flutter_moment/widgets/trim_picture_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class EditerPersonItemRoute extends StatefulWidget {
  final PersonItem _personItem;

  EditerPersonItemRoute(this._personItem);

  @override
  EditerPersonItemRouteState createState() => EditerPersonItemRouteState();
}

/// 这个Route中使用了TextField时，会导致StatefulWidget（即此例中的EditerPersonItemRoute）
/// 在TextField获取或失去焦点时重复执行构建方法，所以如果直接引用了_personItem时会出现字段
/// 清为原始数据的情况。
/// 只有将需要编辑的类成员数据需要在State<>中复制到变量（或TextEditingController）中，才能
/// 有效保留编辑的数据
class EditerPersonItemRouteState extends State<EditerPersonItemRoute> {
  final _nameController = TextEditingController();
  final _focusNode = FocusNode();
  PersonItem _editerPerson = PersonItem();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget._personItem.name;
    _editerPerson.copyWith(widget._personItem);
//    _editerPerson = PersonItem(
//      name: widget._personItem.name,
//      gender: widget._personItem.gender,
//      birthday: widget._personItem.birthday,
//      photo: widget._personItem.photo,
//    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String routeTitle = widget._personItem.name.length == 0 ? '新增人物' : '编辑人物';
    return Scaffold(
      appBar: AppBar(
        title: Text(routeTitle),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () {
              if (_nameController.text.length > 0) {
                _editerPerson.name = _nameController.text;
                Navigator.of(context).pop(_editerPerson);
              } else {
                Navigator.of(context).pop(null);
              }
            },
          ),
        ],
      ),
      body: getPersonFormColumn(context),
    );
  }

  Widget getPersonFormColumn(BuildContext context) {
    String _birthdayString = _editerPerson.hasBirthday()
        ? _editerPerson.getBirthdayChineseTitle()
        : '输入日期';
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ClipOval(
              child: SizedBox(
                height: 75,
                width: 75,
                child: InkWell(
                  child: _editerPerson.getImage(),
                  onTap: () {
                    _focusNode.unfocus();
                    showDialog(
                        context: context,
                        builder: (context) {
                          return TrimPictureDialog(
                              hasPicture: _editerPerson.hasPhoto());
                        }).then((img) {
                      if (img is Uint8List) {
                        setState(() {
                          _editerPerson.updatePhoto(
                              Base64Encoder().convert(img.toList()));
                        });
                      } else if (img is int) {
                        setState(() {
                          _editerPerson.updatePhoto(null);
                        });
                      }
                    });
                  },
                ),
              ),
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
            child: TextField(
              autofocus: true,
              maxLines: 1,
              controller: _nameController,
              focusNode: _focusNode,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.go,
              style: TextStyle(
                  color: Colors.black87,
                  fontStyle: FontStyle.normal,
                  fontSize: 16,
                  textBaseline: TextBaseline.ideographic),
              decoration: InputDecoration(
                icon: Icon(Icons.person),
                hintText: '输入姓名',
                //labelText: '姓名',
                border: InputBorder.none,
                contentPadding: EdgeInsets.fromLTRB(16, 16, 16, 16),
              ),
            ),
          ),
          Divider(
            indent: 24,
          ),
          ListTile(
            leading: Icon(Icons.face),
            title: Text('性别'),
            trailing: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(_editerPerson.getGenderChineseTitle()),
                Icon(Icons.arrow_right)
              ],
            ),
            onTap: () {
              _focusNode.unfocus();
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return GenderChooseDialog(
                        title: '设置性别',
                        onBoyChooseEvent: () {
                          Navigator.pop(context);
                          setState(() {
                            _editerPerson.gender = 1;
                          });
                        },
                        onGirlChooseEvent: () {
                          Navigator.pop(context);
                          setState(() {
                            _editerPerson.gender = 0;
                          });
                        });
                  });
            },
          ),
          Divider(indent: 24),
          ListTile(
            leading: Icon(Icons.cake),
            title: Text('生日'),
            trailing: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(_birthdayString),
                Icon(Icons.arrow_right)
              ],
            ),
            onTap: () {
              _focusNode.unfocus();
              showDatePicker(
                      context: context,
                      initialDate: _editerPerson.birthday == null
                          ? DateTime.now()
                          : _editerPerson.birthday,
                      firstDate: DateTime(1949, 1, 1),
                      lastDate: DateTime(2050, 12, 31))
                  .then((dateTime) {
                if (dateTime != null) {
                  setState(() {
                    _editerPerson.birthday = dateTime;
                  });
                }
              });
            },
          ),
          Divider(indent: 24),
        ],
      ),
    );
  }
}

class GenderChooseDialog extends Dialog {
  final title;
  final Function onBoyChooseEvent;
  final Function onGirlChooseEvent;

  GenderChooseDialog({
    Key key,
    @required this.title,
    @required this.onBoyChooseEvent,
    @required this.onGirlChooseEvent,
  }) : super(key: key);

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
                              borderRadius: BorderRadius.all(
                            Radius.circular(7.0),
                          ))),
                      margin: const EdgeInsets.all(12.0),
                      child: Column(children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.fromLTRB(16, 35, 16, 28),
                            child: Center(
                                child: Text(title,
                                    style: TextStyle(
                                      fontSize: 20.0,
                                    )))),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              _genderChooseItemWid(1),
                              _genderChooseItemWid(0)
                            ])
                      ]))
                ])));
  }

  Widget _genderChooseItemWid(int gender) {
    return InkWell(
        onTap: gender == 1 ? this.onBoyChooseEvent : this.onGirlChooseEvent,
        child: Column(children: <Widget>[
          Image.asset(
              gender == 1
                  ? 'assets/image/iconBoy.png'
                  : 'assets/image/iconGirl.png',
              width: 135.0,
              height: 135.0),
          Padding(
              padding: EdgeInsets.fromLTRB(0.0, 22.0, 0.0, 40.0),
              child: Text(gender == 1 ? '男生' : '女生',
                  style: TextStyle(
                      color: Color(gender == 1 ? 0xff4285f4 : 0xffff4444),
                      fontSize: 15.0)))
        ]));
  }
}

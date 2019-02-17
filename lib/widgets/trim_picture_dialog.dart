import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';

///
/// 这是一个对话框，需要用下面的方式调用
/// showDialog(
///   context: context,
///   builder: (context) {
///     return TrimPicture();
///   }
/// );
///

class TrimPictureDialog extends StatefulWidget {
  final bool hasPicture;

  TrimPictureDialog({
    this.hasPicture = false,
  });

  @override
  _TrimPictureDialogState createState() => _TrimPictureDialogState();
}

class _TrimPictureDialogState extends State<TrimPictureDialog> with TickerProviderStateMixin {
  GlobalKey _repaintKey = GlobalKey();
  bool _dialogMode = true;
  File _imageFile;
  Image _imagePhoto;

  double _scale = 1.4;
  double _tmpScale = 1.0;
  double _moveX = 0.0;
  double _tmpMoveX = 0.0;
  double _moveY = 0.0;
  double _tmpMoveY = 0.0;
  double _rotation = 0.0;
  double _tmpRotation = 0.0;

  Offset _tmpFocal = Offset.zero;

  AnimationController _animationController;
  Animation<double> _values;

  @override
  void initState() {
    super.initState();

    // 这段时测试图片大小的，用于改进图片裁切算法
//    var completer = Completer();
//    _imagePhoto.image.resolve(ImageConfiguration()).addListener((info, _) => completer.complete(info.image));
//    completer.future.then((img){
//      debugPrint('img: $img');
//    });

    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 120));
    // Tween 将动画的 0 - 1 的值映射到我们设置的范围内
    _values = Tween(begin: 1.0, end: 0.0).animate(_animationController);
    _animationController.addListener(() {
      setState(() {
        // 通过动画逐帧还原位置
        _moveX = _tmpMoveX * _values.value;
        _moveY = _tmpMoveY * _values.value;
        _scale = (_tmpScale - 1) * _values.value + 1;
        _rotation = _tmpRotation * _values.value;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print(MediaQuery.of(context).size);
    //_scale = screenWidth / _imageWidth;
  }

  @override
  void dispose() {
    super.dispose();
    _animationController?.dispose();
  }

  Future getPicture(ImageSource imageSource) async {
    _imageFile = await ImagePicker.pickImage(source: imageSource);  //ImageSource.camera  ImageSource.gallery
    if (_imageFile == null) {
      Navigator.of(context).pop(null);
    } else {
      setState(() {
        _dialogMode = false;
        _imagePhoto = Image.file(_imageFile);
      });
    }
  }

  Future<Uint8List> _captureImg() async {
    try {
      RenderRepaintBoundary boundary = _repaintKey.currentContext.findRenderObject();
      var image = await boundary.toImage(pixelRatio: 0.5);
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      return pngBytes;
    } catch (e) {
      print(e);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_dialogMode) {
      List<Widget> listTiles = [];
      listTiles.add(
          ListTile(
            leading: Icon(Icons.photo),
            title: Text('从照片库中选择'),
            onTap: (){
              getPicture(ImageSource.gallery);
            },
          )
      );
      listTiles.add(
        ListTile(
          leading: Icon(Icons.camera_alt),
          title: Text('拍摄新的照片'),
          onTap: (){
            getPicture(ImageSource.camera);
          },
        ),
      );
      if (widget.hasPicture) {
        listTiles.add(
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('删除现有的图片'),
            onTap: (){
              Navigator.of(context).pop(1);
            },
          ),
        );
      }
      return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Material(
              type: MaterialType.transparency,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: listTiles,
                      ),
                    ),
                  ]
              )
          )
      );
    }
    double _width = MediaQuery.of(context).size.width;
    // 配置 Matrix
    Matrix4 matrix4 = Matrix4.identity()
      ..scale(_scale, _scale)
      ..translate(_moveX, _moveY)
      ..rotateZ(_rotation);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('裁切图片'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.done),
            onPressed: (){
              _captureImg().then((img){
                if (img is Uint8List) {
                  var list = img.toList();
                  debugPrint('剪切后的图片大小：${list.length}');
                }
                Navigator.of(context).pop(img);
              });
            },
          ),
        ],
      ),
      body: Center(
        child: GestureDetector(
          onDoubleTap: () {
            if (!_animationController.isAnimating) {
              _tmpMoveX = _moveX;
              _tmpMoveY = _moveY;
              _tmpScale = _scale;
              _tmpScale = 1.4;
              _tmpRotation = _rotation;
              _animationController.reset();
              _animationController.forward();
            }
          },
          onScaleStart: (details) {
            if (!_animationController.isAnimating) {
              _tmpFocal = details.focalPoint;
              _tmpMoveX = _moveX;
              _tmpMoveY = _moveY;
              _tmpScale = _scale;
              _tmpRotation = _rotation;
            }
          },
          onScaleUpdate: (details) {
            if (!_animationController.isAnimating) {
              setState(() {
                _moveX = _tmpMoveX + (details.focalPoint.dx - _tmpFocal.dx) / _tmpScale;
                _moveY = _tmpMoveY + (details.focalPoint.dy - _tmpFocal.dy) / _tmpScale;
                _scale = _tmpScale * details.scale;
                debugPrint('_moveX[$_moveX] = _tmpMoveX[$_tmpMoveX] + (details.focalPoint.dx[${details.focalPoint.dx}] - _tmpFocal.dx[${_tmpFocal.dx}]) / _tmpScale');
                debugPrint('_moveY[$_moveY] = _tmpMoveY[$_tmpMoveY] + (details.focalPoint.dy[${details.focalPoint.dy}] - _tmpFocal.dy[${_tmpFocal.dy}]) / _tmpScale');
                debugPrint('_scale[$_scale] = _tmpScale[$_tmpScale] * details.scale[${details.scale}]');
                //_rotation = _tmpRotation + details.rotation;
                //print(_rotation);
              });
            }
          },
          child: Center(
            child: RepaintBoundary(
              key: _repaintKey,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                child: SizedBox(
                  width: _width - 32,
                  height: _width - 32,
                  child: Hero(
                    tag: _imageFile,
                    child: Transform(
                      alignment: FractionalOffset.center,
                      transform: matrix4,
                      child: _imagePhoto, //Image.file(widget._imageFile,), // fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

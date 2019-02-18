import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TrimPhoto extends StatefulWidget {
  final File _imageFile;

  TrimPhoto(this._imageFile);

  @override
  State<StatefulWidget> createState() => _TrimPhotoState();
}

class _TrimPhotoState extends State<TrimPhoto> with TickerProviderStateMixin {
  GlobalKey repaintKey = GlobalKey();
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
    _imagePhoto = Image.file(widget._imageFile);

    // 这段时测试图片大小的，用于改进图片裁切算法
    var completer = Completer();
    _imagePhoto.Image.resolve(ImageConfiguration()).addListener((info, _) => completer.complete(info.mixinImage));
    completer.future.then((img){
      debugPrint('img: $img');
    });

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

  Future<Uint8List> _captureImg() async {
    try {
      RenderRepaintBoundary boundary = repaintKey.currentContext.findRenderObject();
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
    double _width = MediaQuery.of(context).size.width;
    // 配置 Matrix
    Matrix4 matrix4 = Matrix4.identity()
      ..scale(_scale, _scale)
      ..translate(_moveX, _moveY)
      ..rotateZ(_rotation);
    return Scaffold(
      backgroundColor: Colors.white24,
      appBar: AppBar(
        title: Text('剪切图片'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.done),
            onPressed: (){
              _captureImg().then((img) {
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
              key: repaintKey,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                child: SizedBox(
                  width: _width - 32,
                  height: _width - 32,
                  child: Hero(
                    tag: widget._imageFile,
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
//          child: Container(
//            width: _width,
//            height: _width,
//            color: Colors.black,
//            child: Center(
//              child: Hero(
//                tag: widget._imageFile,
//                child: Transform(
//                  alignment: FractionalOffset.center,
//                  transform: matrix4,
//                  child: Image.file(widget._imageFile),
//                ),
//              ),
//            ),
//          ),
        ),
      ),
    );
  }
}
import 'dart:ui';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_moment/models/enums.dart';

mixin BuildImageMixin {
  Image _image;
  String _source, _defaultDark, _defaultLight;

  void setImageSource(String source) {
    _source = source;
    _image = null;
  }

  void setDarkSource(String dark) {
    _defaultDark = dark;
  }

  void setLightSource(String light) {
    _defaultLight = light;
  }

  Image buildImage(EImageMode mode) {
    if (_source == null) {
      if (mode == EImageMode.Dark && _defaultDark != null) {
        return Image.asset(_defaultDark);
      } else if (mode == EImageMode.Light && _defaultLight != null) {
        return Image.asset(_defaultLight);
      }
      return null;
    }
    if (_image == null) {
      _image = Image.memory(Base64Decoder().convert(_source));
    }
    return _image;
  }
}
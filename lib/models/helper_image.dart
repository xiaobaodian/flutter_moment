import 'dart:ui';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_moment/models/enums.dart';

mixin BuildImageMixin {
  Image _image;
  String _source = '', _defaultDark = '', _defaultLight = '';

  bool hasImage() => _source.isNotEmpty;
  String get mixinImage => _source;

  void setMixinImageSource(String source) {
    _source = (source == null) ? '' : source;
    _image = null;
  }

  void setMixinDarkSource(String dark) {
    _defaultDark = dark;
  }

  void setMixinLightSource(String light) {
    _defaultLight = light;
  }

  Image buildMixinImage(EImageMode mode) {
    if (_source.isEmpty) {
      if (mode == EImageMode.Dark && _defaultDark.isNotEmpty) {
        return Image.asset(_defaultDark);
      } else if (mode == EImageMode.Light && _defaultLight.isNotEmpty) {
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


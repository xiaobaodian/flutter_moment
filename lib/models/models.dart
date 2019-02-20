import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_moment/models/enums.dart';
import 'package:flutter_moment/models/helper_image.dart';
import 'package:flutter_moment/models/helper_chinese_string.dart';

class BaseItem {
  int boxId = 0;
  int references = 0;
//  bool systemPresets = false;
//  bool internal = false;

  BaseItem({
    this.boxId = 0,
    this.references = 0,
  });

  bool get isReferences => references == 0;
  bool get isNotReferences => references > 0;

  void addReferences() {
    references++;
  }

  void minusReferences() {
    references--;
  }
}

class SystemBaseItem extends BaseItem {
  bool systemPresets = false;
  bool internal = false;

  SystemBaseItem({
    boxId = 0,
    references = 0,
    systemPresets = false,
    internal = false,
}): super(
    boxId: boxId,
    references: references,
  );
}

// user.g.dart 将在我们运行生成命令后自动生成
//part 'models.g.dart';
//这个标注是告诉生成器，这个类是需要生成Model类的
//@JsonSerializable()

class FocusItem extends SystemBaseItem with DetailsListMixin<FocusEvent> {
  String title;
  String comment;

  FocusItem({
    this.title = "",
    this.comment = "",
  }): super();

  // 新建实例时的构建函数
  FocusItem.build({
    this.title,
    this.comment,
    int boxId = 0,
    int references = 0,
    bool systemPresets = false,
    bool internal = false,
  }): super(boxId: boxId, references: references, systemPresets: systemPresets, internal: internal) {
    //id = DateTime.now().millisecondsSinceEpoch.toString();
  }

  factory FocusItem.fromJson(Map<String, dynamic> json) {
    return FocusItem.build(
      boxId: json['boxId'],
      title: json['title'],
      comment: json['comment'],
      references: json['references'],                   // 引用次数
      systemPresets: json['systemPresets'],             // 系统预设
      internal: json['internal'],                       // 内部使用
    );
  }

  Map<String, dynamic> toJson() => {
    'boxId': boxId,
    'title': title,
    'comment': comment,
    'references': references,
    'systemPresets': systemPresets,
    'internal': internal,
  };
}

///
/// PlaceItem 定义
///
class PlaceItem extends BaseItem with BuildImageMixin {
  String title;
  String address;
  double geography;
  String picture;

  PlaceItem({
    this.title = '',
    this.address = '',
    this.picture,
    boxId = 0,
    references = 0,
  }): super(boxId: boxId, references: references) {
    setMixinImageSource(picture);
    setMixinDarkSource('assets/image/defaultPersonPhoto1.png');
    setMixinLightSource('assets/image/defaultPersonPhoto2.png');
  }

  bool hasTitle() => title.length > 0;
  bool hasPicture() => picture != null;

  Image getImage({EImageMode mode = EImageMode.Dark}) {
    return buildMixinImage(mode);
  }

  void updatePicture(String pic) {
    picture = pic;
    setMixinImageSource(picture);
  }

  void copyWith(PlaceItem other) {
    title = other.title;
    address = other.address;
    geography = other.geography;
    if (picture != other.picture) {
      picture = other.picture;
      setMixinImageSource(picture);
    }
  }

  factory PlaceItem.fromJson(Map<String, dynamic> json) {
    return PlaceItem(
      boxId: json['boxId'],
      title: json['title'],
      address: json['address'],
      picture: json['picture'],
      references: json['references'],
    );
  }

  Map<String, dynamic> toJson() => {
    'boxId': boxId,
    'title': title,
    'address': address,
    'picture': picture,
    'references': references,
  };

}

///
/// gender: 0->Female, 1->Male, 2->None
///
class PersonItem extends BaseItem with BuildImageMixin, GetPersonChineseStringMixin {
  String name;
  //String photo;
  int gender;
  DateTime birthday;
  double height;
  double weight;

  PersonItem({
    this.name = '',
    this.gender = 2,
    this.birthday,
    photo = '',
    boxId = 0,
    references = 0,
  }): super(boxId: boxId, references: references) {
    setMixinImageSource(photo);
    setMixinDarkSource('assets/image/defaultPersonPhoto1.png');
    setMixinLightSource('assets/image/defaultPersonPhoto2.png');
  }

  String get photo => mixinImage;
  bool hasPhoto() => hasImage();
  bool hasBirthday() => birthday != null;

  Image getImage({EImageMode mode = EImageMode.Dark}) {
    return buildMixinImage(mode);
  }

  void updatePhoto(String photo) {
    setMixinImageSource(photo);
  }

  String getGenderChineseTitle() {
    return getGenderChineseString(gender);
  }

  String getBirthdayChineseTitle() {
    return getBirthdayChineseString(birthday);
  }

  void copyWith(PersonItem other) {
    name = other.name;
    gender = other.gender;
    birthday = other.birthday;
    height = other.height;
    weight = other.weight;
    if (mixinImage != other.mixinImage) {
      setMixinImageSource(other.mixinImage);
    }
  }

  factory PersonItem.fromJson(Map<String, dynamic> json) {
    String _birthday = json['birthday'];
    return PersonItem(
      name: json['name'],
      photo: json['photo'],
      gender: json['gender'],
      birthday: _birthday == '' ? null : DateTime.parse(_birthday),
      boxId: json['boxId'],
      references: json['references']
    );
  }

  //
  Map<String, dynamic> toJson() => {
    'boxId': boxId,
    'name': name,
    'photo': mixinImage,
    'gender': gender,
    'birthday': hasBirthday() ? birthday.toIso8601String() : '',
    'references': references,
  };
}

///
/// DailyEvents 每天的事件句柄
///

class DailyRecord {
  int boxId = 0;
  int dayIndex;
  //DateTime date;
  String weather;
  List<FocusEvent> focusEvents = [];

  DailyRecord(this.dayIndex);

  DailyRecord.build({
    this.boxId,
    this.dayIndex,
    this.weather,
    var focusEventsOfJson,
  }) {
    var list = focusEventsOfJson as List;
    focusEvents = list.map((item) => FocusEvent.fromJson(item)).toList();
  }

  bool get isNull => weather.isEmpty && focusEvents.isEmpty;

  factory DailyRecord.fromJson(Map<String, dynamic> json) {
    return DailyRecord.build(
      boxId: json['boxId'],
      dayIndex: json['dayIndex'],
      weather: json['weather'],
      focusEventsOfJson: json['focusEvents'],
    );
  }

  Map<String, dynamic> toJson() => {
    'boxId': boxId,
    'dayIndex': dayIndex,
    'weather': weather,
  };
}

class FocusEvent {
  int boxId;
  int dayIndex;
  int focusItemBoxId;
  String note;

  FocusEvent({
    this.boxId = 0,
    this.dayIndex = -1,
    this.focusItemBoxId = -1,
    this.note = ''
  });

  void copyWith(FocusEvent other) {
    boxId = other.boxId;
    dayIndex = other.dayIndex;
    focusItemBoxId = other.focusItemBoxId;
    note = other.note;
  }

  factory FocusEvent.fromJson(Map<String, dynamic> json) {
    return FocusEvent(
      boxId: json['boxId'],
      dayIndex: json['dayIndex'],
      focusItemBoxId: json['focusItemBoxId'],
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() => {
    'boxId': boxId,
    'dayIndex': dayIndex,
    'focusItemBoxId': focusItemBoxId,
    'note': note,
  };
}

mixin DetailsListMixin<T> {
  List<T> detailsList = [];

  void addDetailsItem(T item) {
    detailsList.add(item);
  }

  void removeDetailsItem(T item) {
    detailsList.remove(item);
  }
}

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
  bool systemPresets = false;
  bool internal = false;

  BaseItem({
    this.boxId = 0,
    this.references = 0,
    this.systemPresets = false,
    this.internal = false,
  });

  bool get referencesIsNull => references == 0;
  bool get referencesIsNotNull => references > 0;

  void addReferences() {
    references++;
  }

  void minusReferences() {
    references--;
  }
}

class BasePhotoItem extends BaseItem {
  String dir;
  BasePhotoItem({
    this.dir,
    boxId = 0,
    references = 0,
    systemPresets = false,
    internal = false,
}): super(
    boxId: boxId,
    references: references,
    systemPresets: systemPresets,
    internal: internal,
  );
}

// user.g.dart 将在我们运行生成命令后自动生成
//part 'models.g.dart';
//这个标注是告诉生成器，这个类是需要生成Model类的
//@JsonSerializable()

class FocusItem extends BaseItem {

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
    setImageSource(picture);
    setDarkSource('assets/image/defaultPersonPhoto1.png');
    setLightSource('assets/image/defaultPersonPhoto2.png');
  }

  bool hasTitle() => title.length > 0;
  bool hasPicture() => picture != null;

  Image getImage({EImageMode mode = EImageMode.Dark}) {
    return buildImage(mode);
  }

  void updatePicture(String pic) {
    picture = pic;
    setImageSource(picture);
  }

  void copyWith(PlaceItem other) {
    title = other.title;
    address = other.address;
    geography = other.geography;
    if (picture != other.picture) {
      picture = other.picture;
      setImageSource(picture);
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
  String photo;
  int gender;
  DateTime birthday;
  double height;
  double weight;

  PersonItem({
    this.name = '',
    this.gender = 2,
    this.birthday,
    this.photo,
    boxId = 0,
    references = 0,
  }): super(boxId: boxId, references: references) {
    setImageSource(photo);
    setDarkSource('assets/image/defaultPersonPhoto1.png');
    setLightSource('assets/image/defaultPersonPhoto2.png');
  }

  bool hasPhoto() => photo != null;
  bool hasBirthday() => birthday != null;

  Image getImage({EImageMode mode = EImageMode.Dark}) {
    return buildImage(mode);
  }

  void updatePhoto(String photo) {
    this.photo = photo;
    setImageSource(photo);
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
    if (photo != other.photo) {
      photo = other.photo;
      setImageSource(photo);
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
    'photo': photo,
    'gender': gender,
    'birthday': hasBirthday() ? birthday.toIso8601String() : '',
    'references': references,
  };
}

///
/// DailyEvents 每天的事件句柄
///

class DailyEvents {
  int boxId = 0;
  int dayIndex;
  //DateTime date;
  String weather;
  List<FocusEvent> focusEvents = [];

  DailyEvents(this.dayIndex);

  DailyEvents.build({
    this.boxId,
    this.dayIndex,
    var focusEventsFromJson,
  }) {
    var list = focusEventsFromJson as List;
    focusEvents = list.map((item) => FocusEvent.fromJson(item)).toList();
  }

  factory DailyEvents.fromJson(Map<String, dynamic> json) {
    return DailyEvents.build(
      boxId: json['boxId'],
      dayIndex: json['dayIndex'],
      focusEventsFromJson: json['focusEvents'],
    );
  }

  Map<String, dynamic> toJson() => {
    'boxId': boxId,
    'dayIndex': dayIndex,
    'focusEvents': focusEvents,
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

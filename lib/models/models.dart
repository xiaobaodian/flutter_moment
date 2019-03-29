import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/models/enums.dart';
import 'package:flutter_moment/models/helper_image.dart';
import 'package:flutter_moment/models/helper_chinese_string.dart';
import 'package:flutter_moment/models/data_helper.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_data.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_widget.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_layout.dart';
import 'package:flutter_moment/task/task_item.dart';

class PassingObject<T> {
  PassingObject({this.oldObject, this.newObject});
  T oldObject;
  T newObject;
}

abstract class BoxItem {
  BoxItem({
    this.boxId = 0,
    this.bmobObjectId,
    this.bmobCreatedAt,
    this.bmobUpdatedAt,
  });

  int boxId;
  String bmobObjectId;
  String bmobCreatedAt;
  String bmobUpdatedAt;

  factory BoxItem.itemFromJson(Type type, Map<String, dynamic> json) {
    if (type == FocusItem) {
      return FocusItem.fromJson(json);
    } else if (type == PersonItem) {
      return PersonItem.fromJson(json);
    } else if (type == PlaceItem) {
      return PlaceItem.fromJson(json);
    } else if (type == PlaceItem) {
      return PlaceItem.fromJson(json);
    } else if (type == TagItem) {
      return TagItem.fromJson(json);
    } else if (type == TaskItem) {
      return TaskItem.fromJson(json);
    } else if (type == DailyRecord) {
      return DailyRecord.fromJson(json);
    } else if (type == FocusEvent) {
      return FocusEvent.fromJson(json);
    }
    return null;
  }

  static String typeName(Type type) {
    if (type == FocusItem) {
      return 'FocusItem';
    } else if (type == PersonItem) {
      return 'PersonItem';
    } else if (type == PlaceItem) {
      return 'PlaceItem';
    } else if (type == FocusEvent) {
      return 'FocusEvent';
    } else if (type == TagItem) {
      return 'TagItem';
    } else if (type == TaskItem) {
      return 'TaskItem';
    } else if (type == DailyRecord) {
      return 'DailyRecord';
    } else if (type == FocusEvent) {
      return 'FocusEvent';
    }
    return null;
  }

  Map<String, dynamic> toJson();
}

abstract class ReferencesBoxItem extends BoxItem {
  ReferencesBoxItem({
    boxId = 0,
    this.count = 0,
    bmobObjectId,
    bmobCreatedAt,
    bmobUpdatedAt,
  }) : super(
            boxId: boxId,
            bmobObjectId: bmobObjectId,
            bmobCreatedAt: bmobCreatedAt,
            bmobUpdatedAt: bmobUpdatedAt);

  int count;
  bool get isReferences => count == 0;
  bool get isNotReferences => count > 0;

  String getLabel();

  void addReferences() {
    count++;
  }

  void minusReferences() {
    count--;
    if (count < 0) count = 0;
  }
}

abstract class SystemBaseItem extends ReferencesBoxItem {
  SystemBaseItem({
    boxId = 0,
    count = 0,
    this.presets = false,
    this.internal = false,
    bmobObjectId,
    bmobCreatedAt,
    bmobUpdatedAt,
  }) : super(
            boxId: boxId,
            count: count,
            bmobObjectId: bmobObjectId,
            bmobCreatedAt: bmobCreatedAt,
            bmobUpdatedAt: bmobUpdatedAt);

  bool presets;
  bool internal;
}

// user.g.dart 将在我们运行生成命令后自动生成
//part 'models.g.dart';
//这个标注是告诉生成器，这个类是需要生成Model类的
//@JsonSerializable()

class FocusItem extends SystemBaseItem with DetailsListMixin<FocusEvent> {
  FocusItem({
    this.title = "",
    this.comment = "",
    bmobObjectId,
    bmobCreatedAt,
    bmobUpdatedAt,
  }) : super(
            bmobObjectId: bmobObjectId,
            bmobCreatedAt: bmobCreatedAt,
            bmobUpdatedAt: bmobUpdatedAt);

  // 新建实例时的构建函数
  FocusItem.build({
    this.title,
    this.comment,
    int boxId = 0,
    int count = 0,
    bool presets = false,
    bool internal = false,
    bmobObjectId,
    bmobCreatedAt,
    bmobUpdatedAt,
  }) : super(
          boxId: boxId,
          count: count,
          presets: presets,
          internal: internal,
          bmobObjectId: bmobObjectId,
          bmobCreatedAt: bmobCreatedAt,
          bmobUpdatedAt: bmobUpdatedAt,
        ) {
    //id = DateTime.now().millisecondsSinceEpoch.toString();
  }

  String title;
  String comment;
  String getLabel() => title;

  void copyWith(FocusItem other) {
    title = other.title;
    comment = other.comment;

    presets = other.presets;
    internal = other.internal;

    boxId = other.boxId;
    count = other.count;
    bmobObjectId = other.bmobObjectId;
    bmobCreatedAt = other.bmobCreatedAt;
    bmobUpdatedAt = other.bmobUpdatedAt;
  }

  factory FocusItem.fromJson(Map<String, dynamic> json) {
    return FocusItem.build(
      title: json['title'],
      comment: json['comment'],
      count: json['count'], // 引用次数
      presets: json['presets'] == 1, // 系统预设
      internal: json['internal'] == 1, // 内部使用
      boxId: json['boxId'],
      bmobObjectId: json['bmobObjectId'],
      bmobCreatedAt: json['bmobCreatedAt'],
      bmobUpdatedAt: json['bmobUpdatedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'comment': comment,
        'count': count,
        'presets': presets ? 1 : 0,
        'internal': internal ? 1 : 0,
        'bmobObjectId': bmobObjectId,
        'bmobCreatedAt': bmobCreatedAt,
        'bmobUpdatedAt': bmobUpdatedAt,
      };
}

///
/// [PlaceItem] “位置”的class定义，需要用到数据库和引用计数，所以扩展自[ReferencesBoxItem]
///
/// “位置”有图片数据处理，所以混入了[BuildImageMixin]
///
class PlaceItem extends ReferencesBoxItem
    with BuildImageMixin, DetailsListMixin<FocusEvent> {
  PlaceItem({
    this.title = '',
    this.address = '',
    this.coverPicture,
    boxId = 0,
    count = 0,
    bmobObjectId,
    bmobCreatedAt,
    bmobUpdatedAt,
  }) : super(
          boxId: boxId,
          count: count,
          bmobObjectId: bmobObjectId,
          bmobCreatedAt: bmobCreatedAt,
          bmobUpdatedAt: bmobUpdatedAt,
        ) {
    setMixinImageSource(coverPicture);
    setMixinDarkSource('assets/image/defaultPersonPhoto1.png');
    setMixinLightSource('assets/image/defaultPersonPhoto2.png');
  }

  String title;
  String address;
  double geography;
  String coverPicture;

  bool hasTitle() => title.length > 0;
  bool hasPicture() => coverPicture != null;

  String getLabel() => title;

  Image getImage({EImageMode mode = EImageMode.Dark}) {
    return buildMixinImage(mode);
  }

  void updatePicture(String pic) {
    coverPicture = pic;
    setMixinImageSource(coverPicture);
  }

  void copyWith(PlaceItem other) {
    title = other.title;
    address = other.address;
    geography = other.geography;
    if (coverPicture != other.coverPicture) {
      coverPicture = other.coverPicture;
      setMixinImageSource(coverPicture);
    }
    boxId = other.boxId;
    count = other.count;
    bmobObjectId = other.bmobObjectId;
    bmobCreatedAt = other.bmobCreatedAt;
    bmobUpdatedAt = other.bmobUpdatedAt;
  }

  factory PlaceItem.fromJson(Map<String, dynamic> json) {
    return PlaceItem(
      title: json['title'],
      address: json['address'],
      coverPicture: json['coverPicture'],
      boxId: json['boxId'],
      count: json['count'],
      bmobObjectId: json['bmobObjectId'],
      bmobCreatedAt: json['bmobCreatedAt'],
      bmobUpdatedAt: json['bmobUpdatedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'address': address,
        'coverPicture': coverPicture,
        'count': count,
        'bmobObjectId': bmobObjectId,
        'bmobCreatedAt': bmobCreatedAt,
        'bmobUpdatedAt': bmobUpdatedAt,
      };
}

///
/// [TagItem] 标签项的class定义，需要用到数据库和引用计数，所以扩展自[ReferencesBoxItem]
///
class TagItem extends ReferencesBoxItem with DetailsListMixin<FocusEvent> {
  String title;

  TagItem({
    this.title = '',
    boxId = 0,
    count = 0,
    bmobObjectId,
    bmobCreatedAt,
    bmobUpdatedAt,
  }) : super(
          boxId: boxId,
          count: count,
          bmobObjectId: bmobObjectId,
          bmobCreatedAt: bmobCreatedAt,
          bmobUpdatedAt: bmobUpdatedAt,
        );

  bool hasTitle() => title.isNotEmpty;
  String getLabel() => title;

  void copyWith(TagItem other) {
    title = other.title;
    boxId = other.boxId;
    count = other.count;
    bmobObjectId = other.bmobObjectId;
    bmobCreatedAt = other.bmobCreatedAt;
    bmobUpdatedAt = other.bmobUpdatedAt;
  }

  factory TagItem.fromJson(Map<String, dynamic> json) {
    return TagItem(
      title: json['title'],
      boxId: json['boxId'],
      count: json['count'],
      bmobObjectId: json['bmobObjectId'],
      bmobCreatedAt: json['bmobCreatedAt'],
      bmobUpdatedAt: json['bmobUpdatedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'count': count,
        'bmobObjectId': bmobObjectId,
        'bmobCreatedAt': bmobCreatedAt,
        'bmobUpdatedAt': bmobUpdatedAt,
      };
}

///
/// [PersonItem] 人物对象的class定义，需要用到数据库和引用计数，所以扩展自[ReferencesBoxItem]
///
/// [gender]数值: 0->Female, 1->Male, 2->None
///
class PersonItem extends ReferencesBoxItem
    with
        BuildImageMixin,
        DetailsListMixin<FocusEvent>,
        GetPersonChineseStringMixin {
  PersonItem({
    this.name = '',
    this.gender = 2,
    this.birthday,
    photo = '',
    boxId = 0,
    count = 0,
    bmobObjectId,
    bmobCreatedAt,
    bmobUpdatedAt,
  }) : super(
          boxId: boxId,
          count: count,
          bmobObjectId: bmobObjectId,
          bmobCreatedAt: bmobCreatedAt,
          bmobUpdatedAt: bmobUpdatedAt,
        ) {
    setMixinImageSource(photo);
    setMixinDarkSource('assets/image/defaultPersonPhoto1.png');
    setMixinLightSource('assets/image/defaultPersonPhoto2.png');
  }

  String getLabel() => name;
  String get photo => mixinImage;
  bool hasPhoto() => hasImage();
  bool hasBirthday() => birthday != null;

  String name;
  int gender;
  DateTime birthday;
  double height;
  double weight;

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
    //birthday = DateTime(other.birthday.year, other.birthday.month, other.birthday.day);
    birthday = other.birthday;
    height = other.height;
    weight = other.weight;
    if (mixinImage != other.mixinImage) {
      setMixinImageSource(other.mixinImage);
    }
    boxId = other.boxId;
    count = other.count;
    bmobObjectId = other.bmobObjectId;
    bmobCreatedAt = other.bmobCreatedAt;
    bmobUpdatedAt = other.bmobUpdatedAt;
  }

  factory PersonItem.fromJson(Map<String, dynamic> json) {
    String _birthday = json['birthday'];
    return PersonItem(
      name: json['name'],
      photo: json['photo'],
      gender: json['gender'],
      birthday: _birthday == '' ? null : DateTime.parse(_birthday),
      boxId: json['boxId'],
      count: json['count'],
      bmobObjectId: json['bmobObjectId'],
      bmobCreatedAt: json['bmobCreatedAt'],
      bmobUpdatedAt: json['bmobUpdatedAt'],
    );
  }

  //
  Map<String, dynamic> toJson() => {
        'name': name,
        'photo': mixinImage,
        'gender': gender,
        'birthday': hasBirthday() ? birthday.toIso8601String() : '',
        'count': count,
        'bmobObjectId': bmobObjectId,
        'bmobCreatedAt': bmobCreatedAt,
        'bmobUpdatedAt': bmobUpdatedAt,
      };
}

///
/// DailyEvents 每天的事件句柄
///

class DailyRecord extends BoxItem {
  DailyRecord(this.dayIndex);

  DailyRecord.build({
    int boxId,
    this.dayIndex,
    this.weather = '',
    bmobObjectId,
    bmobCreatedAt,
    bmobUpdatedAt,
  }) : super(
          boxId: boxId,
          bmobObjectId: bmobObjectId,
          bmobCreatedAt: bmobCreatedAt,
          bmobUpdatedAt: bmobUpdatedAt,
        );

  int dayIndex = -1;
  String weather = '';
  List<FocusEvent> focusEvents;
  List<RichLine> richLines = [];

  bool get focusEventIsNull {
    return focusEvents == null;
  }

  void initRichList(GlobalStoreState store, bool hasRelated) {
    if (richLines == null) {
      richLines = List<RichLine>();
    }
    if (richLines.isEmpty) {
      buildRichList(store, hasRelated);
    }
  }

  void buildRichList(GlobalStoreState store, bool hasRelated) {
    if (richLines == null) {
      richLines = List<RichLine>();
    } else {
      richLines.clear();
    }
    focusEvents?.forEach((event) {
      // 加入FocusTitle
      richLines.add(RichLine(
        type: RichType.FocusTitle,
        content: event.focusItemBoxId.toString(),
        note: event,
      ));
      //List<RichLine> lines = RichSource.getRichLinesFromJson(event.note);

      // 整体加入noteLines
      event.noteLines?.forEach((line) {
        line.note = event;
      });
      richLines.addAll(event.noteLines);

      if (hasRelated) {
        if (event.personKeys.hasKeys()) {
          debugPrint('加入人物引用');
          String text;
          for (int i = 0; i < event.personKeys.keyList.length; i++) {
            if (i == 0) {
              text = store.getPersonItemFromId(event.personKeys.keyList[i]).name;
            } else {
              text = text +
                  "、${store.getPersonItemFromId(event.personKeys.keyList[i]).name}";
            }
          }
          richLines.add(RichLine(
            type: RichType.Related,
            indent: 0,
            content: text,
            note: event,
          ));
        }

        if (event.placeKeys.hasKeys()) {
          debugPrint('加入地点引用');
          String text;
          for (int i = 0; i < event.placeKeys.keyList.length; i++) {
            if (i == 0) {
              //text = store.getPlaceItemFromId(event.placeKeys[i]).title;
              text =
                  store.placeSet.getItemFromId(event.placeKeys.keyList[i]).title;
            } else {
              //text = text + "、${store.getPlaceItemFromId(event.placeKeys[i]).title}";
              text = text +
                  "、${store.placeSet.getItemFromId(event.placeKeys.keyList[i]).title}";
            }
          }
          richLines.add(RichLine(
            type: RichType.Related,
            indent: 1,
            content: text,
            note: event,
          ));
        }
        if (event.tagKeys.hasKeys()) {
          debugPrint('加入标签引用');
          String text;
          for (int i = 0; i < event.tagKeys.keyList.length; i++) {
            if (i == 0) {
              text = store.tagSet.getItemFromId(event.tagKeys.keyList[i]).title;
            } else {
              text = text +
                  "、${store.tagSet.getItemFromId(event.tagKeys.keyList[i]).title}";
            }
          }
          richLines.add(RichLine(
            type: RichType.Related,
            indent: 2,
            content: text,
            note: event,
          ));
        }
      }
    });
  }

  void copyWith(DailyRecord other) {
    dayIndex = other.dayIndex;
    weather = other.weather;
    focusEvents = other.focusEvents;
    boxId = other.boxId;
    bmobObjectId = other.bmobObjectId;
    bmobCreatedAt = other.bmobCreatedAt;
    bmobUpdatedAt = other.bmobUpdatedAt;
  }

  factory DailyRecord.fromJson(Map<String, dynamic> json) {
    return DailyRecord.build(
      dayIndex: json['dayIndex'],
      weather: json['weather'],
      boxId: json['boxId'],
      bmobObjectId: json['bmobObjectId'],
      bmobCreatedAt: json['bmobCreatedAt'],
      bmobUpdatedAt: json['bmobUpdatedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
        'dayIndex': dayIndex,
        'weather': weather,
        'bmobObjectId': bmobObjectId,
        'bmobCreatedAt': bmobCreatedAt,
        'bmobUpdatedAt': bmobUpdatedAt,
      };
}

class FocusEvent extends BoxItem {
  FocusEvent({
    int boxId = 0,
    this.dayIndex = -1,
    this.focusItemBoxId = -1,
    String note = '',
    String personBoxIds,
    String placeBoxIds,
    String tagBoxIds,
    bmobObjectId,
    bmobCreatedAt,
    bmobUpdatedAt,
  }) : super(
          boxId: boxId,
          bmobObjectId: bmobObjectId,
          bmobCreatedAt: bmobCreatedAt,
          bmobUpdatedAt: bmobUpdatedAt,
        ) {
    noteLines = RichSource.getRichLinesFromJson(note);
    personKeys.fromString(personBoxIds);
    placeKeys.fromString(placeBoxIds);
    tagKeys.fromString(tagBoxIds);
  }

  int dayIndex;
  int focusItemBoxId;
  List<RichLine> noteLines;

  /// [personIds]在内容[noteLines]里面提及相关人员的boxId
  //List<int> personIds;
  LabelKeys personKeys = LabelKeys();

  /// [placeIds]在内容[noteLines]里面提及相关地点的boxId
  LabelKeys placeKeys = LabelKeys();
  //List<int> placeIds;

  /// [tagIds]在内容[noteLines]里面提及相关标签的boxId
  LabelKeys tagKeys = LabelKeys();
  //List<int> tagIds;

  void extractingPersonList(List<PersonItem> personList) {
    personKeys.fromExtracting(noteLines, personList);
  }

  void extractingPlaceList(List<PlaceItem> placeList) {
    placeKeys.fromExtracting(noteLines, placeList);
  }

//  void extractingTagList(List<TagItem> tagList) {
//    tagKeys.fromExtracting(noteLines, tagList);
//  }

  void copyWith(FocusEvent other) {
    dayIndex = other.dayIndex;
    focusItemBoxId = other.focusItemBoxId;
    noteLines = other.noteLines;
    personKeys.copyWith(other.personKeys);
    placeKeys.copyWith(other.placeKeys);
    tagKeys.copyWith(other.tagKeys);
    boxId = other.boxId;
    bmobObjectId = other.bmobObjectId;
    bmobCreatedAt = other.bmobCreatedAt;
    bmobUpdatedAt = other.bmobUpdatedAt;
  }

  factory FocusEvent.fromJson(Map<String, dynamic> json) {
    return FocusEvent(
      dayIndex: json['dayIndex'],
      focusItemBoxId: json['focusItemBoxId'],
      note: json['note'],
      personBoxIds: json['personBoxIds'],
      placeBoxIds: json['placeBoxIds'],
      tagBoxIds: json['tagBoxIds'],
      boxId: json['boxId'],
      bmobObjectId: json['bmobObjectId'],
      bmobCreatedAt: json['bmobCreatedAt'],
      bmobUpdatedAt: json['bmobUpdatedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
        'dayIndex': dayIndex,
        'focusItemBoxId': focusItemBoxId,
        'note': RichSource.getJsonFromRichLine(noteLines),
        'personBoxIds': personKeys.toString(),
        'placeBoxIds': placeKeys.toString(),
        'tagBoxIds': tagKeys.toString(),
        'bmobObjectId': bmobObjectId,
        'bmobCreatedAt': bmobCreatedAt,
        'bmobUpdatedAt': bmobUpdatedAt,
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

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/models/enums.dart';
import 'package:flutter_moment/models/helper_image.dart';
import 'package:flutter_moment/models/helper_chinese_string.dart';
import 'package:flutter_moment/models/label_management.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_data.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_widget.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_layout.dart';
import 'package:flutter_moment/task/TaskItem.dart';

class PassingObject<T> {
  PassingObject({this.oldObject, this.newObject});
  T oldObject;
  T newObject;
}

abstract class BoxItem {
  BoxItem({this.boxId = 0});
  int boxId;

  factory BoxItem.itemFromJson(Type type, Map<String, dynamic> json){
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
    }
    return null;
  }
}

abstract class ReferencesBoxItem extends BoxItem{
  ReferencesBoxItem({
    boxId = 0,
    this.references = 0,
  }): super(boxId: boxId);

  int references = 0;
  bool get isReferences => references == 0;
  bool get isNotReferences => references > 0;

  String getLabel();

  void addReferences() {
    references++;
  }

  void minusReferences() {
    references--;
    if (references < 0) references = 0;
  }

}

abstract class SystemBaseItem extends ReferencesBoxItem {
  bool systemPresets = false;
  bool internal = false;

  SystemBaseItem({
    boxId = 0,
    references = 0,
    systemPresets = false,
    internal = false,
  }) : super(
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
  }) : super();

  // 新建实例时的构建函数
  FocusItem.build({
    this.title,
    this.comment,
    int boxId = 0,
    int references = 0,
    bool systemPresets = false,
    bool internal = false,
  }) : super(
    boxId: boxId,
    references: references,
    systemPresets: systemPresets,
    internal: internal) {
    //id = DateTime.now().millisecondsSinceEpoch.toString();
  }

  String getLabel() => title;

  factory FocusItem.fromJson(Map<String, dynamic> json) {
    return FocusItem.build(
      boxId: json['boxId'],
      title: json['title'],
      comment: json['comment'],
      references: json['references'], // 引用次数
      systemPresets: json['systemPresets'], // 系统预设
      internal: json['internal'], // 内部使用
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
/// [PlaceItem] “位置”的class定义，需要用到数据库和引用计数，所以扩展自[ReferencesBoxItem]
///
/// “位置”有图片数据处理，所以混入了[BuildImageMixin]
///
class PlaceItem extends ReferencesBoxItem with BuildImageMixin, DetailsListMixin<FocusEvent> {
  PlaceItem({
    this.title = '',
    this.address = '',
    this.picture,
    boxId = 0,
    references = 0,
  }) : super(boxId: boxId, references: references) {
    setMixinImageSource(picture);
    setMixinDarkSource('assets/image/defaultPersonPhoto1.png');
    setMixinLightSource('assets/image/defaultPersonPhoto2.png');
  }

  String title;
  String address;
  double geography;
  String picture;

  bool hasTitle() => title.length > 0;
  bool hasPicture() => picture != null;

  String getLabel() => title;

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
    boxId = other.boxId;
    references = other.references;
  }

  factory PlaceItem.fromJson(Map<String, dynamic> json) {
    return PlaceItem(
      title: json['title'],
      address: json['address'],
      picture: json['picture'],
      boxId: json['boxId'],
      references: json['references'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'address': address,
        'picture': picture,
        'boxId': boxId,
        'references': references,
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
    references = 0,
  }) : super(boxId: boxId, references: references);

  bool hasTitle() => title.isNotEmpty;
  String getLabel() => title;

  void copyWith(TagItem other) {
    title = other.title;
    boxId = other.boxId;
    references = other.references;
  }

  factory TagItem.fromJson(Map<String, dynamic> json) {
    return TagItem(
      title: json['title'],
      boxId: json['boxId'],
      references: json['references'],
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'boxId': boxId,
    'references': references,
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
  }) : super(boxId: boxId, references: references) {
    setMixinImageSource(photo);
    setMixinDarkSource('assets/image/defaultPersonPhoto1.png');
    setMixinLightSource('assets/image/defaultPersonPhoto2.png');
  }

  String getLabel() => name;
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
    //birthday = DateTime(other.birthday.year, other.birthday.month, other.birthday.day);
    birthday = other.birthday;
    height = other.height;
    weight = other.weight;
    if (mixinImage != other.mixinImage) {
      setMixinImageSource(other.mixinImage);
    }
    boxId = other.boxId;
    references = other.references;
  }

  factory PersonItem.fromJson(Map<String, dynamic> json) {
    String _birthday = json['birthday'];
    return PersonItem(
        name: json['name'],
        photo: json['photo'],
        gender: json['gender'],
        birthday: _birthday == '' ? null : DateTime.parse(_birthday),
        boxId: json['boxId'],
        references: json['references']);
  }

  //
  Map<String, dynamic> toJson() => {
        'name': name,
        'photo': mixinImage,
        'gender': gender,
        'birthday': hasBirthday() ? birthday.toIso8601String() : '',
        'boxId': boxId,
        'references': references,
      };
}

///
/// DailyEvents 每天的事件句柄
///

class DailyRecord {
  DailyRecord(this.dayIndex);

  DailyRecord.build({
    this.boxId,
    this.dayIndex,
    this.weather = '',
    var focusEventsOfJson,
  }) {
    var list = focusEventsOfJson as List;
    focusEvents = list.map((item) => FocusEvent.fromJson(item)).toList();
  }

  int boxId = 0;
  int dayIndex = -1;
  //DateTime date;
  String weather = '';
  List<FocusEvent> focusEvents = [];
  List<RichLine> richLines = [];

  bool get isNull {
    if (focusEvents == null) focusEvents = [];
    return weather.isEmpty && focusEvents.length == 0;
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
          for (int i = 0; i < event.personKeys.list.length; i++) {
            if (i == 0) {
              text = store.getPersonItemFromId(event.personKeys.list[i]).name;
            } else {
              text = text +
                  "、${store.getPersonItemFromId(event.personKeys.list[i]).name}";
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
          print('加入地点引用');
          String text;
          for (int i = 0; i < event.placeKeys.list.length; i++) {
            if (i == 0) {
              //text = store.getPlaceItemFromId(event.placeKeys[i]).title;
              text = store.placeSet.getItemFromId(event.placeKeys.list[i]).title;
            } else {
              //text = text + "、${store.getPlaceItemFromId(event.placeKeys[i]).title}";
              text = text + "、${store.placeSet.getItemFromId(event.placeKeys.list[i]).title}";
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
          print('加入标签引用');
          String text;
          for (int i = 0; i < event.tagKeys.list.length; i++) {
            if (i == 0) {
              text = store.tagSet.getItemFromId(event.tagKeys.list[i]).title;
            } else {
              text = text + "、${store.tagSet.getItemFromId(event.tagKeys.list[i]).title}";
            }
          }
          richLines.add(RichLine(
            type: RichType.Related,
            indent: 1,
            content: text,
            note: event,
          ));
        }
      }
    });
  }

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
  FocusEvent({
    this.boxId = 0,
    this.dayIndex = -1,
    this.focusItemBoxId = -1,
    String note = '',
    String personBoxIds,
    String placeBoxIds,
    String tagBoxIds,
  }) {
    //personIds = StringExt.stringToListInt(personBoxIds);
    //placeIds = StringExt.stringToListInt(placeBoxIds);
    //tagIds = StringExt.stringToListInt(tagBoxIds);
    noteLines = RichSource.getRichLinesFromJson(note);

    personKeys.fromString(personBoxIds);
    placeKeys.fromString(placeBoxIds);
    tagKeys.fromString(tagBoxIds);

  }

  int boxId;
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

  void extractingTagList(List<TagItem> tagList) {
    tagKeys.fromExtracting(noteLines, tagList);
  }

  void copyWith(FocusEvent other) {
    boxId = other.boxId;
    dayIndex = other.dayIndex;
    focusItemBoxId = other.focusItemBoxId;
    noteLines = other.noteLines;
    //personIds = other.personIds.sublist(0);
    personKeys.copyWith(other.personKeys);
    placeKeys.copyWith(other.placeKeys);
    tagKeys.copyWith(other.tagKeys);
    //note = other.note;
  }

  factory FocusEvent.fromJson(Map<String, dynamic> json) {
    return FocusEvent(
      boxId: json['boxId'],
      dayIndex: json['dayIndex'],
      focusItemBoxId: json['focusItemBoxId'],
      note: json['note'],
      personBoxIds: json['personBoxIds'],
      placeBoxIds: json['placeBoxIds'],
      tagBoxIds: json['tagBoxIds'],
    );
  }

  Map<String, dynamic> toJson() => {
    'boxId': boxId,
    'dayIndex': dayIndex,
    'focusItemBoxId': focusItemBoxId,
    'note': RichSource.getJsonFromRichLine(noteLines),
    //'personBoxIds': StringExt.listIntToString(personIds),
    'personBoxIds': personKeys.toString(),
    'placeBoxIds': placeKeys.toString(),
    'tagBoxIds': tagKeys.toString(),
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

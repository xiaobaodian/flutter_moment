import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/models/enums.dart';
import 'package:flutter_moment/models/helper_image.dart';
import 'package:flutter_moment/models/helper_chinese_string.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_data.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_widget.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_layout.dart';

class PassingObject<T> {
  PassingObject({this.oldObject, this.newObject});
  T oldObject;
  T newObject;
}

class BoxItem {
  int boxId = 0;
  int references = 0;

  BoxItem({
    this.boxId = 0,
    this.references = 0,
  });

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
    }
    return null;
  }

  bool get isReferences => references == 0;
  bool get isNotReferences => references > 0;

  void addReferences() {
    references++;
  }

  void minusReferences() {
    references--;
    if (references < 0) references = 0;
  }

}

abstract class SystemBaseItem extends BoxItem {
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
/// PlaceItem 定义
///
class PlaceItem extends BoxItem with BuildImageMixin {
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
  }) : super(boxId: boxId, references: references) {
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
/// TagItem 定义
///
class TagItem extends BoxItem {
  String title;

  TagItem({
    this.title = '',
    boxId = 0,
    references = 0,
  }) : super(boxId: boxId, references: references);

  bool hasTitle() => title.isNotEmpty;

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
/// [gender]数值: 0->Female, 1->Male, 2->None
///
class PersonItem extends BoxItem
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
        if (event.personIds.length > 0) {
          print('加入人物引用');
          String text;
          for (int i = 0; i < event.personIds.length; i++) {
            if (i == 0) {
              text = store.getPersonItemFromId(event.personIds[i]).name;
            } else {
              text = text +
                  "、${store.getPersonItemFromId(event.personIds[i]).name}";
            }
          }
          richLines.add(RichLine(
            type: RichType.Related,
            indent: 0,
            content: text,
            note: event,
          ));
        }
        if (event.placeIds.length > 0) {
          print('加入地点引用');
          String text;
          for (int i = 0; i < event.placeIds.length; i++) {
            if (i == 0) {
              //text = store.getPlaceItemFromId(event.placeKeys[i]).title;
              text = store.placeSet.getItemFromId(event.placeIds[i]).title;
            } else {
              //text = text + "、${store.getPlaceItemFromId(event.placeKeys[i]).title}";
              text = text + "、${store.placeSet.getItemFromId(event.placeIds[i]).title}";
            }
          }
          richLines.add(RichLine(
            type: RichType.Related,
            indent: 1,
            content: text,
            note: event,
          ));
        }
        if (event.tagIds.length > 0) {
          print('加入标签引用');
          String text;
          for (int i = 0; i < event.tagIds.length; i++) {
            if (i == 0) {
              //text = store.getPlaceItemFromId(event.tagKeys[i]).title;
              text = store.tagSet.getItemFromId(event.tagIds[i]).title;
            } else {
              //text = text + "、${store.getPlaceItemFromId(event.tagKeys[i]).title}";
              text = text + "、${store.tagSet.getItemFromId(event.tagIds[i]).title}";
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
    noteLines = RichSource.getRichLinesFromJson(note);
    personIds = StringExt.stringToListInt(personBoxIds);
    placeIds = StringExt.stringToListInt(placeBoxIds);
    tagIds = StringExt.stringToListInt(tagBoxIds);
  }

  int boxId;
  int dayIndex;
  int focusItemBoxId;
  List<RichLine> noteLines;

  /// [personIds]在内容[noteLines]里面提及相关人员的boxId
  List<int> personIds;

  /// [placeIds]在内容[noteLines]里面提及相关地点的boxId
  List<int> placeIds;

  /// [tagIds]在内容[noteLines]里面提及相关标签的boxId
  List<int> tagIds;


  void extractingPersonList(List<PersonItem> personList) {
    personIds.clear();
    for (var line in noteLines) {
      for (var person in personList) {
        if (line.getContent().indexOf(person.name) > -1) {
          debugPrint('找到了：${person.name}');
          if (personIds.indexOf(person.boxId) == -1) {
            personIds.add(person.boxId);
          }
        }
      }
    }
  }

  void extractingPlaceList(List<PlaceItem> placeList) {
    placeIds.clear();
    for (var line in noteLines) {
      for (var place in placeList) {
        if (line.getContent().contains(place.title)) {
          debugPrint('找到了：${place.title}');
          if (placeIds.indexOf(place.boxId) == -1) {
            placeIds.add(place.boxId);
          }
        }
      }
    }
  }

  void extractingTagList(List<TagItem> tagList) {
    tagIds.clear();
    for (var line in noteLines) {
      for (var tag in tagList) {
        if (line.getContent().contains(tag.title)) {
          debugPrint('找到了：${tag.title}');
          if (tagIds.indexOf(tag.boxId) == -1) {
            tagIds.add(tag.boxId);
          }
        }
      }
    }
  }

  void copyWith(FocusEvent other) {
    boxId = other.boxId;
    dayIndex = other.dayIndex;
    focusItemBoxId = other.focusItemBoxId;
    noteLines = other.noteLines;
    personIds = other.personIds.sublist(0);
    placeIds = other.placeIds.sublist(0);
    tagIds = other.tagIds.sublist(0);
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
    'personBoxIds': StringExt.listIntToString(personIds),
    'placeBoxIds': StringExt.listIntToString(placeIds),
    'tagBoxIds': StringExt.listIntToString(tagIds),
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

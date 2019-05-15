import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/models/enums.dart';
import 'package:flutter_moment/models/helper_image.dart';
import 'package:flutter_moment/models/helper_chinese_string.dart';
import 'package:flutter_moment/models/data_helper.dart';
import 'package:flutter_moment/richnote/cccat_rich_note_data.dart';
import 'package:flutter_moment/task/task_item.dart';

class DiffObject<T> {
  DiffObject({this.oldObject, this.newObject});
  T oldObject;
  T newObject;
}

abstract class BoxItem {
  BoxItem({
    this.boxId = 0,
    this.timeId = 0,
    this.objectId,
    this.createdAt,
    this.updatedAt,
  });

  int boxId;
  int timeId;
  String objectId;
  String createdAt;
  String updatedAt;

  bool get isNew => timeId == 0;
  bool get isOld => timeId > 0;

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
    timeId = 0,
    this.count = 0,
    objectId,
    createdAt,
    updatedAt,
  }) : super(
        boxId: boxId,
        timeId: timeId,
        objectId: objectId,
        createdAt: createdAt,
        updatedAt: updatedAt);

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
    timeId = 0,
    count = 0,
    this.presets = false,
    this.internal = false,
    objectId,
    createdAt,
    updatedAt,
  }) : super(
            boxId: boxId,
            timeId: timeId,
            count: count,
      objectId: objectId,
      createdAt: createdAt,
      updatedAt: updatedAt);

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
    objectId,
    createdAt,
    updatedAt,
  }) : super(
      objectId: objectId,
      createdAt: createdAt,
      updatedAt: updatedAt);

  // 新建实例时的构建函数
  FocusItem.build({
    this.title,
    this.comment,
    int boxId = 0,
    int timeId = 0,
    int count = 0,
    bool presets = false,
    bool internal = false,
    objectId,
    createdAt,
    updatedAt,
  }) : super(
          boxId: boxId,
          timeId: timeId,
          count: count,
          presets: presets,
          internal: internal,
    objectId: objectId,
    createdAt: createdAt,
    updatedAt: updatedAt,
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
    timeId = other.timeId;
    count = other.count;
    objectId = other.objectId;
    createdAt = other.createdAt;
    updatedAt = other.updatedAt;
  }

  factory FocusItem.fromJson(Map<String, dynamic> json) {
    return FocusItem.build(
      title: json['title'],
      comment: json['comment'],
      count: json['count'], // 引用次数
      presets: json['presets'] == 1, // 系统预设
      internal: json['internal'] == 1, // 内部使用
      boxId: json['boxId'],
      timeId: json['timeId'],
      objectId: json['objectId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'comment': comment,
        'count': count,
        'presets': presets ? 1 : 0,
        'internal': internal ? 1 : 0,
        'timeId': timeId,
        'objectId': objectId,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
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
    timeId = 0,
    count = 0,
    objectId,
    createdAt,
    updatedAt,
  }) : super(
          boxId: boxId,
          timeId: timeId,
          count: count,
    objectId: objectId,
    createdAt: createdAt,
    updatedAt: updatedAt,
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
    timeId = other.timeId;
    count = other.count;
    objectId = other.objectId;
    createdAt = other.createdAt;
    updatedAt = other.updatedAt;
  }

  factory PlaceItem.fromJson(Map<String, dynamic> json) {
    return PlaceItem(
      title: json['title'],
      address: json['address'],
      coverPicture: json['coverPicture'],
      boxId: json['boxId'],
      count: json['count'],
      timeId: json['timeId'],
      objectId: json['objectId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'address': address,
        'coverPicture': coverPicture,
        'count': count,
        'timeId': timeId,
        'objectId': objectId,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
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
    timeId = 0,
    count = 0,
    objectId,
    createdAt,
    updatedAt,
  }) : super(
          boxId: boxId,
          timeId: timeId,
          count: count,
    objectId: objectId,
    createdAt: createdAt,
    updatedAt: updatedAt,
        );

  bool hasTitle() => title.isNotEmpty;
  String getLabel() => title;

  void copyWith(TagItem other) {
    title = other.title;
    boxId = other.boxId;
    timeId = other.timeId;
    count = other.count;
    objectId = other.objectId;
    createdAt = other.createdAt;
    updatedAt = other.updatedAt;
  }

  factory TagItem.fromJson(Map<String, dynamic> json) {
    return TagItem(
      title: json['title'],
      boxId: json['boxId'],
      timeId: json['timeId'],
      count: json['count'],
      objectId: json['objectId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'count': count,
        'timeId': timeId,
        'objectId': objectId,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
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
    this.nickname = '',
    this.gender = 2,
    this.birthday,
    photo = '',
    boxId = 0,
    timeId = 0,
    count = 0,
    this.username = '',
    objectId,
    createdAt,
    updatedAt,
  }) : super(
    boxId: boxId,
    timeId: timeId,
    count: count,
    objectId: objectId,
    createdAt: createdAt,
    updatedAt: updatedAt,
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
  String nickname;
  int gender;
  DateTime birthday;
  double height;
  double weight;

  String username;

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
    nickname = other.nickname;
    gender = other.gender;
    birthday = other.birthday;
    height = other.height;
    weight = other.weight;
    if (mixinImage != other.mixinImage) {
      setMixinImageSource(other.mixinImage);
    }
    boxId = other.boxId;
    timeId = other.timeId;
    count = other.count;
    username = other.username;
    objectId = other.objectId;
    createdAt = other.createdAt;
    updatedAt = other.updatedAt;
  }

  factory PersonItem.fromJson(Map<String, dynamic> json) {
    String _birthday = json['birthday'];
    return PersonItem(
      name: json['name'],
      nickname: json['nickname'],
      photo: json['photo'],
      gender: json['gender'],
      birthday: _birthday == '' ? null : DateTime.parse(_birthday),
      boxId: json['boxId'],
      timeId: json['timeId'],
      count: json['count'],
      username: json['username'],
      objectId: json['objectId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  //
  Map<String, dynamic> toJson() => {
        'name': name,
        'nickname': nickname,
        'photo': mixinImage,
        'gender': gender,
        'birthday': hasBirthday() ? birthday.toIso8601String() : '',
        'count': count,
        'username': username,
        'timeId': timeId,
        'objectId': objectId,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

///
/// UserAccount
///
class UserItem extends ReferencesBoxItem
    with
        BuildImageMixin,
        DetailsListMixin<FocusEvent>,
        GetPersonChineseStringMixin {
  UserItem({
    this.name = '',
    this.nickname = '',
    this.gender = 2,
    this.birthday,
    photo = '',
    boxId = 0,
    timeId = 0,
    count = 0,
    this.username = '',
    this.password = '',
    this.email = '',
    this.emailVerified = false,
    this.mobilePhoneNumber = '',
    this.mobilePhoneNumberVerified = false,
    objectId,
    createdAt,
    updatedAt,
  }) : super(
    boxId: boxId,
    timeId: timeId,
    count: count,
    objectId: objectId,
    createdAt: createdAt,
    updatedAt: updatedAt,
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
  String nickname;
  int gender;
  DateTime birthday;
  double height;
  double weight;

  String username;
  String password;
  String email;
  bool emailVerified;
  String mobilePhoneNumber;
  bool mobilePhoneNumberVerified;
  String sessionToken;

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

  void copyWith(UserItem other) {
    name = other.name;
    nickname = other.nickname;
    gender = other.gender;
    birthday = other.birthday;
    height = other.height;
    weight = other.weight;
    if (mixinImage != other.mixinImage) {
      setMixinImageSource(other.mixinImage);
    }
    boxId = other.boxId;
    timeId = other.timeId;
    count = other.count;
    username = other.username;
    password = other.password;
    email = other.email;
    emailVerified = other.emailVerified;
    mobilePhoneNumber = other.mobilePhoneNumber;
    mobilePhoneNumberVerified = other.mobilePhoneNumberVerified;
    objectId = other.objectId;
    createdAt = other.createdAt;
    updatedAt = other.updatedAt;
  }

  factory UserItem.fromJson(Map<String, dynamic> json) {
    String _birthday = json['birthday'];
    return UserItem(
      name: json['name'],
      nickname: json['nickname'],
      photo: json['photo'],
      gender: json['gender'],
      birthday: _birthday == '' ? null : DateTime.parse(_birthday),
      boxId: json['boxId'],
      timeId: json['timeId'],
      count: json['count'],
      username: json['username'],
      password: json['password'],
      email: json['email'],
      emailVerified: json['emailVerified'] == 1,
      mobilePhoneNumber: json['mobilePhoneNumber'],
      mobilePhoneNumberVerified: json['mobilePhoneNumberVerified'] == 1,
      objectId: json['objectId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  //
  Map<String, dynamic> toJson() => {
    'name': name,
    'nickname': nickname,
    'photo': mixinImage,
    'gender': gender,
    'birthday': hasBirthday() ? birthday.toIso8601String() : '',
    'count': count,
    'username': username,
    'password': password,
    'email': email,
    'emailVerified': emailVerified ? 1 : 0,
    'mobilePhoneNumber': mobilePhoneNumber,
    'mobilePhoneNumberVerified': mobilePhoneNumberVerified ? 1 : 0,
    'timeId': timeId,
    'objectId': objectId,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}


///
/// DailyEvents 每天的事件句柄
///

class DailyRecord extends BoxItem {
  DailyRecord(this.dayIndex);

  DailyRecord.build({
    int boxId,
    int timeId,
    this.dayIndex,
    this.weather = '',
    objectId,
    createdAt,
    updatedAt,
  }) : super(
    boxId: boxId,
    timeId: timeId,
    objectId: objectId,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  int dayIndex = -1;
  String weather = '';
  List<FocusEvent> focusEvents;
  List<RichLine> richLines = [];

  bool get focusEventsIsNull {
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
    focusEvents.forEach((event) {
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
              text = store.personSet.getItemFromId(event.personKeys.keyList[i]).name;
            } else {
              text = text +
                  "、${store.personSet.getItemFromId(event.personKeys.keyList[i]).name}";
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
              text =
                  store.placeSet.getItemFromId(event.placeKeys.keyList[i]).title;
            } else {
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
    timeId = other.timeId;
    objectId = other.objectId;
    createdAt = other.createdAt;
    updatedAt = other.updatedAt;
  }

  factory DailyRecord.fromJson(Map<String, dynamic> json) {
    return DailyRecord.build(
      dayIndex: json['dayIndex'],
      weather: json['weather'],
      boxId: json['boxId'],
      timeId: json['timeId'],
      objectId: json['objectId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
    'dayIndex': dayIndex,
    'weather': weather,
    'timeId': timeId,
    'objectId': objectId,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

class FocusEvent extends BoxItem {
  FocusEvent({
    int boxId = 0,
    int timeId = 0,
    this.dayIndex = -1,
    this.focusItemBoxId = -1,
    String note = '',
    String personTags,
    String placeTags,
    String tags,
    objectId,
    createdAt,
    updatedAt,
  }) : super(
      boxId: boxId,
      timeId: timeId,
      objectId: objectId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    ) {
    noteLines = RichSource.getRichLinesFromJson(note);
    personKeys.fromString(personTags);
    placeKeys.fromString(placeTags);
    tagKeys.fromString(tags);
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

  void removeTask(TaskItem task) {
    noteLines.removeWhere((line) {
      if (line.type != RichType.Task) {
        return false;
      }
      if (line.expandData is int) {
        return line.expandData == task.timeId;
      } else if (line.expandData is TaskItem) {
        return (line.expandData as TaskItem).timeId == task.timeId;
      }
    });
  }

  void copyWith(FocusEvent other) {
    dayIndex = other.dayIndex;
    focusItemBoxId = other.focusItemBoxId;
    noteLines = other.noteLines;
    personKeys.copyWith(other.personKeys);
    placeKeys.copyWith(other.placeKeys);
    tagKeys.copyWith(other.tagKeys);
    boxId = other.boxId;
    timeId = other.timeId;
    objectId = other.objectId;
    createdAt = other.createdAt;
    updatedAt = other.updatedAt;
  }

  factory FocusEvent.fromJson(Map<String, dynamic> json) {
    return FocusEvent(
      dayIndex: json['dayIndex'],
      focusItemBoxId: json['focusItemBoxId'],
      note: json['note'],
      personTags: json['personTags'],
      placeTags: json['placeTags'],
      tags: json['tags'],
      boxId: json['boxId'],
      timeId: json['timeId'],
      objectId: json['objectId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
    'dayIndex': dayIndex,
    'focusItemBoxId': focusItemBoxId,
    'note': RichSource.getJsonFromRichLine(noteLines),
    'personTags': personKeys.toString(),
    'placeTags': placeKeys.toString(),
    'tags': tagKeys.toString(),
    'timeId': timeId,
    'objectId': objectId,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
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

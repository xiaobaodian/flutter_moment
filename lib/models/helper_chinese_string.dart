mixin GetPersonChineseStringMixin {

  String getGenderChineseString(int gender) {
    if (gender == 1) {
      return '男';
    } else if (gender == 0) {
      return '女';
    }
    return '';
  }

  String getBirthdayChineseString(DateTime birthday) {
    return '${birthday.year}年${birthday.month}月${birthday.day}日';
  }
}

class StringExt {
  static String listIntToString(List<int> list, {String split = '|'}) {
    String text;
    for (int i = 0; i < list.length; i++) {
      if (i == 0) {
        text = list[i].toString();
      } else {
        text = text + "|${list[i].toString()}";
      }
    }
    return text;
  }

  static List<int> stringToListInt(String text, {String split = '|'}) {
    print('stringToListInt => text: $text');
    List<int> list = [];
    if (text != null) {
      list = text.split('|').map((key) => int.parse(key)).toList();
    }
    return list;
  }

  static String listStringToString(List<String> list, {String split = '、'}) {
    if (list.isEmpty) return '';
    String result;
    for (int i = 0; i < list.length; i++) {
      if (i == 0) {
        result = list[i];
      } else {
        result = result + '$split${list[i]}';
      }
    }
    return result;
  }
}

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


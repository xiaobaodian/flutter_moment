// 1月3月5月7月8月10月12月为大月31天,
// 4月6月9月11月为小月30天,
// 2月闰年是29天,平年是28天.
// 年份能被4整除【如年份是整百数的能被400整除】的为闰年.

import 'global_store.dart';

class DateTimeExt {
    DateTimeExt(this.dateTime) {
    firstDayOfMonth = DateTime(dateTime.year, dateTime.month, 1);
  }

  static String chineseDateString(DateTime date, {bool short = true}) {
    if (short) {
      var now = DateTime.now();
      if (now.year == date.year && now.month == date.month) {
        return '${date.day}日';
      } else if (now.year == date.year) {
        return '${date.month}月${date.day}日';
      }
    }
    return '${date.year}年${date.month}月${date.day}日';
  }
  static String chineseMonthNumber(DateTime date) {
    const name = ['一','二','三','四','五','六','七','八','九','十','十一','十二'];
    return name[date.month - 1];
  }
  static String chineseWeekName(DateTime date, {bool longName = false}) {
    if (longName) {
      const title = ['星期一','星期二','星期三','星期四','星期五','星期六','星期日'];
      return title[date.weekday - 1];
    } else {
      const title = ['周一','周二','周三','周四','周五','周六','周日'];
      return title[date.weekday - 1];
    }
  }

  /// 判断是不是闰年
  static bool isLeapYear(int year) {
    return (year % 100 != 0 && year % 4 == 0) || year % 400 == 0;
  }

  /// 返回该月有几天
  static int monthDaysFrom(int year, int month) {
    assert(year >= 1900 && year <=2200 );
    assert(month >= 1 && month <=12 );
    int days = 0;
    if (month == 2) {
      days = isLeapYear(year) ? 29 : 28;
    } else if (month == 4 || month == 6 ||month == 9 || month == 11) {
      days = 30;
    } else {
      days = 31;
    }
    return days;
  }

  /// 返回一年的天数
  static int yearDaysFrom(int year){
    return isLeapYear(year) ? 366 : 365;
  }

  DateTime dateTime;
  DateTime firstDayOfMonth;
  List<DateTime> _dayArray;

  int get year => dateTime.year;
  int get month => dateTime.month;
  int get day => dateTime.day;
  bool get isLeap => DateTimeExt.isLeapYear(year);

  /// [weekday]返回当前日期是星期几
  int get weekday => dateTime.weekday;

  /// [firstWeekDayOfMonth]返回本月第一天是星期几
  int get firstWeekDayOfMonth => firstDayOfMonth.weekday;

  /// 当月一共有几周
  int get fewWeeks => ((firstWeekDayOfMonth + getMonthDays() - 1) / 7 + 0.99).toInt();
  DateTime get date => dateTime;

  /// [getMonthDays]返回指定月的天数，如果不传参数，就默认当前月
  int getMonthDays({int month}) {
    int m = month == null ? dateTime.month : month;
    assert(m >= 1 && m <=12 );
    int days = 0;
    if (m == 2) {
      days = isLeap ? 29 : 28;
    } else if (m == 4 || m == 6 ||m == 9 || m == 11) {
      days = 30;
    } else {
      days = 31;
    }
    return days;
  }

  /// 根据当前月份的周数跨度，构建day的列表，当第一周的前几天或最后一周的后几天不在本月时，填充null
  void _buildDayArray() {
    _dayArray = List<DateTime>();
    var d = 0;
    for (int i = 1; i <= fewWeeks * 7; i++) {
      if (i < firstWeekDayOfMonth || i >= firstWeekDayOfMonth + getMonthDays()) {
        _dayArray.add(null);
      } else {
        _dayArray.add(firstDayOfMonth.add(Duration(days: d++)));
      }
    }
  }

  /// 给定本月第几周的索引，返回这周的每天列表
  List<DateTime> getDaysOfWeek(int weekIndex) {
    if (_dayArray == null) {
      _buildDayArray();
    }
    int b = (weekIndex - 1) * 7;
    return _dayArray.sublist(b, b + 7);
  }

  List<DateTime> getDaysOfWeekExt(int weekIndex) {
    var days = List<DateTime>();
    int begin = (weekIndex - 1) * 7 + 1;
    for (int i = begin; i < begin + 7; i++) {
      int day = (i - firstWeekDayOfMonth) + 1;
      if (day < 1 || day > getMonthDays()) {
        days.add(null);
      } else {
        days.add(DateTime(dateTime.year, dateTime.month, day));
      }
    }
    return days;
  }
}

class TimePoint {
  TimePoint() {
    hour = -1;
    min = -1;
  }
  TimePoint.build(this.hour, this.min);

  int hour;
  int min;

  bool get isEmpty => hour == -1;

  void clear() {
    hour = -1;
    min = -1;
  }

  int compareTo(TimePoint other) {
    if (hour > other.hour) return 1;
    if (hour < other.hour) return -1;
    if (min > other.min) return 1;
    if (min < other.min) return -1;
    return 0;
  }

  int compareToDateTime(DateTime date) {
    return compareTo(TimePoint.build(date.hour, date.minute));
  }

  void copyWith(TimePoint other) {
    hour = other.hour;
    min = other.min;
  }

  factory TimePoint.fromString(String str) {
    var time = str.split(':');
    return TimePoint.build(int.parse(time[0]), int.parse(time[1]));
  }

  void loadFromString(String str) {
    if (str == null) return;
    var time = str.split(':');
    hour = int.parse(time[0]);
    min = int.parse(time[1]);
  }

  String toString() {
    return '${hour == 0 ? "00" : hour.toString()}:${min == 0 ? "00" : hour.toString()}';
  }
}

class TimeRange {
  TimeRange({
    this.start,
    this.end
  });

  TimePoint start;
  TimePoint end;

  String toString() {
    return '${start.toString()} - ${end.toString()}';
  }
}

class TimeLineTools {
  TimeLineTools(this._store);

  GlobalStoreState _store;

  String getDateTitle(int dayIndex) {
    int todayIndex = _store.calendarMap.getDateIndex();
    String name;
    if (dayIndex == todayIndex) {
      name = '今天';
    } else if (dayIndex == todayIndex - 1) {
      name = '昨天';
    } else if (dayIndex == todayIndex - 2) {
      name = '前天';
    } else if (dayIndex == todayIndex + 1) {
      name = '明天';
    } else if (dayIndex == todayIndex + 2) {
      name = '后天';
    } else {
      DateTime date = _store.calendarMap.getDateFromIndex(dayIndex);
      name = DateTimeExt.chineseDateString(date) +
          ' ' +
          DateTimeExt.chineseWeekName(date);
    }
    return name;
  }
}
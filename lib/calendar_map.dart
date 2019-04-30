import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_moment/calendar_tools.dart';
import 'package:flutter_moment/models/data_services.dart';
import 'package:flutter_moment/models/models.dart';

class CalendarMap {

  /// 一些基本参数
  final int startYear, endYear;
  final double monthBoxTitleHeight, monthBoxCellHeight;

  DateTimeExt currentDate = DateTimeExt(DateTime.now());
  int currentDateIndexed = 0;
  DateTime selectedDate = DateTime.now();

  int _weeksTotal = 0;
  int _daysTotal = 0;

  /// 每个月的偏移量
  /// String -> ['$y$m']年月组成的字符，如："201710", "20181"
  /// double -> 该月的偏移数据
  Map<String, double> everyMonthOffset;

  /// 每月第0周就是该月的标题行
  /// 按周一到周日的七天进行分组，月头和月尾不足七天的页分为一组
  List<WeekProperty> everyWeekIndex;

  /// startYear到endYear，每天的数组映射，便于PageView通过index翻页定位到天
  List<DateProperty> everyDayIndex;

  CalendarMap({
    this.startYear = 2000,
    this.endYear = 2050,
    this.monthBoxTitleHeight = 48,
    this.monthBoxCellHeight = 48,
  }) {
    everyMonthOffset = Map<String, double>();
    everyWeekIndex = List<WeekProperty>();
    everyDayIndex = List<DateProperty>();

    /// 用于计算偏移合计的临时变量
    double _offsetSum = 0;

    for (int y = startYear; y <= endYear; y++) {
      for (int m = 1; m <= 12; m++) {
        everyMonthOffset['$y$m'] = _offsetSum;
        int weeks = DateTimeExt(DateTime(y, m)).fewWeeks;    // 计算每月周数的方法以后要单独成一个函数，不用每次创建对象
        double offset = monthBoxTitleHeight + monthBoxCellHeight * weeks;
        _offsetSum += offset;
        // 第0周就是每月的标题行
        for (int w = 0; w <= weeks; w++) {
          everyWeekIndex.add(WeekProperty(y, m, w));
          _weeksTotal++;
        }
      }
    }

    /// 开始计算天数总和
    for (int y = startYear; y <= endYear; y++) {
      _daysTotal += DateTimeExt.yearDaysFrom(y);
    }

    /// 开始构建从startYear到endYear期间每天的映射数组
    for (int y = startYear; y <= endYear; y++) {
      for (int m = 1; m <= 12; m++) {
        for (int d = 1; d <= DateTimeExt.monthDaysFrom(y, m); d++){
          everyDayIndex.add(DateProperty(y, m, d));
        }
      }
    }
    currentDateIndexed = getDateIndex(currentDate.date);

    debugPrint('currentDateIndexed: $currentDateIndexed');
  }

  void initCurrentDate() {
    currentDate = DateTimeExt(DateTime.now());
    currentDateIndexed = getDateIndex(currentDate.date);
  }

  /// [weeksTotal]返回从startYear到endYear期间的周数
  int get weeksTotal => _weeksTotal;

  /// [daysTotal]返回从startYear到endYear期间的天数
  int get daysTotal => _daysTotal;

  /// [getMonthOffset]给定日期所在月份的偏移量
  double getMonthOffset(DateTime date) => everyMonthOffset['${date.year}${date.month}'];

  /// [todayOffset]today所在月的偏移
  double get todayOffset => everyMonthOffset['${currentDate.year}${currentDate.month}'];

  /// [selectedDayOffset]selectedDay所在月的偏移
  double get selectedDayOffset => everyMonthOffset['${selectedDate.year}${selectedDate.month}'];

  /// [getWeekPropertyFromIndex]按照索引给出周的日期属性
  WeekProperty getWeekPropertyFromIndex(int index) => everyWeekIndex[index];

  /// [isToday]判断给定日期是不是今天
  bool isToday(DateTime date) => date.year == currentDate.year &&
      date.month == currentDate.month &&
      date.day == currentDate.day;

  /// [isSelectedDate]判断给定日期是当前界面选择的日期
  bool isSelectedDate(DateTime date) => date.year == selectedDate.year &&
      date.month == selectedDate.month &&
      date.day == selectedDate.day;

  /// [isNotSelectedDate]判断给定日期不是当前界面选择的日期
  bool isNotSelectedDate(DateTime date) => !isSelectedDate(date);

  /// [selectedDateIndex]返回当前界面选择的日期的index
  int get selectedDateIndex => getDateIndex(selectedDate);

  /// [selectedDateWeekName]返回当前界面选择的日期的星期名称：周一、周二等
  String get selectedDateWeekName => DateTimeExt.chineseWeekName(selectedDate);

  /// [getDateIndex]返回给定日期的index，如果不传日期参数，就返回今天的日期index
  int getDateIndex([DateTime date]) {
    DateTime d = date == null ? DateTime.now() : date;
    assert(d.year >= startYear && d.year <= endYear);
    var time = DateTimeExt(d);
    int days = 0;
    for (int y = startYear; y <= endYear; y++) {
      if (y >= d.year) {
        break;
      } else {
        days += DateTimeExt.yearDaysFrom(y);
      }
    }
    for (int m = 1; m < 13; m++) {
      if (m < d.month) {
        days += time.getMonthDays(month: m);
      } else {
        break;
      }
    }
    days += d.day;
    return days - 1;  // 天数累加是按实际进行的，在List中，下标从0开始，所以需要-1
  }

  /// [getChineseTermOfRecentDay]返回给定日期index的近期称呼，不在[dayName]范围的则返回“X天以前”或“X天以后”
  String getChineseTermOfRecentDay(int dayIndex) {
    List<String> dayName = ['前天', '昨天', '今天', '明天', '后天'];
    int base = currentDateIndexed - 2;
    int offset = dayIndex - base;
    String dayLeap;
    if (offset < 0) {  // offset < 0 || offset > 4
      dayLeap = '${currentDateIndexed - dayIndex}天以前';
    } else if(offset > 4){
      dayLeap = '${dayIndex - currentDateIndexed}天以后';
    } else {
      dayLeap = dayName[offset];
    }
    return dayLeap;
  }

  /// [getChineseTermOfDate]返回日期的中文叫法
  String getChineseTermOfDate(int dayIndex) {
    DateTime date = everyDayIndex[dayIndex].date();
    return '${date.year}年${date.month}月${date.day}日';
  }

  /// [setSelectedDateFromIndex]根据日期index设置[selectedDate]的日期
  void setSelectedDateFromIndex(int index) {
    selectedDate = everyDayIndex[index].date();
  }

  DateTime getDateFromIndex(int index) => everyDayIndex[index].date();

  DailyRecord getDailyRecordFromIndex(int index) => everyDayIndex[index].dailyRecord;

  DailyRecord getDailyRecordFromSelectedDay() {
    if (everyDayIndex[selectedDateIndex].dailyRecord == null) {
      everyDayIndex[selectedDateIndex].dailyRecord = DailyRecord(selectedDateIndex);
    }
    return everyDayIndex[selectedDateIndex].dailyRecord;
  }

  bool hasDailyRecord(DateTime date) {
    int index = getDateIndex(date);
    return getDailyRecordFromIndex(index) != null;
  }

  List<FocusEvent> getFocusEventsFromDayIndex(int dayIndex) => getDailyRecordFromIndex(dayIndex).focusEvents;

  void clearDailyRecordOfSelectedDay() =>  everyDayIndex[selectedDateIndex].dailyRecord = null;
  void clearDailyRecordOfDayIndex(int dayIndex) => everyDayIndex[dayIndex].dailyRecord = null;

  /// [getWeekRange] 返回给定dayIndex所在周的dayIndex范围
  DayIndexRange getWeekRange(int dayIndex){
    int weekday = getDateFromIndex(dayIndex).weekday;
    int bDays = weekday - 1; // 在这周中dayIndex前面还有几天
    int eDays = 7 - weekday; // 在这周中dayIndex后面还有几天
    return DayIndexRange(dayIndex - bDays, dayIndex + eDays);
  }

  DayIndexRange getCurrentWeekRange() {
    return getWeekRange(currentDateIndexed);
  }

  DayIndexRange getNextWeekRange() {
    var thisWeek = getCurrentWeekRange();
    return DayIndexRange(thisWeek.begin + 7, thisWeek.end + 7);
  }

  DayIndexRange getLastWeekRange() {
    var thisWeek = getCurrentWeekRange();
    return DayIndexRange(thisWeek.begin - 7, thisWeek.end - 7);
  }

  /// [getMonthRange] 返回给定dayIndex所在月的dayIndex范围
  DayIndexRange getMonthRange(int dayIndex){
    DateProperty dayProperty = everyDayIndex[dayIndex];
    int monthDays = DateTimeExt.monthDaysFrom(dayProperty.year, dayProperty.month);
    int day = dayProperty.date().day;
    int bDays = day - 1; // 在这月中dayIndex前面还有几天
    int eDays = monthDays - day; // 在这月中dayIndex后面还有几天
    return DayIndexRange(dayIndex - bDays, dayIndex + eDays);
  }

  DayIndexRange getCurrentMonthRange() {
    return getMonthRange(currentDateIndexed);
  }

  DayIndexRange getNextMonthRange() {
    var thisMonth = getCurrentMonthRange();
    return getMonthRange(thisMonth.end + 1);
  }

  DayIndexRange getLastMonthRange() {
    var thisMonth = getCurrentMonthRange();
    return getMonthRange(thisMonth.begin - 1);
  }
}

class DayIndexRange {
  DayIndexRange(this.begin, this.end);
  int begin, end;
}

class WeekProperty {
  WeekProperty(this.year, this.month, this.weeks);

  int year, month, weeks;
  
  DateTime date() {
    return DateTime(year, month);
  }
}

class DateProperty {
  DateProperty(this.year, this.month, this.day);

  int year, month, day;
  DailyRecord dailyRecord;

  DateTime date() => DateTime(year, month, day);
}
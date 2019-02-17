import 'package:flutter/material.dart';


// 1月3月5月7月8月10月12月为大月31天,
// 4月6月9月11月为小月30天,
// 2月闰年是29天,平年是28天.
// 年份能被4整除【如年份是整百数的能被400整除】的为闰年.

class DateTimeExt {

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

  static bool isLeapYear(int year) {
    return (year % 100 != 0 && year % 4 == 0) || year % 400 == 0;
  }

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

  static int yearDaysFrom(int year){
    return isLeapYear(year) ? 366 : 365;
  }

  DateTime dateTime;
  DateTime firstDayOfMonth;
  List<DateTime> _dayArray;

  DateTimeExt(this.dateTime) {
    firstDayOfMonth = DateTime(dateTime.year, dateTime.month, 1);
  }

  int get year => dateTime.year;
  int get month => dateTime.month;
  int get day => dateTime.day;
  bool get isLeap => DateTimeExt.isLeapYear(year);

  int get weekday => dateTime.weekday;

  int get firstWeekDayOfMonth => firstDayOfMonth.weekday;

  // 当月一共有几周
  int get fewWeeks => ((firstWeekDayOfMonth + getMonthDays() - 1) / 7 + 0.99).toInt();
  DateTime get date => dateTime;

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
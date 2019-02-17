import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DemoData {
  
  List<QuestionItem> _questionItems;

  DemoData(){
    _questionItems = List<QuestionItem>();
    _questionItems
      ..add(QuestionItem('今天的待办事项', '计划在今天完成的事项。如果你将日期移到将来的某一天，就可以安排计划待办事项'))
      ..add(QuestionItem('工作中的问题与处置办法', '记下工作中遇到的问题，形成原因，以及采取的处置办法。多进行此类总结有利于工作能力的提升'))
      ..add(QuestionItem('家庭圈', '今天你的家庭有哪些活动值得记录？记下这美好时刻'))
      ..add(QuestionItem('朋友圈', '朋友间的趣闻和聚会也是有很多值得品味的，记下来，分享给大家'))
      ..add(QuestionItem('血拼战绩', '每天都是12.12？不记下来就不能提醒自己剁手'))
      ..add(QuestionItem('读书与知识', '提升自己的知识和见识，需要阅读，多花些时间看看书，书中自有黄金屋'))
      ..add(QuestionItem('今天的健身项目', '身体是革命的本钱，锻炼身体，保卫祖国。好身体也是快乐的源泉...'))
      ..add(QuestionItem('喵星轶事', '猫孩子们的日常点滴'))
      ..add(QuestionItem('熊孩子成长记', '猫孩子们的日常点滴'))
      ..add(QuestionItem('饮食及身体反应', '猫孩子们的日常点滴'));
  }

  QuestionItem getMainQuestionItem(int index) {
    return _questionItems[index];
  }

}

class QuestionItem {
  String title;
  String note;
  QuestionItem(this.title, this.note);
}





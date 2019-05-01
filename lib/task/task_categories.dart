import 'package:flutter/material.dart';
import 'package:flutter_moment/calendar_map.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/task/task_item.dart';
import 'package:flutter_moment/task/tree_node.dart';

class TaskCategories {
  TaskCategories(this.store){
    debugPrint('初始化TaskCategories...');
    allTasks = TreeNode<TaskItem>(
      title: '所有任务'
    );

    actionTasks = TreeNode<TaskItem>(
      title: '待执行',
      isMember: (task) {
        // 测试时使用
        if (task.dueDate == 0) {
          task.dueDate = task.createDate;
          task.startDate = task.createDate;
          store.taskSet.changeItem(task);
        }
        return task.state != TaskState.Complete && task.dueDate >= store.todayIndex;
      },
    );
    todayTasks = TreeNode<TaskItem>(
      title: '今天',
      isMember: (task) {
        todayTasks.property['DateRange'] ??= store.todayIndex;
        int today = todayTasks.property['DateRange'];
        return task.startDate <= today && task.dueDate >= today;
      },
      behavior: (arg) {
        if (arg == 1) {
          todayTasks.property.remove('DateRange');
          todayTasks.children.clear();
        }
      },
    );
    tomorrowTasks = TreeNode<TaskItem>(
      title: '明天',
      isMember: (task) {
        tomorrowTasks.property['DateRange'] ??= store.todayIndex + 1;
        int tomorrow = tomorrowTasks.property['DateRange'];
        return task.startDate == tomorrow;
      },
      behavior: (arg) {
        if (arg == 1) {
          tomorrowTasks.property.remove('DateRange');
          tomorrowTasks.children.clear();
        }
      },
    );
    afterTomorrowTasks = TreeNode<TaskItem>(
      title: '后天',
      isMember: (task) {
        afterTomorrowTasks.property['DateRange'] ??= store.todayIndex + 2;
        int afterTomorrow = afterTomorrowTasks.property['DateRange'];
        return task.startDate == afterTomorrow;
      },
      behavior: (arg) {
        if (arg == 1) {
          afterTomorrowTasks.property.remove('DateRange');
          afterTomorrowTasks.children.clear();
        }
      },
    );
    thisWeekTasks = TreeNode<TaskItem>(
      title: '这周',
      isMember: (task) {
        if (thisWeekTasks.property['DateRange'] == null) {
          DayIndexRange weekRange = store.calendarMap.getCurrentWeekRange();
          int thisWeekBeginDayIndex = store.todayIndex + 3; // 计算这周的起点，须扣除今天明天的dayIndex
          if (thisWeekBeginDayIndex > weekRange.end) {
            thisWeekTasks.property['DateRange'] = false; // 如果这周的计算起点已经超出了周范围，说明已经没有这周的分类组了
          } else {
            thisWeekTasks.property['DateRange'] = DayIndexRange(thisWeekBeginDayIndex, weekRange.end);
          }
        }
        var range = thisWeekTasks.property['DateRange'];
        if (range == false) {
          return false;
        }
        return task.startDate >= range.begin && task.startDate <= range.end;
      },
      behavior: (arg) {
        if (arg == 1) {
          thisWeekTasks.property.remove('DateRange');
          thisWeekTasks.children.clear();
        }
      },
    );
    nextWeekTasks = TreeNode<TaskItem>(
      title: '下周',
      isMember: (task) {
        if (nextWeekTasks.property['DateRange'] == null) {
          DayIndexRange weekRange = store.calendarMap.getNextWeekRange();
          int nextWeekBeginDayIndex = store.todayIndex + 3; // 计算下周的起点，须扣除今天明天的dayIndex
          if (nextWeekBeginDayIndex < weekRange.begin) {
            nextWeekBeginDayIndex = weekRange.begin; // 如果下周的计算起点小于下周的范围
          }
          nextWeekTasks.property['DateRange'] = DayIndexRange(nextWeekBeginDayIndex, weekRange.end);
        }
        DayIndexRange range = nextWeekTasks.property['DateRange'];
        return task.startDate >= range.begin && task.startDate <= range.end;
      },
      behavior: (arg) {
        if (arg == 1) {
          nextWeekTasks.property.remove('DateRange');
          nextWeekTasks.children.clear();
        }
      },
    );
    thisMonthTasks = TreeNode<TaskItem>(
      title: '这月',
      isMember: (task) {
        if (thisMonthTasks.property['DateRange'] == null) {
          DayIndexRange nextWeekRange = store.calendarMap.getNextWeekRange();
          DayIndexRange monthRange = store.calendarMap.getCurrentMonthRange();
          /// 这月的起点在下周的后一天开始计算
          int thisMonthBeginDayIndex = nextWeekRange.end + 1; // 计算这周的起点，须扣除今天明天的dayIndex
          if (thisMonthBeginDayIndex > monthRange.end) {
            thisMonthTasks.property['DateRange'] = false; // 如果这周的计算起点已经超出了周范围，说明已经没有这周的分类组了
          } else {
            thisMonthTasks.property['DateRange'] = DayIndexRange(thisMonthBeginDayIndex, monthRange.end);
          }
        }
        var range = thisMonthTasks.property['DateRange'];
        if (range == false) {
          return false;
        }
        return task.startDate >= range.begin && task.startDate <= range.end;
      },
      behavior: (arg) {
        if (arg == 1) {
          thisMonthTasks.property.remove('DateRange');
          thisMonthTasks.children.clear();
        }
      },
    );
    nextMonthTasks = TreeNode<TaskItem>(
      title: '下月',
      isMember: (task) {
        if (nextMonthTasks.property['DateRange'] == null) {
          DayIndexRange nextWeekRange = store.calendarMap.getNextWeekRange();
          DayIndexRange nextMonthRange = store.calendarMap.getNextMonthRange();
          int nextMonthBeginDayIndex = nextWeekRange.end + 1;
          if (nextMonthBeginDayIndex < nextMonthRange.begin) {
            nextMonthBeginDayIndex = nextMonthRange.begin; // 如果这月的计算起点小于这月的范围
          }
          nextMonthTasks.property['DateRange'] = DayIndexRange(nextMonthBeginDayIndex, nextMonthRange.end);
        }
        DayIndexRange range = nextMonthTasks.property['DateRange'];
        return task.startDate >= range.begin && task.startDate <= range.end;
      },
      behavior: (arg) {
        if (arg == 1) {
          nextMonthTasks.property.remove('DateRange');
          nextMonthTasks.children.clear();
        }
      },
    );

    futureTasks = TreeNode<TaskItem>(
      title: '以后',
      isMember: (task) {
        if (futureTasks.property['DateRange'] == null) {
          DayIndexRange nextMonthRange = store.calendarMap.getNextMonthRange();
          futureTasks.property['DateRange'] = nextMonthRange.end + 1;
        }
        int future = futureTasks.property['DateRange'];
        return task.startDate >= future;
      },
      behavior: (arg) {
        if (arg == 1) {
          futureTasks.property.remove('DateRange');
          futureTasks.children.clear();
        }
      },
    );
    actionTasks.addSubNode(todayTasks);
    actionTasks.addSubNode(tomorrowTasks);
    actionTasks.addSubNode(afterTomorrowTasks);
    actionTasks.addSubNode(thisWeekTasks);
    actionTasks.addSubNode(nextWeekTasks);
    actionTasks.addSubNode(thisMonthTasks);
    actionTasks.addSubNode(nextMonthTasks);
    actionTasks.addSubNode(futureTasks);

    lateTasks = TreeNode<TaskItem>(
      title: '逾期',
      isMember: (task){
        // 测试时使用
        if (task.dueDate == 0) {
          task.dueDate = task.createDate;
          task.startDate = task.createDate;
          store.taskSet.changeItem(task);
        }
        return task.state != TaskState.Complete && task.dueDate < store.todayIndex;
      },
    );
    yesterdayLateTasks = TreeNode<TaskItem>(
      title: '昨天',
      isMember: (task){
        yesterdayLateTasks.property['DateRange'] ??= store.todayIndex - 1;
        int yesterday = yesterdayLateTasks.property['DateRange'];
        return task.dueDate == yesterday;
      },
      behavior: (arg) {
        if (arg == 1) {
          yesterdayLateTasks.property.remove('DateRange');
          yesterdayLateTasks.children.clear();
        }
      },
    );
    beforeYesterdayLateTasks = TreeNode<TaskItem>(
      title: '前天',
      isMember: (task){
        beforeYesterdayLateTasks.property['DateRange'] ??= store.todayIndex - 2;
        int beforeYesterday = beforeYesterdayLateTasks.property['DateRange'];
        return task.dueDate == beforeYesterday;
      },
      behavior: (arg) {
        if (arg == 1) {
          beforeYesterdayLateTasks.property.remove('DateRange');
          beforeYesterdayLateTasks.children.clear();
        }
      },
    );
    thisWeekLateTasks = TreeNode<TaskItem>(
      title: '这周',
      isMember: (task){
        thisWeekCompleteTasks.property['DateRange'] ??= firstHalfWeek();
        var range = thisWeekCompleteTasks.property['DateRange'];
        if (range == false) {
          return false;
        }
        return task.dueDate >= range.begin && task.dueDate <= range.end;
      },
      behavior: (arg) {
        if (arg == 1) {
          thisWeekLateTasks.property.remove('DateRange');
          thisWeekLateTasks.children.clear();
        }
      },
    );
    lastWeekLateTasks = TreeNode<TaskItem>(
      title: '上周',
      isMember: (task){
        lastWeekCompleteTasks.property['DateRange'] ??= lastWeekLateRange();
        DayIndexRange range = lastWeekCompleteTasks.property['DateRange'];
        return task.dueDate >= range.begin && task.dueDate <= range.end;
      },
      behavior: (arg) {
        if (arg == 1) {
          lastWeekLateTasks.property.remove('DateRange');
          lastWeekLateTasks.children.clear();
        }
      },
    );
    thisMonthLateTasks = TreeNode<TaskItem>(
      title: '这月',
      isMember: (task){
        thisMonthCompleteTasks.property['DateRange'] ??= thisMonthLateRange();
        var range = thisMonthCompleteTasks.property['DateRange'];
        if (range == false) {
          return false;
        }
        return task.dueDate >= range.begin && task.dueDate <= range.end;
      },
      behavior: (arg) {
        if (arg == 1) {
          thisMonthLateTasks.property.remove('DateRange');
          thisMonthLateTasks.children.clear();
        }
      },
    );
    lastMonthLateTasks = TreeNode<TaskItem>(
      title: '上月',
      isMember: (task){
        lastMonthCompleteTasks.property['DateRange'] ??= lastMonthLateRange();
        DayIndexRange range = lastMonthCompleteTasks.property['DateRange'];
        return task.dueDate >= range.begin && task.dueDate <= range.end;
      },
      behavior: (arg) {
        if (arg == 1) {
          lastMonthLateTasks.property.remove('DateRange');
          lastMonthLateTasks.children.clear();
        }
      },
    );
    longTimeAgoLateTasks = TreeNode<TaskItem>(
      title: '以前',
      isMember: (task){
        longTimeAgoCompleteTasks.property['DateRange'] ??= longTimeAgoPoint();
        int ago = longTimeAgoCompleteTasks.property['DateRange'];
        return task.dueDate <= ago;
      },
      behavior: (arg) {
        if (arg == 1) {
          longTimeAgoLateTasks.property.remove('DateRange');
          longTimeAgoLateTasks.children.clear();
        }
      },
    );

    lateTasks.addSubNode(yesterdayLateTasks);
    lateTasks.addSubNode(beforeYesterdayLateTasks);
    lateTasks.addSubNode(thisWeekLateTasks);
    lateTasks.addSubNode(lastWeekLateTasks);
    lateTasks.addSubNode(thisMonthLateTasks);
    lateTasks.addSubNode(lastMonthLateTasks);
    lateTasks.addSubNode(longTimeAgoLateTasks);

    completeTasks = TreeNode<TaskItem>(
      title: '已完成',
      isMember: (task) {
        // 测试时使用
        if (task.dueDate == 0) {
          task.dueDate = task.createDate;
          task.startDate = task.createDate;
          store.taskSet.changeItem(task);
        }
        return task.state == TaskState.Complete;
      },
    );
    yesterdayCompleteTasks = TreeNode<TaskItem>(
      title: '昨天',
      isMember: (task){
        yesterdayCompleteTasks.property['DateRange'] ??= store.todayIndex - 1;
        int yesterday = yesterdayCompleteTasks.property['DateRange'];
        return task.dueDate == yesterday;
      },
      behavior: (arg) {
        if (arg == 1) {
          yesterdayCompleteTasks.property.remove('DateRange');
          yesterdayCompleteTasks.children.clear();
        }
      },
    );
    beforeYesterdayCompleteTasks = TreeNode<TaskItem>(
      title: '前天',
      isMember: (task){
        beforeYesterdayCompleteTasks.property['DateRange'] ??= store.todayIndex - 2;
        int beforeYesterday = beforeYesterdayCompleteTasks.property['DateRange'];
        return task.dueDate == beforeYesterday;
      },
      behavior: (arg) {
        if (arg == 1) {
          beforeYesterdayCompleteTasks.property.remove('DateRange');
          beforeYesterdayCompleteTasks.children.clear();
        }
      },
    );
    thisWeekCompleteTasks = TreeNode<TaskItem>(
      title: '这周',
      isMember: (task){
        thisWeekCompleteTasks.property['DateRange'] ??= firstHalfWeek();
        var range = thisWeekCompleteTasks.property['DateRange'];
        if (range == false) {
          return false;
        }
        return task.dueDate >= range.begin && task.dueDate <= range.end;
      },
      behavior: (arg) {
        if (arg == 1) {
          thisWeekCompleteTasks.property.remove('DateRange');
          thisWeekCompleteTasks.children.clear();
        }
      },
    );
    lastWeekCompleteTasks = TreeNode<TaskItem>(
      title: '上周',
      isMember: (task){
        lastWeekCompleteTasks.property['DateRange'] ??= lastWeekLateRange();
        DayIndexRange range = lastWeekCompleteTasks.property['DateRange'];
        return task.dueDate >= range.begin && task.dueDate <= range.end;
      },
      behavior: (arg) {
        if (arg == 1) {
          lastWeekCompleteTasks.property.remove('DateRange');
          lastWeekCompleteTasks.children.clear();
        }
      },
    );
    thisMonthCompleteTasks = TreeNode<TaskItem>(
      title: '这月',
      isMember: (task){
        thisMonthCompleteTasks.property['DateRange'] ??= thisMonthLateRange();
        var range = thisMonthCompleteTasks.property['DateRange'];
        if (range == false) {
          return false;
        }
        return task.dueDate >= range.begin && task.dueDate <= range.end;
      },
      behavior: (arg) {
        if (arg == 1) {
          thisMonthCompleteTasks.property.remove('DateRange');
          thisMonthCompleteTasks.children.clear();
        }
      },
    );
    lastMonthCompleteTasks = TreeNode<TaskItem>(
      title: '上月',
      isMember: (task){
        lastMonthCompleteTasks.property['DateRange'] ??= lastMonthLateRange();
        DayIndexRange range = lastMonthCompleteTasks.property['DateRange'];
        return task.dueDate >= range.begin && task.dueDate <= range.end;
      },
      behavior: (arg) {
        if (arg == 1) {
          lastMonthCompleteTasks.property.remove('DateRange');
          lastMonthCompleteTasks.children.clear();
        }
      },
    );
    longTimeAgoCompleteTasks = TreeNode<TaskItem>(
      title: '以前',
      isMember: (task){
        longTimeAgoCompleteTasks.property['DateRange'] ??= longTimeAgoPoint();
        int ago = longTimeAgoCompleteTasks.property['DateRange'];
        return task.dueDate <= ago;
      },
      behavior: (arg) {
        if (arg == 1) {
          longTimeAgoCompleteTasks.property.remove('DateRange');
          longTimeAgoCompleteTasks.children.clear();
        }
      },
    );
    completeTasks.addSubNode(yesterdayCompleteTasks);
    completeTasks.addSubNode(beforeYesterdayCompleteTasks);
    completeTasks.addSubNode(thisWeekCompleteTasks);
    completeTasks.addSubNode(lastWeekCompleteTasks);
    completeTasks.addSubNode(thisMonthCompleteTasks);
    completeTasks.addSubNode(lastMonthLateTasks);
    completeTasks.addSubNode(longTimeAgoCompleteTasks);

    /// 装配大类
    allTasks.addSubNode(actionTasks);
    allTasks.addSubNode(lateTasks);
    allTasks.addSubNode(completeTasks);
  }

  GlobalStoreState store;
  int _currentDayIndex = 0;

  TreeNode<TaskItem> allTasks;

  TreeNode<TaskItem> actionTasks;
  TreeNode<TaskItem> todayTasks;
  TreeNode<TaskItem> tomorrowTasks;
  TreeNode<TaskItem> afterTomorrowTasks;
  TreeNode<TaskItem> thisWeekTasks;
  TreeNode<TaskItem> nextWeekTasks;
  TreeNode<TaskItem> thisMonthTasks;
  TreeNode<TaskItem> nextMonthTasks;
  TreeNode<TaskItem> futureTasks;

  TreeNode<TaskItem> lateTasks;

  TreeNode<TaskItem> yesterdayLateTasks;
  TreeNode<TaskItem> beforeYesterdayLateTasks;
  TreeNode<TaskItem> thisWeekLateTasks;
  TreeNode<TaskItem> lastWeekLateTasks;
  TreeNode<TaskItem> thisMonthLateTasks;
  TreeNode<TaskItem> lastMonthLateTasks;
  TreeNode<TaskItem> longTimeAgoLateTasks;

  TreeNode<TaskItem> completeTasks;

  TreeNode<TaskItem> yesterdayCompleteTasks;
  TreeNode<TaskItem> beforeYesterdayCompleteTasks;
  TreeNode<TaskItem> thisWeekCompleteTasks;
  TreeNode<TaskItem> lastWeekCompleteTasks;
  TreeNode<TaskItem> thisMonthCompleteTasks;
  TreeNode<TaskItem> lastMonthCompleteTasks;
  TreeNode<TaskItem> longTimeAgoCompleteTasks;

  void checkDate() {
    var newCurrentDateIndex = store.calendarMap.currentDateIndexed;
    if (_currentDayIndex != newCurrentDateIndex) {
      _currentDayIndex = newCurrentDateIndex;
      allTasks.actionAll(1);
      store.taskSet.itemList.forEach((task){
        allTasks.assigned(task);
      });
    }
  }

  dynamic firstHalfWeek() {
    DayIndexRange weekRange = store.calendarMap.getCurrentWeekRange();
    int thisWeekEndDayIndex = store.todayIndex - 3; // 计算这周的结束点，排除今昨天前天
    if (thisWeekEndDayIndex < weekRange.begin) {
      return false; // 如果这周的计算点已经超出了周范围，说明已经没有这周的分类组了
    } else {
      return DayIndexRange(weekRange.begin, thisWeekEndDayIndex);
    }
  }

  DayIndexRange lastWeekLateRange() {
    DayIndexRange weekRange = store.calendarMap.getLastWeekRange();
    int lastWeekEndDayIndex = store.todayIndex - 3; // 计算上周的结束点，须排除昨天前天
    if (lastWeekEndDayIndex > weekRange.end) {
      lastWeekEndDayIndex = weekRange.end;
    }
    return DayIndexRange(weekRange.begin, lastWeekEndDayIndex);
  }

  dynamic thisMonthLateRange() {
    DayIndexRange lastWeekRange = store.calendarMap.getLastWeekRange();
    DayIndexRange monthRange = store.calendarMap.getCurrentMonthRange();
    int thisMonthEndDayIndex = lastWeekRange.begin - 1;
    if (thisMonthEndDayIndex < monthRange.begin) {
      return false; // 如果这周的计算起点已经超出了周范围，说明已经没有这周的分类组了
    } else {
      return DayIndexRange(monthRange.begin, thisMonthEndDayIndex);
    }
  }

  DayIndexRange lastMonthLateRange() {
    DayIndexRange lastWeekRange = store.calendarMap.getLastWeekRange();
    DayIndexRange lastMonthRange = store.calendarMap.getLastMonthRange();
    int lastMonthEndDayIndex = lastWeekRange.begin - 1;
    if (lastMonthEndDayIndex > lastMonthRange.end) {
      lastMonthEndDayIndex = lastMonthRange.end; // 如果这月的计算起点小于这月的范围
    }
    return DayIndexRange(lastMonthRange.begin, lastMonthEndDayIndex);
  }

  int longTimeAgoPoint() {
    DayIndexRange agoRange = store.calendarMap.getLastMonthRange();
    return agoRange.begin - 1;
  }
}
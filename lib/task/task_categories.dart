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
        return task.startDate <= store.todayIndex && task.dueDate >= store.todayIndex;
      },
    );
    tomorrowTasks = TreeNode<TaskItem>(
      title: '明天',
      isMember: (task) {
        return task.startDate == store.todayIndex + 1;
      },
    );
    afterTomorrowTasks = TreeNode<TaskItem>(
      title: '后天',
      isMember: (task) {
        return task.startDate == store.todayIndex + 2;
      },
    );
    thisWeekTasks = TreeNode<TaskItem>(
      title: '这周',
      isMember: (task) {
        DayIndexRange weekRange = store.calendarMap.getCurrentWeekRange();
        int thisWeekBeginDayIndex = store.todayIndex + 3; // 计算这周的起点，须扣除今天明天的dayIndex
        if (thisWeekBeginDayIndex > weekRange.end) {
          return false; // 如果这周的计算起点已经超出了周范围，说明已经没有这周的分类组了
        }
        return task.startDate >= thisWeekBeginDayIndex && task.startDate <= weekRange.end;
      },
    );
    nextWeekTasks = TreeNode<TaskItem>(
      title: '下周',
      isMember: (task) {
        DayIndexRange weekRange = store.calendarMap.getCurrentWeekRange();
        int nextWeekBeginDayIndex = store.todayIndex + 3; // 计算下周的起点，须扣除今天明天的dayIndex
        if (nextWeekBeginDayIndex < weekRange.end + 1) {
          nextWeekBeginDayIndex = weekRange.end + 1; // 如果虾周的计算起点小于下周的周范围，就将nextWeekBeginDayIndex设为下周的起点
        }
        return task.startDate >= nextWeekBeginDayIndex && task.startDate <= weekRange.end + 7;
      },
    );

    futureTasks = TreeNode<TaskItem>(
      title: '以后',
      isMember: (task) {
        return task.startDate > store.todayIndex + 2;
      },
    );
    actionTasks.addSubNode(todayTasks);
    actionTasks.addSubNode(tomorrowTasks);
    actionTasks.addSubNode(afterTomorrowTasks);
    actionTasks.addSubNode(thisWeekTasks);
    actionTasks.addSubNode(nextWeekTasks);
    actionTasks.addSubNode(futureTasks);

    completeTasks = TreeNode<TaskItem>(
      title: '已完成',
      isMember: (task) {
        return task.state == TaskState.Complete;
      },
    );

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
        // 测试时使用
        if (task.dueDate == 0) {
          task.dueDate = task.createDate;
          task.startDate = task.createDate;
          store.taskSet.changeItem(task);
        }
        return task.dueDate == store.todayIndex - 1;
      },
    );
    beforeYesterdayLateTasks = TreeNode<TaskItem>(
      title: '前天',
      isMember: (task){
        // 测试时使用
        if (task.dueDate == 0) {
          task.dueDate = task.createDate;
          task.startDate = task.createDate;
          store.taskSet.changeItem(task);
        }
        return task.dueDate == store.todayIndex - 2;
      },
    );
    longTimeAgoLateTasks = TreeNode<TaskItem>(
      title: '以前',
      isMember: (task){
        // 测试时使用
        if (task.dueDate == 0) {
          task.dueDate = task.createDate;
          task.startDate = task.createDate;
          store.taskSet.changeItem(task);
        }
        return task.dueDate < store.todayIndex - 2;
      },
    );
    lateTasks.addSubNode(yesterdayLateTasks);
    lateTasks.addSubNode(beforeYesterdayLateTasks);
    lateTasks.addSubNode(longTimeAgoLateTasks);

    /// 装配大类
    allTasks.addSubNode(actionTasks);
    allTasks.addSubNode(lateTasks);
    allTasks.addSubNode(completeTasks);
  }

  GlobalStoreState store;

  TreeNode<TaskItem> allTasks;

  TreeNode<TaskItem> actionTasks;
  TreeNode<TaskItem> todayTasks;
  TreeNode<TaskItem> tomorrowTasks;
  TreeNode<TaskItem> afterTomorrowTasks;
  TreeNode<TaskItem> thisWeekTasks;
  TreeNode<TaskItem> nextWeekTasks;
  TreeNode<TaskItem> thisMonthTasks;
  TreeNode<TaskItem> nextMonthTasks;
  TreeNode<TaskItem> comingSoonTasks;
  TreeNode<TaskItem> futureTasks;

  TreeNode<TaskItem> lateTasks;

  TreeNode<TaskItem> yesterdayLateTasks;
  TreeNode<TaskItem> beforeYesterdayLateTasks;
  TreeNode<TaskItem> lastWeekLateTasks;
  TreeNode<TaskItem> longTimeAgoLateTasks;

  TreeNode<TaskItem> completeTasks;

  TreeNode<TaskItem> yesterdayCompleteTasks;
  TreeNode<TaskItem> beforeYesterdayCompleteTasks;
  TreeNode<TaskItem> lastWeekCompleteTasks;
  TreeNode<TaskItem> longTimeAgoCompleteTasks;
}
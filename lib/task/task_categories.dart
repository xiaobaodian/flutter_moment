import 'package:flutter/material.dart';
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
    futureTasks = TreeNode<TaskItem>(
      title: '以后',
      isMember: (task) {
        return task.startDate > store.todayIndex + 1;
      },
    );
    actionTasks.addSubNode(todayTasks);
    actionTasks.addSubNode(tomorrowTasks);
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
    allTasks.addSubNode(actionTasks);
    allTasks.addSubNode(lateTasks);
    allTasks.addSubNode(completeTasks);
  }

  GlobalStoreState store;

  TreeNode<TaskItem> allTasks;

  TreeNode<TaskItem> actionTasks;
  TreeNode<TaskItem> todayTasks;
  TreeNode<TaskItem> tomorrowTasks;
  TreeNode<TaskItem> futureTasks;

  TreeNode<TaskItem> lateTasks;

  TreeNode<TaskItem> completeTasks;
}
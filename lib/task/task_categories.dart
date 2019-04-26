import 'package:flutter/material.dart';
import 'package:flutter_moment/task/task_item.dart';
import 'package:flutter_moment/task/tree_node.dart';

class TaskCategories {
  TaskCategories(){
    debugPrint('初始化TaskCategories...');
    allTasks = TreeNode<TaskItem>(
      title: '所有任务'
    );
    actionTasks = TreeNode<TaskItem>(
      title: '待执行',
      isMember: (task) {
        return task.state != TaskState.Complete;
      },
    );
    completeTasks = TreeNode<TaskItem>(
      title: '已完成',
      isMember: (task) {
        return task.state == TaskState.Complete;
      },
    );
    allTasks.addSubNode(actionTasks);
    allTasks.addSubNode(completeTasks);
  }

  TreeNode<TaskItem> allTasks;
  TreeNode<TaskItem> actionTasks;
  TreeNode<TaskItem> completeTasks;
}
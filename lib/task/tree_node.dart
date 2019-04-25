

import 'package:flutter/material.dart';

abstract class Node<I> {
  Node(this.title, {
    this.onLostItem,
  });

  String title;
  List<Node<I>> children = [];
  ValueChanged<I> onLostItem;

  bool isMember(I item);
  int getItemCount();

  int addItem(I item) {
    if (isMember(item)) {
      int count = 0;
      children.forEach((node){
        if (node.addItem(item) > 0) {
          count++;
        }
      });
      if (count == 0 && onLostItem != null) {
        onLostItem(item);
      }
      return count;
    }
    return -1;
  }
}

abstract class Group<I> {
  List<I> items = [];

  bool isMember(I item);

  int addItem(I item) {
    if (isMember(item)) {
      items.add(item);
      return 1;
    }
    return -1;
  }
}

abstract class ItemBase {

  ///所属的group的list，便于快速处理与group相关的操作，如删除等
  List<Group> groups;
}
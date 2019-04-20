

import 'package:flutter/material.dart';

abstract class Node<I> {
  Node({
    this.onLost,
  });

  List<Node<I>> children = [];
  ValueChanged<I> onLost;

  bool isMember(I item);

  int addItem(I item) {
    if (isMember(item)) {
      int count = 0;
      children.forEach((node){
        if (node.addItem(item) > 0) {
          count++;
        }
      });
      if (count == 0 && onLost != null) {
        onLost(item);
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
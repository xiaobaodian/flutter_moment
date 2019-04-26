

import 'package:flutter/material.dart';

class TreeNode<I> {
  TreeNode({
    this.title,
    this.isMember,
    this.onLostItem,
  });

  String title;
  var property = Map<String, dynamic>();
  List<I> children = [];
  List<TreeNode<I>> subNodes = [];

  bool Function(I item) isMember;
  void Function(I tem) onLostItem;

  void addSubNode(TreeNode node) {
    subNodes.add(node);
    if (children.isNotEmpty) {
      List<I> temp = [];
      children.forEach((item){
        if (node.assigned(item)) temp.add(item);
      });
      temp.forEach((item){
        children.remove(item);
      });
    }
  }

  /// 分配item。如果[subNodes.isEmpty]说明没有下级没有子节点了，上级分配过来
  /// 的[item]就应该在这一级保存了。
  /// 否则，遍历[subNodes]并调用[node]的[assigned]方法，如果有任一个[assigned]方法
  /// 返回true，就表明下级分配成功，将[isLost]设为false。否则就表明当前的[item]不被
  /// 所有的子节点接收，属于丢失了，这种情况下将[item]加入到[children]中，便于跟踪丢
  /// 失的[item]以及后续的处理。
  bool assigned(I item) {
    debugPrint('开始分配item, ${item.toString()}');
    //bool member = isMember == null ? true : isMember(item);
    if (isMember == null ? true : isMember(item)) {
      if (subNodes.isEmpty) {
        children.add(item);
        debugPrint('分类节点<$title>加入Item：$item');
      } else {
        debugPrint('开始往下级Node分配Item...');
        bool isLost = true;
        subNodes.forEach((node){
          debugPrint('节点<${node.title}>开始分配Item...');
          if (node.assigned(item)) isLost = false;
        });
        if (isLost) {
          debugPrint('节点<$title>获取了丢失的Item...');
          children.add(item);
          if (onLostItem != null) onLostItem(item);
        }
      }
      return true;
    }
    return false;
  }

  void remove(I item) {
    if (subNodes.isEmpty) {
      children.remove(item);
    } else {
      subNodes.forEach((node){
        node.remove(item);
      });
    }
  }

  void change(I item) {
    remove(item);
    assigned(item);
  }
}
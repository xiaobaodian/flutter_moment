import 'package:flutter/material.dart';
import 'package:flutter_moment/global_store.dart';

class AppVersion {
  AppVersion({
    this.version_title,
    this.version_number,
    this.update_log,
    this.version_i,
    this.path,
  });

  String update_log;
  String version_title;
  String version_number;
  int version_i;
  String path;

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      version_title: json['version_title'],
      version_number: json['version_number'],
      update_log: json['update_log'],
      version_i: json['version_i'],
      path: json['path'],
    );
  }

  bool diffVersion(GlobalStoreState store) {
    var currentVersion = store.packageInfo.version;
    int diff = version_number.compareTo(currentVersion);
    String text = (diff > 0) ? '需要升级' : '无需升级';
    debugPrint('version title: $version_title');
    debugPrint('currentVersion: $currentVersion, updateVersion: $version_number');
    debugPrint('can updates: $text');
    return (diff > 0);
  }
}
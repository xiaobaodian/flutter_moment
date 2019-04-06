import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_file/open_file.dart';

class AppVersion {
  AppVersion({
    this.title,
    this.number,
    this.log,
    this.version,
    this.path,
  });

  String log;
  String title;
  String number;
  int version;
  String path;

  bool needUpgrade = false;

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      title: json['version_title'],
      number: json['version_number'],
      log: json['update_log'],
      version: json['version_i'],
      path: json['path'],
    );
  }

  void diffVersion(GlobalStoreState store) {
    int diff = number.compareTo(store.packageInfo.version);
    needUpgrade = diff > 0;
  }

  Future updates(GlobalStoreState store) async {
    String _updatesPath = store.localDir + '/Update';
    FlutterDownloader.registerCallback((id, status, progress) {
      debugPrint('Download task ($id) is in status ($status) and process ($progress)');
      if (status == DownloadTaskStatus.complete) {
        //FlutterDownloader.open(taskId: id);
        OpenFile.open(_updatesPath + '/app-release.apk');
        FlutterDownloader.registerCallback(null);
      }
    });
    debugPrint('下载升级文件的目录：$_updatesPath');
    final savedDir = Directory(_updatesPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    final taskId = await FlutterDownloader.enqueue(
      url: 'https://share.heiluo.com/share/download?type=1&shareId=e6414385ca4a48b98899a7d51ca29af7&fileId=2445569',
      savedDir: _updatesPath,
      showNotification:  true, // show download progress in status bar (for Android)
      openFileFromNotification: true, // click on notification to open downloaded file (for Android)
    );
    //FlutterDownloader.open(taskId: taskId);
    final tasks = await FlutterDownloader.loadTasks();
  }
}
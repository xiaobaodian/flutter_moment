import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

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

  bool diffVersion(BuildContext context, GlobalStoreState store) {
    var currentVersion = store.packageInfo.version;
    int diff = version_number.compareTo(currentVersion);
    String text = (diff > 0) ? '需要升级' : '无需升级';
    debugPrint('version title: $version_title');
    debugPrint('currentVersion: $currentVersion, updateVersion: $version_number');
    debugPrint('can updates: $text');
    if (diff > 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('发现新的版本'),
            content: Text('找到了$version_title，Version：$version_number。需要升级吗？'),
            actions: <Widget>[
              FlatButton(
                child: Text('取消'),
                onPressed: () {
                  store.allowUpgrades = false;
                  Navigator.of(context).pop(null);
                },
              ),
              FlatButton(
                child: Text('升级'),
                onPressed: () {
                  Navigator.of(context).pop(1);
                },
              ),
            ],
          );
        }
      ).then((result){
        if (result is int) {
          updates(store);
        }
      });

    }
    return (diff > 0);
  }

  Future updates(GlobalStoreState store) async {
    FlutterDownloader.registerCallback((id, status, progress) {
      debugPrint('Download task ($id) is in status ($status) and process ($progress)');
      if (status == DownloadTaskStatus.complete) {
        FlutterDownloader.open(taskId: id);
      }
    });
    String _updatesPath = store.localDir + '/Update';
    debugPrint('下载升级文件的目录：$_updatesPath');
    final savedDir = Directory(_updatesPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      //savedDir.create();
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
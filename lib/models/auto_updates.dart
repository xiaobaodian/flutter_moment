import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_file/open_file.dart';

class AppVersion {
  AppVersion({
    this.title,
    this.version,
    this.buildNumber,
    this.log,
    this.path,
  });

  String title;
  String version;
  String buildNumber;
  String log;
  String path;

  String _updatesPath;
  String _filePath;
  bool needUpgrade = false;

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      title: json['title'],
      version: json['version'],
      buildNumber: json['buildNumber'],
      log: json['log'],
      path: json['path'],
    );
  }

  void init(GlobalStoreState store) {
    _updatesPath = store.localDir + '/Update';
    _filePath = _updatesPath + '/app-release.apk';
  }

  Future diffVersion(GlobalStoreState store) async {
    final savedDir = Directory(_updatesPath);
    bool hasDir = await savedDir.exists();
    if (!hasDir) {
      savedDir.create();
    }
    File file = File(_filePath);
    bool hasFile = await file.exists();
    if (hasFile) {
      file.delete();
    }
    int diff = version.compareTo(store.packageInfo.version);
    if (diff <= 0) {
      diff = buildNumber.compareTo(store.packageInfo.buildNumber);
    }
    needUpgrade = diff > 0;
  }

  Future updates(BuildContext context, GlobalStoreState store) async {
    debugPrint('下载升级文件的目录：$_updatesPath');
    final savedDir = Directory(_updatesPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    final taskId = await FlutterDownloader.enqueue(
      //url: 'https://share.heiluo.com/share/download?type=1&shareId=e6414385ca4a48b98899a7d51ca29af7&fileId=2445569',
      url: path,
      savedDir: _updatesPath,
      showNotification:  true, // show download progress in status bar (for Android)
      openFileFromNotification: true, // click on notification to open downloaded file (for Android)
    );
    //FlutterDownloader.open(taskId: taskId);
    final tasks = await FlutterDownloader.loadTasks();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        double downloadProgress;
        return AlertDialog(
          title: Text('下载'),
          contentPadding: EdgeInsets.all(32),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              FlutterDownloader.registerCallback((id, status, progress) {
                if (status == DownloadTaskStatus.complete) {
                  OpenFile.open(_filePath);
                  FlutterDownloader.registerCallback(null);
                  Navigator.of(context).pop(null);
                } else {
                  setDialogState((){
                    downloadProgress = progress / 100.0;
                  });
                }
              });
              return Container(
                child: LinearProgressIndicator(
                  value: downloadProgress,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
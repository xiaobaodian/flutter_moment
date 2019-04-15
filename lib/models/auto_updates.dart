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
    cleanSaveDir();
  }

  Future cleanSaveDir() async {
    final savedDir = Directory(_updatesPath);
    bool hasDir = await savedDir.exists();
    if (hasDir) {
      List<FileSystemEntity> files = savedDir.listSync();
      files.forEach((file){
        debugPrint(file.path);
        File(file.path).deleteSync();
      });
      await savedDir.delete(); debugPrint('删除原来的下载目录');
    }
    await savedDir.create(); debugPrint('创建下载目录');
  }

  Future diffVersion(GlobalStoreState store) async {
    int diff = version.compareTo(store.packageInfo.version);
    if (diff <= 0) {
      diff = buildNumber.compareTo(store.packageInfo.buildNumber);
    }
    needUpgrade = diff > 0;
  }

  Future updates(BuildContext context, GlobalStoreState store) async {
    bool isFailed = false;
    await cleanSaveDir();
    final taskId = await FlutterDownloader.enqueue(
      url: path,
      savedDir: _updatesPath,
      showNotification: true, // show download progress in status bar (for Android)
      openFileFromNotification: false, // click on notification to open downloaded file (for Android)
    );
    //FlutterDownloader.open(taskId: taskId);
    //final tasks = await FlutterDownloader.loadTasks();
    await FlutterDownloader.loadTasks();

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
                } else if (status == DownloadTaskStatus.failed){
                  setDialogState((){
                    isFailed = true;
                    FlutterDownloader.registerCallback(null);
                    Future.delayed(Duration(seconds: 2),(){
                      Navigator.of(context).pop(null);
                    });
                  });
                } else {
                  setDialogState((){
                    downloadProgress = progress / 100.0;
                  });
                }
              });
              return Container(
                child: isFailed ? Text('下载失败') : LinearProgressIndicator(
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
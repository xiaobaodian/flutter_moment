import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_moment/models/helper_net.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_file/open_file.dart';

Future<AppVersion> checkUpdatesFile(GlobalStoreState store) async {
  bool hasConnect = await ConnectState.hasConnect();
  if (hasConnect) {
    Dio dio = Dio();
    Response response = await dio.get(
        "https://share.heiluo.com/share/download?type=1&shareId=ce2e6c74d2b0428f80ff8203b84b7379&fileId=2609208");
    debugPrint('获取的文件内容：${response.data.toString()}');
    AppVersion appVer = AppVersion.fromJson(jsonDecode(response.data.toString()));
    //debugPrint('版本：${appVer.title}');
    appVer.init(store);
    return appVer;
  }
  return null;
}

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
      files.forEach((file) {
        debugPrint(file.path);
        File(file.path).deleteSync();
      });
      await savedDir.delete();
      debugPrint('删除原来的下载目录');
    }
    await savedDir.create();
    debugPrint('创建下载目录');
  }

  Future diffVersion(GlobalStoreState store) async {
    int diff = version.compareTo(store.packageInfo.version);
    if (diff <= 0) {
      diff = buildNumber.compareTo(store.packageInfo.buildNumber);
    }
    needUpgrade = diff > 0;
  }

  Future updates(BuildContext context, GlobalStoreState store) async {
    bool notConnect = await ConnectState.notConnect();
    if (notConnect) {
      Fluttertoast.showToast(msg: '没有网络连接，请检查你的网络...');
      return;
    }
    bool isFailed = false;
    await cleanSaveDir();
    final taskId = await FlutterDownloader.enqueue(
      url: path,
      savedDir: _updatesPath,
      showNotification: true,
      openFileFromNotification: false,
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
                } else if (status == DownloadTaskStatus.failed) {
                  setDialogState(() {
                    isFailed = true;
                    FlutterDownloader.registerCallback(null);
                    Future.delayed(Duration(seconds: 2), () {
                      Navigator.of(context).pop(null);
                    });
                  });
                } else {
                  setDialogState(() {
                    downloadProgress = progress / 100.0;
                  });
                }
              });
              return Container(
                child: isFailed
                    ? Text('下载失败')
                    : LinearProgressIndicator(
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

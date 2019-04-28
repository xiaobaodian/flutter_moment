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
    CancelToken token = CancelToken();
    String configPath = store.prefs.upgradeConfigPath;
    debugPrint('获取的配置路径：$configPath');
    try {
      Response response = await dio.get(configPath, cancelToken: token);
      debugPrint('获取的文件内容：${response.data.toString()}');
      AppVersion appVer = AppVersion.fromJson(jsonDecode(response.data.toString()));
      appVer.init(store);
      return appVer;
    } on DioError catch (e) {
      if (e.response != null) {
        debugPrint('e.response.data -> ${e.response.data.toString()}');
        debugPrint('e.response.headers -> ${e.response.headers.toString()}');
        debugPrint('e.response.request -> ${e.response.request.toString()}');
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        debugPrint('e.request -> ${e.request.toString()}');
        debugPrint('e.message -> ${e.message}');
      }
    }
  }
  return null;
}

enum CheckUpdateState {
  Wait,
  Updating,
  Fail,
  Complete
}

class AppVersion {
  AppVersion({
    this.title,
    this.version,
    this.buildNumber,
    this.log,
    this.configPath,
    this.appPath,
  });

  String title;
  String version;
  String buildNumber;
  String log;
  String configPath;
  String appPath;

  String _updatesPath;
  String _filePath;

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      title: json['title'],
      version: json['version'],
      buildNumber: json['buildNumber'],
      log: json['log'],
      configPath: json['configPath'],
      appPath: json['appPath'],
    );
  }

  void init(GlobalStoreState store) {
    _updatesPath = store.localDir + '/Update';
    _filePath = _updatesPath + '/app-release.apk';
    store.prefs.upgradeConfigPath = configPath;
    store.prefs.upgradeAppPath = appPath;
    cleanSaveDir();
  }

  Future cleanSaveDir() async {
    final savedDir = Directory(_updatesPath);
    bool hasDir = savedDir.existsSync();
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

  bool hasUpgrade(GlobalStoreState store) {
    int diff = version.compareTo(store.packageInfo.version);
    if (diff <= 0) {
      diff = buildNumber.compareTo(store.packageInfo.buildNumber);
    }
    return diff > 0;
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
      url: appPath,
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
                  //OpenFile.open(_filePath);
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

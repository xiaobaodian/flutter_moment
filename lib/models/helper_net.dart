import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

class ConnectState {
  static Future<bool> hasConnect() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      debugPrint('hasConnect() == ${connectivityResult.toString()}');
      return true;
    }
    debugPrint('hasConnect() == false');
    return false;
  }
  static Future<bool> notConnect() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      debugPrint('notConnect() == true');
      return true;
    }
    debugPrint('notConnect() == false');
    return false;
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LaunchPage extends StatefulWidget{

  @override
  _LaunchPageState createState()=> new _LaunchPageState();

}

class _LaunchPageState extends State<LaunchPage>{

  //bool isStartHomePage = false;

  //页面初始化状态的方法
  @override
  void initState() {
    super.initState();
    //隐藏状态栏
    //SystemChrome.setEnabledSystemUIOverlays([]);
    countDown();
  }

  void countDown() {
    Future.delayed(Duration(seconds: 5), bootHomeScreen);
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: bootHomeScreen,//设置页面点击事件
      child: Image.asset("assets/image/SplashPage.png",
        fit: BoxFit.cover,
      ),
    );
  }

  void bootHomeScreen(){
    Navigator.of(context).pushReplacementNamed('HomeScreen');
  }
}
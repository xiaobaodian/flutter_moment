import 'package:flutter/material.dart';

import 'global_store.dart';

class UpdatePage extends StatefulWidget{

  @override
  _UpdatePageState createState()=> new _UpdatePageState();

}

class _UpdatePageState extends State<UpdatePage>{
  GlobalStoreState _store;

  @override
  void initState() {
    super.initState();
    //隐藏状态栏
    //SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = GlobalStore.of(context);
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
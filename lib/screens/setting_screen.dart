import 'package:flutter/material.dart';

class SettingScreen  extends StatefulWidget{
  const SettingScreen({super.key});

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
  super.build(context);
    return Scaffold();
  }
  
}
import 'package:flutter/material.dart';

class DeckListScreen  extends StatefulWidget{
  const DeckListScreen({super.key});

  @override
  _DeckListScreenState createState() => _DeckListScreenState();
}

class _DeckListScreenState extends State<DeckListScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
  super.build(context);
    return Scaffold();
  }
  
}
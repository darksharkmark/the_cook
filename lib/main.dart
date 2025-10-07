import 'package:flutter/material.dart';
import 'package:the_cook/screens/navigation_menu.dart';

void main() {
  runApp(const CSVImageApp());
}

class CSVImageApp extends StatelessWidget {
  const CSVImageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'One Piece Card Searcher',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const NavigationMenu(),
    );
  }
}


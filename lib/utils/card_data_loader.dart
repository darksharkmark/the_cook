import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class CardDataLoader {
  List<List<String>> allData = [];
  List<List<String>> _allDataLower = [];

  Future<void> load() async {
    final raw = await rootBundle.loadString('assets/card_data.csv');
    final lines = const LineSplitter().convert(raw);
    allData = lines.map((line) => line.split('|')).toList();
    _allDataLower = allData
        .map((row) => row.map((cell) => cell.toLowerCase()).toList())
        .toList();
  }

  List<List<String>> filter(String query) {
    if (query.isEmpty) return allData;
    final words = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return allData;
    final filtered = <List<String>>[];
    for (int i = 0; i < allData.length; i++) {
      final rowLower = _allDataLower[i];
      if (words.every((word) => rowLower.any((cell) => cell.contains(word)))) {
        filtered.add(allData[i]);
      }
    }
    return filtered;
  }

  Future<String?> assetPathForId(String id) async {
    final parts = id.split('-');
    if (parts.isEmpty) return null;
    final folder = parts[0];
    final pngPath = 'assets/cards/$folder/$id.png';
    final jpgPath = 'assets/cards/$folder/$id.jpg';
    try {
      await rootBundle.load(pngPath);
      return pngPath;
    } catch (_) {}
    try {
      await rootBundle.load(jpgPath);
      return jpgPath;
    } catch (_) {}
    return null;
  }
}

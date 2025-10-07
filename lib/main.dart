import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const CSVViewerApp());
}

class CSVViewerApp extends StatelessWidget {
  const CSVViewerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSV Viewer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CSVScreen(),
    );
  }
}

class CSVScreen extends StatefulWidget {
  const CSVScreen({super.key});

  @override
  State<CSVScreen> createState() => _CSVScreenState();
}

class _CSVScreenState extends State<CSVScreen> {
  final ValueNotifier<List<List<String>>> _filteredData = ValueNotifier([]);
  List<List<String>> _allData = [];
  List<List<String>> _allDataLower = [];
  bool _loading = true;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadCSV();
  }

  Future<void> _loadCSV() async {
    final raw = await rootBundle.loadString('assets/results/card_data.csv');

    // Parse CSV fast using split('|')
    final lines = const LineSplitter().convert(raw);
    _allData = lines.map((line) => line.split('|')).toList();

    // Precompute lowercased data for fast search
    _allDataLower = _allData
        .map((row) => row.map((cell) => cell.toLowerCase()).toList())
        .toList();

    _filteredData.value = _allData;
    setState(() => _loading = false);
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.isEmpty) {
        _filteredData.value = _allData;
        return;
      }

      final words = query
          .toLowerCase()
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .toList();

      if (words.isEmpty) {
        _filteredData.value = _allData;
        return;
      }

      // Filter using pre-lowered data
      final filtered = <List<String>>[];
      for (int i = 0; i < _allData.length; i++) {
        final rowLower = _allDataLower[i];
        if (words.every(
          (word) => rowLower.any((cell) => cell.contains(word)),
        )) {
          filtered.add(_allData[i]);
        }
      }

      _filteredData.value = filtered;
    });
  }

  @override
  void dispose() {
    _filteredData.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('One Piece Card Searcher'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search (multiple words supported)...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ValueListenableBuilder<List<List<String>>>(
              valueListenable: _filteredData,
              builder: (context, data, _) {
                if (data.isEmpty) {
                  return const Center(child: Text('No results found'));
                }

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final row = data[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            row.join(' | '),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

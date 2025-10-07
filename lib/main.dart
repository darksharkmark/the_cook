import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(const CsvPaginatedApp());
}

class CsvPaginatedApp extends StatelessWidget {
  const CsvPaginatedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CsvPaginatedPage(),
    );
  }
}

class CsvPaginatedPage extends StatefulWidget {
  const CsvPaginatedPage({super.key});

  @override
  State<CsvPaginatedPage> createState() => _CsvPaginatedPageState();
}

class _CsvPaginatedPageState extends State<CsvPaginatedPage> {
  List<String> headers = [];
  List<List<String>> rows = [];

  static const int rowsPerPage = 100;
  int currentPage = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCsv();
  }

  Future<void> _loadCsv() async {
    try {
      final raw = await rootBundle.loadString('assets/results/card_data.csv');
      final data = await compute(parseCsvInBackground, raw);

      if (data.isEmpty) return;

      setState(() {
        headers = data.first;
        rows = data.skip(1).toList();
        loading = false;
      });
    } catch (e) {
      debugPrint('Error loading CSV: $e');
    }
  }

  // Show 100 rows per page
  List<List<String>> get _paginatedRows {
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, rows.length);
    return rows.sublist(start, end);
  }

  void _nextPage() {
    if ((currentPage + 1) * rowsPerPage < rows.length) {
      setState(() => currentPage++);
    }
  }

  void _prevPage() {
    if (currentPage > 0) {
      setState(() => currentPage--);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Large CSV Viewer')),
      body: Column(
        children: [
          // Header row
          Container(
            color: Colors.blue.shade50,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: headers
                  .map(
                    (h) => Expanded(
                      child: Text(
                        h,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          // Scrollable rows
          Expanded(
            child: ListView.builder(
              itemCount: _paginatedRows.length,
              itemBuilder: (context, index) {
                final row = _paginatedRows[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  child: Row(
                    children: row
                        .map(
                          (cell) => Expanded(
                            child: Text(cell, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
          ),

          // Pagination controls
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Page ${currentPage + 1} of ${(rows.length / rowsPerPage).ceil()}',
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: currentPage > 0 ? _prevPage : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: (currentPage + 1) * rowsPerPage < rows.length
                          ? _nextPage
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Parses CSV on a background thread for speed
List<List<String>> parseCsvInBackground(String raw) {
  final lines = const LineSplitter().convert(raw);
  final parsed = <List<String>>[];

  for (final line in lines) {
    final row = const CsvToListConverter(
      fieldDelimiter: '|',
    ).convert(line).first.map((e) => e.toString()).toList();
    parsed.add(row);
  }

  return parsed;
}

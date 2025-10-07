import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const CSVImageApp());
}

class CSVImageApp extends StatelessWidget {
  const CSVImageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSV Image Viewer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CSVImageScreen(),
    );
  }
}

class CSVImageScreen extends StatefulWidget {
  const CSVImageScreen({super.key});

  @override
  State<CSVImageScreen> createState() => _CSVImageScreenState();
}

class _CSVImageScreenState extends State<CSVImageScreen> {
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
    final raw = await rootBundle.loadString('assets/data.csv');
    final lines = const LineSplitter().convert(raw);

    _allData = lines.map((line) => line.split('|')).toList();
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

  String _assetPathForId(String id) {
    final parts = id.split('-');
    if (parts.isEmpty) return '';
    final folder = parts[0];
    return 'assets/cards/$folder/$id.png';
  }

  void _openFullScreen(BuildContext context, String assetPath) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FullScreenImage(assetPath: assetPath)),
    );
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
        title: const Text('CSV Image Viewer'),
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

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final row = data[index];
                    final id = row[0];
                    final assetPath = _assetPathForId(id);

                    return GestureDetector(
                      onTap: () => _openFullScreen(context, assetPath),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            assetPath,
                            fit: BoxFit.cover,
                            frameBuilder:
                                (
                                  context,
                                  child,
                                  frame,
                                  wasSynchronouslyLoaded,
                                ) {
                                  if (wasSynchronouslyLoaded) return child;
                                  return frame == null
                                      ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : child;
                                },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.broken_image),
                              );
                            },
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

// ------------------------- Full-Screen Image Viewer -------------------------

class FullScreenImage extends StatelessWidget {
  final String assetPath;
  const FullScreenImage({super.key, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 5.0,
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 50,
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

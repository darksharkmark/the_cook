import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/full_screen_image.dart';
import '../utils/card_data_loader.dart';

class CSVImageScreen extends StatefulWidget {
  const CSVImageScreen({super.key});

  @override
  State<CSVImageScreen> createState() => _CSVImageScreenState();
}


class _CSVImageScreenState extends State<CSVImageScreen> with AutomaticKeepAliveClientMixin {
  final ValueNotifier<List<List<String>>> _filteredData = ValueNotifier([]);
  late CardDataLoader _dataLoader;
  bool _loading = true;
  Timer? _debounce;
  String _searchQuery = '';
  late TextEditingController _controller;
  late ScrollController _scrollController;

  @override
  @override
  void initState() {
    super.initState();
    _dataLoader = CardDataLoader();
    _controller = TextEditingController(text: _searchQuery);
    _scrollController = ScrollController();
    _loadCSV();
  }

  Future<void> _loadCSV() async {
    await _dataLoader.load();
    _filteredData.value = _dataLoader.allData;
    setState(() => _loading = false);
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filteredData.value = _dataLoader.filter(_searchQuery);
    });
  }

  void _openFullScreen(BuildContext context, String assetPath) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FullScreenImage(assetPath: assetPath)),
    );
  }

  @override
  @override
  void dispose() {
    _filteredData.dispose();
    _debounce?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('One Piece Card Searcher'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
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
                  controller: _scrollController,
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
                    return FutureBuilder<String?>(
                      future: _dataLoader.assetPathForId(id),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data == null) {
                          return const SizedBox.shrink();
                        }
                        final assetPath = snapshot.data!;
                        return GestureDetector(
                          onTap: () => _openFullScreen(context, assetPath),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: Image.asset(
                                    assetPath,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}

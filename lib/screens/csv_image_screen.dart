import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/full_screen_image.dart';
import '../utils/card_data_loader.dart';
import '../widgets/card_image_widget.dart';

class CSVImageScreen extends StatefulWidget {
  const CSVImageScreen({super.key});

  @override
  State<CSVImageScreen> createState() => _CSVImageScreenState();
}


class _CSVImageScreenState extends State<CSVImageScreen> with AutomaticKeepAliveClientMixin {
  final List<String> _colorOptions = ['red', 'green', 'purple', 'black', 'yellow', 'blue'];
  final Set<String> _selectedColors = {};
  List<List<String>> _filterWithColors(List<List<String>> data) {
    if (_selectedColors.isEmpty) return data;
    return data.where((row) {
      if (row.length < 8) return false;
      final colorField = row[7].toLowerCase();
      return _selectedColors.any((color) => colorField.contains(color));
    }).toList();
  }
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
      _filteredData.value = _filterWithColors(_dataLoader.filter(_searchQuery));
    });
    //id|name|rarity|type|attribute|power|counter|color|card_type|effect|trigger_text|image_url|alternate_art|series_id|series_name
    // holding csv values here for now
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
          preferredSize: const Size.fromHeight(96),
          child: Column(
            children: [
              Padding(
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Wrap(
                  spacing: 8,
                  children: _colorOptions.map((color) {
                    return FilterChip(
                      label: Text(color[0].toUpperCase() + color.substring(1)),
                      selected: _selectedColors.contains(color),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedColors.add(color);
                          } else {
                            _selectedColors.remove(color);
                          }
                          // Re-filter after color change
                          _filteredData.value = _filterWithColors(_dataLoader.filter(_searchQuery));
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
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
                    return GestureDetector(
                      onTap: () => _openFullScreen(context, CardDataLoader().assetPathForId(id)),
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
                              child: CardImageWidget(
                                id: id,
                                width: double.infinity,
                                height: double.infinity,
                                borderRadius: 8,
                              ),
                            ),
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

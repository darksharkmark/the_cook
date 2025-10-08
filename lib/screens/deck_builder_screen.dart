import 'package:flutter/material.dart';
import '../utils/card_data_loader.dart';
import '../utils/deck_storage.dart';
import '../widgets/card_image_widget.dart';

class DeckBuilderScreen extends StatefulWidget {
  final Map<String, dynamic>? initialDeck;
  const DeckBuilderScreen({super.key, this.initialDeck});

  @override
  DeckBuilderScreenState createState() => DeckBuilderScreenState();
}

class DeckBuilderScreenState extends State<DeckBuilderScreen> {
  List<Map<String, dynamic>> _allCards = [];
  List<Map<String, dynamic>> _leaders = [];
  String _leaderSearch = '';
  String _cardSearch = '';
  Map<String, dynamic>? _selectedLeader;
  Map<String, int> _deckCards = {};
  bool _saving = false;
  String _deckName = '';
  String? _deckId;
  String? _deckNameError;
  final TextEditingController _deckNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialDeck != null) {
      _deckName = widget.initialDeck!['name'] ?? '';
      _deckId = widget.initialDeck!['id'];
    }
    _deckNameController.text = _deckName;
    _deckNameController.addListener(() {
      _deckName = _deckNameController.text;
    });
    _loadCards();
  }

  Future<void> _loadCards() async {
    final loader = CardDataLoader();
    await loader.load();
    setState(() {
      _allCards = loader.allData.skip(1).map((row) => {
        'id': row[0],
        'name': row[1],
        'type': row[3],
        'color': row.length > 7 ? row[7] : '',
        // Add more fields as needed
      }).toList();
      _leaders = loader.allData.skip(1)
        .where((row) => row.length > 3 && row[3].toUpperCase() == 'LEADER')
        .map((row) => {
          'id': row[0],
          'name': row[1],
          'type': row[3],
          'color': row.length > 7 ? row[7] : '',
        }).toList();
      if (widget.initialDeck != null) {
        final leaderInfo = widget.initialDeck!['leader'] as List?;
        if (leaderInfo != null) {
          final foundLeader = _leaders.where((l) => l['id'] == leaderInfo[0]).toList();
          if (foundLeader.isNotEmpty) {
            _selectedLeader = foundLeader.first;
          }
        }
        final cards = widget.initialDeck!['cards'] as List?;
        if (cards != null) {
          _deckCards = {
            for (var entry in cards)
              entry[0]: entry[1] as int,
          };
        }
      }
    });
  }

  List<Map<String, dynamic>> get _filteredLeaders {
    if (_leaderSearch.isEmpty) return _leaders;
    return _leaders.where((c) => c['name'].toLowerCase().contains(_leaderSearch.toLowerCase())).toList();
  }

  List<Map<String, dynamic>> get _filteredCards {
    if (_selectedLeader == null) return [];
    final leaderColors = (_selectedLeader!['color'] as String).split('/').map((c) => c.trim().toLowerCase()).toList();
    final filtered = _allCards.where((card) {
      final cardColor = (card['color'] ?? '').toString().toLowerCase();
      // Exclude leaders from card search
      if ((card['type'] ?? '').toString().toUpperCase() == 'LEADER') return false;
      return leaderColors.any((lc) => cardColor.contains(lc));
    }).toList();
    if (_cardSearch.isEmpty) return filtered;
    return filtered.where((card) => card['name'].toLowerCase().contains(_cardSearch.toLowerCase())).toList();
  }

  int get _deckSize => _deckCards.values.fold(0, (a, b) => a + b);

  void _addCard(Map<String, dynamic> card) {
    setState(() {
      _deckCards[card['id']] = (_deckCards[card['id']] ?? 0) + 1;
    });
  }

  void _removeCard(Map<String, dynamic> card) {
    setState(() {
      if (_deckCards[card['id']] != null && _deckCards[card['id']]! > 0) {
        _deckCards[card['id']] = _deckCards[card['id']]! - 1;
        if (_deckCards[card['id']] == 0) _deckCards.remove(card['id']);
      }
    });
  }

  Future<void> _saveDeck() async {
    if (_selectedLeader == null || _deckName.trim().isEmpty) {
      setState(() {
        _deckNameError = _deckName.trim().isEmpty ? 'Deck name is required.' : null;
      });
      return;
    }
    setState(() { _saving = true; _deckNameError = null; });
    final deck = {
      'id': _deckId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'name': _deckName.trim(),
      'leader': [_selectedLeader!['id'], _selectedLeader!['name']],
      'cards': _deckCards.entries.map((e) => [e.key, e.value]).toList(),
    };
    await DeckStorage.saveOrUpdateDeck(deck);
    setState(() { _saving = false; });
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deck Builder')),
      body: _selectedLeader == null
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search Leader',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (v) => setState(() => _leaderSearch = v),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Deck Name',
                      prefixIcon: const Icon(Icons.edit),
                      errorText: _deckNameError,
                    ),
                    controller: _deckNameController,
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                    ),
                    itemCount: _filteredLeaders.length,
                    itemBuilder: (context, i) {
                      final leader = _filteredLeaders[i];
                      return GestureDetector(
                        onTap: () {
                          if (_deckName.trim().isEmpty) {
                            setState(() {
                              _deckNameError = 'Deck name is required.';
                            });
                          } else {
                            setState(() {
                              _selectedLeader = leader;
                              _deckNameError = null;
                            });
                          }
                        },
                        child: Column(
                          children: [
                              Expanded(
                                child: CardImageWidget(
                                  id: leader['id'],
                                  width: double.infinity,
                                  height: double.infinity,
                                  borderRadius: 8,
                                ),
                              ),
                            Text(leader['name'], textAlign: TextAlign.center),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          : Column(
              children: [
                ListTile(
                  leading: CardImageWidget(
                    id: _selectedLeader!['id'],
                    width: 48,
                    height: 48,
                    borderRadius: 8,
                  ),
                  title: Text(_selectedLeader!['name']),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _selectedLeader = null),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text('Total cards: $_deckSize/50', style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      if (_deckSize == 50)
                        const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 3,
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                    ),
                    itemCount: _deckCards.length,
                    itemBuilder: (context, i) {
                      final cardId = _deckCards.keys.elementAt(i);
                      final card = _allCards.firstWhere((c) => c['id'] == cardId);
                      return Stack(
                        children: [
                          CardImageWidget(
                            id: card['id'],
                            height: 60,
                            borderRadius: 8,
                          ),
                          // Overlay the quantity directly on top of the image (centered)
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                margin: const EdgeInsets.all(6),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_deckCards[cardId]}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                // Card search bar in the middle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search Cards',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (v) => setState(() => _cardSearch = v),
                  ),
                ),
                // Card selection grid, 5 per row
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                    ),
                    itemCount: _filteredCards.length,
                    itemBuilder: (context, i) {
                      final card = _filteredCards[i];
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () => _addCard(card),
                            onLongPress: () => _removeCard(card),
                            child: CardImageWidget(
                              id: card['id'],
                              width: double.infinity,
                              height: double.infinity,
                              borderRadius: 8,
                            ),
                          ),
                          if (_deckCards[card['id']] != null && _deckCards[card['id']]! > 0)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha((0.7 * 255).toInt()),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_deckCards[card['id']]}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
                    label: const Text('Save Deck'),
                    onPressed: (!_saving && _deckName.trim().isNotEmpty) ? _saveDeck : null,
                  ),
                ),
              ],
            ),
    );
  }
}

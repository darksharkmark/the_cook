import 'package:flutter/material.dart';
import '../utils/card_data_loader.dart';
import '../utils/deck_storage.dart';

class DeckBuilderScreen extends StatefulWidget {
  final Map<String, dynamic>? initialDeck;
  const DeckBuilderScreen({super.key, this.initialDeck});

  @override
  _DeckBuilderScreenState createState() => _DeckBuilderScreenState();
}

class _DeckBuilderScreenState extends State<DeckBuilderScreen> {
  List<Map<String, dynamic>> _allCards = [];
  List<Map<String, dynamic>> _leaders = [];
  String _search = '';
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
      _deckId = widget.initialDeck!['id'] ?? null;
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
    if (_search.isEmpty) return _leaders;
    return _leaders.where((c) => c['name'].toLowerCase().contains(_search.toLowerCase())).toList();
  }

  List<Map<String, dynamic>> get _filteredCards {
    if (_selectedLeader == null) return [];
    final leaderColors = (_selectedLeader!['color'] as String).split('/').map((c) => c.trim().toLowerCase()).toList();
    return _allCards.where((card) {
      final cardColor = (card['color'] ?? '').toString().toLowerCase();
      return leaderColors.any((lc) => cardColor.contains(lc));
    }).toList();
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
                    onChanged: (v) => setState(() => _search = v),
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
                              child: FutureBuilder<String?>(
                                future: CardDataLoader().assetPathForId(leader['id']),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData || snapshot.data == null) {
                                    return const SizedBox.expand();
                                  }
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  );
                                },
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
                  leading: FutureBuilder<String?>(
                    future: CardDataLoader().assetPathForId(_selectedLeader!['id']),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data == null) {
                        return const SizedBox(width: 48, height: 48);
                      }
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          snapshot.data!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
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
                          FutureBuilder<String?>(
                            future: CardDataLoader().assetPathForId(card['id']),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data == null) {
                                return const SizedBox(height: 60);
                              }
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  snapshot.data!,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_deckCards[cardId]}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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
                    itemCount: _filteredCards.length,
                    itemBuilder: (context, i) {
                      final card = _filteredCards[i];
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () => _addCard(card),
                            onLongPress: () => _removeCard(card),
                            child: Expanded(
                              child: FutureBuilder<String?>(
                                future: CardDataLoader().assetPathForId(card['id']),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData || snapshot.data == null) {
                                    return const SizedBox.expand();
                                  }
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          if (_deckCards[card['id']] != null && _deckCards[card['id']]! > 0)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
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

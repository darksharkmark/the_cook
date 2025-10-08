import 'package:flutter/material.dart';
import '../utils/deck_storage.dart';
// import '../utils/card_data_loader.dart';
import '../widgets/card_image_widget.dart';
import 'deck_builder_screen.dart';

class DeckListScreen extends StatefulWidget {
  const DeckListScreen({super.key});

  @override
  DeckListScreenState createState() => DeckListScreenState();
}

class DeckListScreenState extends State<DeckListScreen> with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> _decks = [];
  bool _loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  Future<void> _loadDecks() async {
    final decks = await DeckStorage.loadDecks();
    setState(() {
      _decks = decks ?? [];
      _loading = false;
    });
  }

  void _openDeckBuilder() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DeckBuilderScreen()),
    );
    _loadDecks(); // Refresh after returning
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Deck List')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Create Deck'),
                      onPressed: _openDeckBuilder,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: _decks.map((deck) {
                      final leader = deck['leader'] as List;
                      final leaderId = leader[0];
                      final leaderName = leader[1];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: CardImageWidget(
                            id: leaderId,
                            width: 48,
                            height: 48,
                            borderRadius: 8,
                          ),
                          title: Text(deck['name'] ?? leaderName),
                          subtitle: Text('Cards: ${((deck['cards'] as List).fold<int>(0, (sum, entry) => sum + (entry[1] as int)))}'),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DeckBuilderScreen(
                                  initialDeck: deck,
                                ),
                              ),
                            );
                            _loadDecks();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}
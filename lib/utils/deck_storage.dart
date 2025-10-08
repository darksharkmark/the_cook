import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DeckStorage {
  static const String decksKey = 'saved_decks';

  static Future<void> saveDeck(Map<String, dynamic> deck) async {
    final prefs = await SharedPreferences.getInstance();
    final decks = await loadDecks() ?? [];
    decks.add(deck);
    await prefs.setString(decksKey, jsonEncode(decks));
  }

  static Future<List<Map<String, dynamic>>?> loadDecks() async {
    final prefs = await SharedPreferences.getInstance();
    final decksStr = prefs.getString(decksKey);
    if (decksStr == null) return [];
    final decoded = jsonDecode(decksStr) as List;
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> saveOrUpdateDeck(Map<String, dynamic> deck) async {
    final prefs = await SharedPreferences.getInstance();
    final decks = await loadDecks() ?? [];
    final deckId = deck['id'];
    final idx = decks.indexWhere((d) => d['id'] == deckId);
    if (idx >= 0) {
      decks[idx] = deck;
    } else {
      decks.add(deck);
    }
    await prefs.setString(decksKey, jsonEncode(decks));
  }
}

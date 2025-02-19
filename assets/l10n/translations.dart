import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Translations extends ChangeNotifier {
  static final Translations _instance = Translations._internal();
  factory Translations() => _instance;

  Translations._internal();

  Map<String, String> _localizedStrings = {}; // Inizializzazione con un valore vuoto
  String _currentLanguage = 'IT'; // Default italiano

  String get currentLanguage => _currentLanguage;

  Future<void> loadLanguage([String? languageCode]) async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = languageCode ?? prefs.getString('language') ?? 'IT';

    try {
      String jsonString = await rootBundle.loadString('lib/l10n/intl_$_currentLanguage.arb');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));

      prefs.setString('language', _currentLanguage);
    } catch (e) {
      debugPrint('Error loading translation file: $e');
      _localizedStrings = {};
    }

    notifyListeners();
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  Future<void> setLanguage(String languageCode) async {
    await loadLanguage(languageCode);
  }
}

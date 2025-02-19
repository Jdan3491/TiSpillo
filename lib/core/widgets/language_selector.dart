import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/translations.dart';

class LanguageSelector extends StatefulWidget {
  final Function() onLanguageChanged;

  const LanguageSelector({Key? key, required this.onLanguageChanged}) : super(key: key);

  @override
  _LanguageSelectorState createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  String _currentLanguage = 'IT'; // Default language

  @override
  void initState() {
    super.initState();
    _loadLanguage(); // Load the language when the widget is first created
  }

  // Load the language from SharedPreferences
  Future<void> _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLanguage = prefs.getString('language');
    setState(() {
      _currentLanguage = savedLanguage ?? 'IT'; // Default to 'IT' if no language is saved
    });

    // Load translations based on the saved language
    final translations = Translations();
    await translations.loadLanguage(_currentLanguage);
  }

  // Change the language and reload translations
  Future<void> _changeLanguage(String newLanguage) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', newLanguage); // Save the new language

    final translations = Translations();
    await translations.loadLanguage(newLanguage); // Load new language translations

    setState(() {
      _currentLanguage = newLanguage; // Update the current language
    });

    widget.onLanguageChanged(); // Notify the parent to refresh the screen
  }

  // Get the flag image for the current language
  String _getFlagForLanguage() {
    return _currentLanguage == 'IT' ? 'it.png' : 'en.png'; // Add more languages here
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Large flag icon to indicate current language
        GestureDetector(
          onTap: () {
            // Open the language menu when the flag is tapped
            showMenu<String>(
              context: context,
              position: RelativeRect.fromLTRB(100, 100, 100, 100), // Adjust position if needed
              items: [
                PopupMenuItem(
                  value: 'IT',
                  child: Row(
                    children: [
                      Image.asset('assets/flags/it.png', width: 24),
                      SizedBox(width: 8),
                      Text('ITALIANO', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'EN',
                  child: Row(
                    children: [
                      Image.asset('assets/flags/en.png', width: 24),
                      SizedBox(width: 8),
                      Text('ENGLISH', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                // Add more languages here as needed
              ],
            ).then((value) {
              if (value != null) {
                _changeLanguage(value); // Change language when selected
              }
            });
          },
          child: CircleAvatar(
            radius: 40,
            child: Image.asset(
              'assets/flags/${_getFlagForLanguage()}',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}

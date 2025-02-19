import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'core/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

Future<void> main() async {
  // Ensure Flutter bindings are initialized before using async methods
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from the .env file
  await dotenv.load();

  // Initialize Supabase with environment variables
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Load Language System Properties
  String initialLanguage = await _loadLanguage();
  print('Set Language: $initialLanguage');

  // Start the app after initialization
  runApp(TispilloApp(initialLanguage: initialLanguage));
}


Future<String> _loadLanguage() async {
  if (Platform.isAndroid) {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('language');
    if (language == null) {
      // First Fly
      await prefs.setString('language', 'IT');
      return 'IT';
    } else {
      return language;
    }
  }
  return 'IT'; // Default to Italian for other platforms if needed
}

import 'package:flutter_dotenv/flutter_dotenv.dart';
Map<String, String> get supabaseKeys {
  return {
    "url": dotenv.env['SUPABASE_URL']!, // Check (!) that confirm is not Nullable always
    "anon": dotenv.env['SUPABASE_ANON_KEY']!,
  };
}

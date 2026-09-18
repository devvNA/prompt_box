import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get url {
    const dartDefineUrl = String.fromEnvironment('SUPABASE_URL');
    if (dartDefineUrl.isNotEmpty) return dartDefineUrl;
    return dotenv.env['SUPABASE_URL'] ?? '';
  }

  static String get anonKey {
    const dartDefineKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (dartDefineKey.isNotEmpty) return dartDefineKey;
    return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }
}

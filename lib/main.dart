import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/supabase_config.dart';
import 'features/auth/screens/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
  );

  runApp(const ProviderScope(child: PromptStudioApp()));
}

class PromptStudioApp extends StatelessWidget {
  const PromptStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PROMPTBOX',
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

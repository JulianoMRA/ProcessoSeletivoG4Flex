import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fala_torcedor/core/constants.dart';
import 'package:fala_torcedor/core/theme.dart';
import 'package:fala_torcedor/views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(const FalaTorcedorApp());
}

final supabase = Supabase.instance.client;

class FalaTorcedorApp extends StatelessWidget {
  const FalaTorcedorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fala, Torcedor!',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR'), Locale('en')],
      theme: AppTheme.light,
      home: const HomeView(),
    );
  }
}

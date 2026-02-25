import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fala_torcedor/core/theme.dart';
import 'package:fala_torcedor/core/theme_provider.dart';
import 'package:fala_torcedor/views/splash_view.dart';

final themeProvider = ThemeProvider();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FalaTorcedorApp());
}

class FalaTorcedorApp extends StatelessWidget {
  const FalaTorcedorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeProvider,
      builder: (context, _) => MaterialApp(
        title: 'Fala, Torcedor!',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('pt', 'BR'), Locale('en')],
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeProvider.themeMode,
        home: const SplashView(),
      ),
    );
  }
}

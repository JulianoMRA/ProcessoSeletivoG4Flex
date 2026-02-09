import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fala_torcedor/core/constants.dart';

/// Ponto de entrada do aplicativo.
///
/// 1. [WidgetsFlutterBinding.ensureInitialized()] — garante que o Flutter
///    esteja pronto antes de chamar código assíncrono.
/// 2. [Supabase.initialize()] — conecta o app ao projeto Supabase usando
///    a URL e a chave anon definidas em [AppConstants].
/// 3. [runApp()] — inicia o widget root do app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(const FalaTorcedorApp());
}

/// Atalho global para acessar o client do Supabase em qualquer lugar do app.
/// Em vez de escrever [Supabase.instance.client] toda vez, usamos [supabase].
final supabase = Supabase.instance.client;

/// Widget root do aplicativo.
///
/// [MaterialApp] configura:
/// - O título do app
/// - O tema visual (cores, fontes, etc.)
/// - A tela inicial (home)
class FalaTorcedorApp extends StatelessWidget {
  const FalaTorcedorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fala, Torcedor!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomeView(),
    );
  }
}

/// Tela inicial temporária — apenas para validar que tudo funciona.
/// Será substituída pela tela real nas próximas fases.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fala, Torcedor!'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text(
          'Supabase conectado com sucesso! 🎉',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'db.dart';
import 'database/app_database.dart';
import 'screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  db = AppDatabase();
  // Encerra sessões ativas de dias anteriores para começar o dia com estado limpo.
  // Jogadores e estatísticas (partidasJogadas) são preservados.
  await db.encerrarSessoesAntigas();
  runApp(const SportsControlApp());
}

class SportsControlApp extends StatelessWidget {
  const SportsControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SportsControl',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B35),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF070B18),
      ),
      home: const MainScreen(),
    );
  }
}

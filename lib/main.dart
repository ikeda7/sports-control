import 'package:flutter/material.dart';

import 'db.dart';
import 'database/app_database.dart';
import 'design/design.dart';
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
      theme: SCTheme.build(),
      home: const MainScreen(),
    );
  }
}

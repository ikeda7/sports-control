// Singleton global do banco de dados.
// Separado do main.dart para evitar dependência circular:
//   signals.dart precisa de `db` → não pode importar main.dart
//   (que importa main_screen.dart → que importa signals.dart)
// Ao separar aqui, o ciclo se quebra.
import 'database/app_database.dart';

late AppDatabase db;

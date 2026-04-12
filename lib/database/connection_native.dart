import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Abre o banco SQLite nativo (Windows, Android, iOS, macOS, Linux).
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'sportscontrol.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Abre o banco SQLite via WebAssembly no browser.
/// Dados persistidos via OPFS (com fallback para IndexedDB).
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'sportscontrol',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.dart.js'),
    );
    return result.resolvedExecutor;
  });
}

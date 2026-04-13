// Worker do Drift para web — compilado para web/drift_worker.dart.js
// Comando: dart compile js -O2 -o web/drift_worker.dart.js lib/database/drift_worker.dart
import 'package:drift/wasm.dart';

void main() {
  WasmDatabase.workerMainForOpen();
}

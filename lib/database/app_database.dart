import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/jogador.dart';
import '../models/sessao.dart';
import '../models/partida.dart';
import '../models/time.dart';

part 'app_database.g.dart';

// =============================================================================
// TABELAS
// =============================================================================

@DataClassName('JogadorRow')
class JogadoresTable extends Table {
  @override
  String get tableName => 'jogadores';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text().withLength(min: 1, max: 100)();
  TextColumn get genero => text()();

  // Levantador fixo (sistema 6x0)
  BoolColumn get isLevantador =>
      boolean().withDefault(const Constant(false))();

  // Atributos de habilidade (1–5 estrelas)
  IntColumn get ataque => integer().withDefault(const Constant(3))();
  IntColumn get defesa => integer().withDefault(const Constant(3))();
  IntColumn get bloqueio => integer().withDefault(const Constant(3))();
  IntColumn get saque => integer().withDefault(const Constant(3))();
  IntColumn get passe => integer().withDefault(const Constant(3))();

  IntColumn get partidasJogadas => integer().withDefault(const Constant(0))();
}

@DataClassName('SessaoRow')
class SessoesTable extends Table {
  @override
  String get tableName => 'sessoes';

  IntColumn get id => integer().autoIncrement()();
  // Timestamp em milissegundos (DateTime.millisecondsSinceEpoch)
  IntColumn get criadaEm => integer()();
  // 'ativa' | 'encerrada'
  TextColumn get status => text().withDefault(const Constant('ativa'))();
  // Mantidos por compatibilidade; substituídos pela TimesTable
  TextColumn get rascunhoAIds =>
      text().withDefault(const Constant(''))();
  TextColumn get rascunhoBIds =>
      text().withDefault(const Constant(''))();
}

@DataClassName('CheckInRow')
class CheckInsTable extends Table {
  @override
  String get tableName => 'checkins';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessaoId => integer()();
  IntColumn get jogadorId => integer()();

  // Garante que um jogador só pode fazer check-in uma vez por sessão
  @override
  List<Set<Column>> get uniqueKeys => [
        {sessaoId, jogadorId}
      ];
}

@DataClassName('PartidaRow')
class PartidasTable extends Table {
  @override
  String get tableName => 'partidas';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessaoId => integer()();
  // IDs dos jogadores separados por vírgula: "1,3,7,12"
  TextColumn get timeAIds => text()();
  TextColumn get timeBIds => text()();
  IntColumn get placarA => integer().withDefault(const Constant(0))();
  IntColumn get placarB => integer().withDefault(const Constant(0))();
  // 'em_andamento' | 'encerrada'
  TextColumn get status =>
      text().withDefault(const Constant('em_andamento'))();
  IntColumn get iniciadaEm => integer()();
  // Nomes dos times (ex: "Time 1", "Time 2")
  TextColumn get timeANome =>
      text().withDefault(const Constant('Time A'))();
  TextColumn get timeBNome =>
      text().withDefault(const Constant('Time B'))();
}

@DataClassName('TimeRow')
class TimesTable extends Table {
  @override
  String get tableName => 'times';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessaoId => integer()();
  TextColumn get nome => text()(); // "Time 1", "Time 2", etc.
  // IDs dos jogadores separados por vírgula
  TextColumn get jogadorIds => text()();
  IntColumn get ordem => integer()(); // índice base 0
}

// =============================================================================
// BANCO DE DADOS PRINCIPAL
// =============================================================================

@DriftDatabase(
    tables: [JogadoresTable, SessoesTable, CheckInsTable, PartidasTable, TimesTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v1→v2+: dev — recria tudo
            await customStatement('DROP TABLE IF EXISTS partidas');
            await customStatement('DROP TABLE IF EXISTS checkins');
            await customStatement('DROP TABLE IF EXISTS sessoes');
            await customStatement('DROP TABLE IF EXISTS jogadores');
            await customStatement('DROP TABLE IF EXISTS times');
            await m.createAll();
            return;
          }
          if (from < 3) {
            await customStatement(
              'ALTER TABLE jogadores ADD COLUMN is_levantador INTEGER NOT NULL DEFAULT 0',
            );
          }
          if (from < 4) {
            await customStatement(
              "ALTER TABLE sessoes ADD COLUMN rascunho_a_ids TEXT NOT NULL DEFAULT ''",
            );
            await customStatement(
              "ALTER TABLE sessoes ADD COLUMN rascunho_b_ids TEXT NOT NULL DEFAULT ''",
            );
          }
          if (from < 5) {
            // v4→v5: tabela de times nomeados + nomes nas partidas
            await m.createTable(timesTable);
            await customStatement(
              "ALTER TABLE partidas ADD COLUMN time_a_nome TEXT NOT NULL DEFAULT 'Time A'",
            );
            await customStatement(
              "ALTER TABLE partidas ADD COLUMN time_b_nome TEXT NOT NULL DEFAULT 'Time B'",
            );
          }
        },
      );

  // ---------------------------------------------------------------------------
  // JOGADORES
  // ---------------------------------------------------------------------------

  Stream<List<Jogador>> watchAllJogadores() {
    return (select(jogadoresTable)
          ..orderBy([(t) => OrderingTerm.asc(t.nome)]))
        .watch()
        .map((rows) => rows.map(_jogadorRowToDomain).toList());
  }

  Future<int> insertJogador({
    required String nome,
    required Genero genero,
    bool isLevantador = false,
    required int ataque,
    required int defesa,
    required int bloqueio,
    required int saque,
    required int passe,
  }) {
    return into(jogadoresTable).insert(
      JogadoresTableCompanion.insert(
        nome: nome,
        genero: genero.name,
        isLevantador: Value(isLevantador),
        ataque: Value(ataque),
        defesa: Value(defesa),
        bloqueio: Value(bloqueio),
        saque: Value(saque),
        passe: Value(passe),
      ),
    );
  }

  Future<void> updateJogadorAtributos(
    int id, {
    required String nome,
    required bool isLevantador,
    required int ataque,
    required int defesa,
    required int bloqueio,
    required int saque,
    required int passe,
  }) async {
    await (update(jogadoresTable)..where((t) => t.id.equals(id))).write(
      JogadoresTableCompanion(
        nome: Value(nome),
        isLevantador: Value(isLevantador),
        ataque: Value(ataque),
        defesa: Value(defesa),
        bloqueio: Value(bloqueio),
        saque: Value(saque),
        passe: Value(passe),
      ),
    );
  }

  Future<int> deleteJogador(int id) {
    return (delete(jogadoresTable)..where((t) => t.id.equals(id))).go();
  }

  /// Remove todos os jogadores, check-ins e times de uma vez.
  Future<void> deleteAllJogadores() async {
    await transaction(() async {
      await delete(timesTable).go();
      await delete(checkInsTable).go();
      await delete(jogadoresTable).go();
    });
  }

  // ---------------------------------------------------------------------------
  // SESSÕES
  // ---------------------------------------------------------------------------

  Stream<Sessao?> watchSessaoAtual() {
    return (select(sessoesTable)
          ..where((t) => t.status.equals('ativa'))
          ..orderBy([(t) => OrderingTerm.desc(t.criadaEm)])
          ..limit(1))
        .watchSingleOrNull()
        .map((row) => row != null ? _sessaoRowToDomain(row) : null);
  }

  Future<Sessao?> getSessaoAtual() async {
    final row = await (select(sessoesTable)
          ..where((t) => t.status.equals('ativa'))
          ..orderBy([(t) => OrderingTerm.desc(t.criadaEm)])
          ..limit(1))
        .getSingleOrNull();
    return row != null ? _sessaoRowToDomain(row) : null;
  }

  Future<int> criarSessao() {
    return into(sessoesTable).insert(
      SessoesTableCompanion.insert(
        criadaEm: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// Cria uma sessão e faz check-in automático de todos os jogadores.
  Future<void> criarSessaoComCheckIns() async {
    await transaction(() async {
      final sessaoId = await criarSessao();
      final jogadores = await select(jogadoresTable).get();
      for (final j in jogadores) {
        await into(checkInsTable).insert(
          CheckInsTableCompanion.insert(
            sessaoId: sessaoId,
            jogadorId: j.id,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  Future<void> encerrarSessao(int sessaoId) async {
    await (update(sessoesTable)..where((t) => t.id.equals(sessaoId))).write(
      const SessoesTableCompanion(status: Value('encerrada')),
    );
  }

  // ---------------------------------------------------------------------------
  // CHECK-INS
  // ---------------------------------------------------------------------------

  /// Todos os jogadores com flag indicando se estão presentes na sessão.
  Stream<List<JogadorComStatus>> watchTodosComStatus(int sessaoId) {
    final query = select(jogadoresTable).join([
      leftOuterJoin(
        checkInsTable,
        checkInsTable.jogadorId.equalsExp(jogadoresTable.id) &
            checkInsTable.sessaoId.equals(sessaoId),
      ),
    ])
      ..orderBy([OrderingTerm.asc(jogadoresTable.nome)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final jogador = _jogadorRowToDomain(row.readTable(jogadoresTable));
        final checkin = row.readTableOrNull(checkInsTable);
        return JogadorComStatus(jogador, checkin != null);
      }).toList();
    });
  }

  /// Apenas os jogadores que fizeram check-in (para o sorteio).
  Stream<List<Jogador>> watchCheckInsDaSessao(int sessaoId) {
    final query = select(jogadoresTable).join([
      innerJoin(
        checkInsTable,
        checkInsTable.jogadorId.equalsExp(jogadoresTable.id) &
            checkInsTable.sessaoId.equals(sessaoId),
      ),
    ])
      ..orderBy([OrderingTerm.asc(jogadoresTable.nome)]);

    return query
        .watch()
        .map((rows) =>
            rows.map((r) => _jogadorRowToDomain(r.readTable(jogadoresTable))).toList());
  }

  Future<void> toggleCheckIn(int sessaoId, int jogadorId) async {
    await transaction(() async {
      final existing = await (select(checkInsTable)
            ..where((t) =>
                t.sessaoId.equals(sessaoId) & t.jogadorId.equals(jogadorId)))
          .getSingleOrNull();

      if (existing != null) {
        await (delete(checkInsTable)
              ..where((t) =>
                  t.sessaoId.equals(sessaoId) & t.jogadorId.equals(jogadorId)))
            .go();
      } else {
        await into(checkInsTable).insert(
          CheckInsTableCompanion.insert(
            sessaoId: sessaoId,
            jogadorId: jogadorId,
          ),
        );
      }
    });
  }

  /// Faz check-in de todos os jogadores na sessão (ignora os já presentes).
  Future<void> checkInTodos(int sessaoId) async {
    final jogadores = await select(jogadoresTable).get();
    await transaction(() async {
      for (final j in jogadores) {
        await into(checkInsTable).insert(
          CheckInsTableCompanion.insert(
            sessaoId: sessaoId,
            jogadorId: j.id,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  /// Remove todos os check-ins da sessão.
  Future<void> checkOutTodos(int sessaoId) async {
    await (delete(checkInsTable)
          ..where((t) => t.sessaoId.equals(sessaoId)))
        .go();
  }

  // ---------------------------------------------------------------------------
  // TIMES
  // ---------------------------------------------------------------------------

  Stream<List<Time>> watchTimesDaSessao(int sessaoId) {
    return (select(timesTable)
          ..where((t) => t.sessaoId.equals(sessaoId))
          ..orderBy([(t) => OrderingTerm.asc(t.ordem)]))
        .watch()
        .map((rows) => rows.map(_timeRowToDomain).toList());
  }

  /// Salva os times do sorteio: apaga os anteriores e insere os novos.
  Future<void> salvarTimes(int sessaoId, List<List<int>> timesIds) async {
    await transaction(() async {
      await (delete(timesTable)
            ..where((t) => t.sessaoId.equals(sessaoId)))
          .go();
      for (var i = 0; i < timesIds.length; i++) {
        await into(timesTable).insert(
          TimesTableCompanion.insert(
            sessaoId: sessaoId,
            nome: 'Time ${i + 1}',
            jogadorIds: _serializeIds(timesIds[i]),
            ordem: i,
          ),
        );
      }
    });
  }

  /// Atualiza a composição de um time (após substituição).
  Future<void> atualizarTimeJogadores(int timeId, List<int> jogadorIds) {
    return (update(timesTable)..where((t) => t.id.equals(timeId))).write(
      TimesTableCompanion(jogadorIds: Value(_serializeIds(jogadorIds))),
    );
  }

  // ---------------------------------------------------------------------------
  // PARTIDAS
  // ---------------------------------------------------------------------------

  /// Partida em andamento na sessão (no máximo uma por vez).
  Stream<Partida?> watchPartidaAtual(int sessaoId) {
    return (select(partidasTable)
          ..where((t) =>
              t.sessaoId.equals(sessaoId) &
              t.status.equals('em_andamento'))
          ..orderBy([(t) => OrderingTerm.desc(t.iniciadaEm)])
          ..limit(1))
        .watchSingleOrNull()
        .map((row) => row != null ? _partidaRowToDomain(row) : null);
  }

  /// Histórico de partidas encerradas na sessão (mais recentes primeiro).
  Stream<List<Partida>> watchHistorico(int sessaoId) {
    return (select(partidasTable)
          ..where((t) =>
              t.sessaoId.equals(sessaoId) & t.status.equals('encerrada'))
          ..orderBy([(t) => OrderingTerm.desc(t.iniciadaEm)]))
        .watch()
        .map((rows) => rows.map(_partidaRowToDomain).toList());
  }

  Future<int> criarPartida({
    required int sessaoId,
    required List<int> timeAIds,
    required List<int> timeBIds,
    String timeANome = 'Time A',
    String timeBNome = 'Time B',
  }) {
    return into(partidasTable).insert(
      PartidasTableCompanion.insert(
        sessaoId: sessaoId,
        timeAIds: _serializeIds(timeAIds),
        timeBIds: _serializeIds(timeBIds),
        timeANome: Value(timeANome),
        timeBNome: Value(timeBNome),
        iniciadaEm: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<void> incrementarPlacar(int partidaId, {required bool isTimeA}) {
    final col = isTimeA ? 'placar_a' : 'placar_b';
    return customUpdate(
      'UPDATE partidas SET $col = $col + 1 WHERE id = ?',
      variables: [Variable.withInt(partidaId)],
      updates: {partidasTable},
    );
  }

  Future<void> decrementarPlacar(int partidaId, {required bool isTimeA}) {
    final col = isTimeA ? 'placar_a' : 'placar_b';
    return customUpdate(
      'UPDATE partidas SET $col = MAX(0, $col - 1) WHERE id = ?',
      variables: [Variable.withInt(partidaId)],
      updates: {partidasTable},
    );
  }

  /// Encerra a partida e incrementa [partidasJogadas] de todos os participantes.
  Future<void> encerrarPartida(int partidaId) async {
    await transaction(() async {
      final row = await (select(partidasTable)
            ..where((t) => t.id.equals(partidaId)))
          .getSingleOrNull();
      if (row == null) return;

      await (update(partidasTable)..where((t) => t.id.equals(partidaId)))
          .write(const PartidasTableCompanion(status: Value('encerrada')));

      final todos = [
        ..._deserializeIds(row.timeAIds),
        ..._deserializeIds(row.timeBIds),
      ];

      for (final jid in todos) {
        await customUpdate(
          'UPDATE jogadores SET partidas_jogadas = partidas_jogadas + 1 WHERE id = ?',
          variables: [Variable.withInt(jid)],
          updates: {jogadoresTable},
        );
      }
    });
  }

  // ---------------------------------------------------------------------------
  // CONVERSORES (Row ↔ Domain)
  // ---------------------------------------------------------------------------

  Jogador _jogadorRowToDomain(JogadorRow row) => Jogador(
        id: row.id,
        nome: row.nome,
        genero: Genero.fromString(row.genero),
        isLevantador: row.isLevantador,
        ataque: row.ataque,
        defesa: row.defesa,
        bloqueio: row.bloqueio,
        saque: row.saque,
        passe: row.passe,
        partidasJogadas: row.partidasJogadas,
      );

  Sessao _sessaoRowToDomain(SessaoRow row) => Sessao(
        id: row.id,
        criadaEm: DateTime.fromMillisecondsSinceEpoch(row.criadaEm),
        ativa: row.status == 'ativa',
        rascunhoAIds: _deserializeIds(row.rascunhoAIds),
        rascunhoBIds: _deserializeIds(row.rascunhoBIds),
      );

  Partida _partidaRowToDomain(PartidaRow row) => Partida(
        id: row.id,
        sessaoId: row.sessaoId,
        timeAIds: _deserializeIds(row.timeAIds),
        timeBIds: _deserializeIds(row.timeBIds),
        placarA: row.placarA,
        placarB: row.placarB,
        emAndamento: row.status == 'em_andamento',
        iniciadaEm: DateTime.fromMillisecondsSinceEpoch(row.iniciadaEm),
        timeANome: row.timeANome,
        timeBNome: row.timeBNome,
      );

  Time _timeRowToDomain(TimeRow row) => Time(
        id: row.id,
        sessaoId: row.sessaoId,
        nome: row.nome,
        jogadorIds: _deserializeIds(row.jogadorIds),
        ordem: row.ordem,
      );

  String _serializeIds(List<int> ids) => ids.join(',');

  List<int> _deserializeIds(String raw) {
    if (raw.isEmpty) return [];
    return raw.split(',').map(int.parse).toList();
  }
}

// =============================================================================
// CONEXÃO
// =============================================================================

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'volleycontrol.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

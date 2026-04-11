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

  // Nível técnico: 'iniciante' | 'intermediario' | 'avancado'
  TextColumn get nivel =>
      text().withDefault(const Constant('intermediario'))();

  // Papéis serializados como CSV: 'levantador,atacante' etc.
  TextColumn get papeis => text().withDefault(const Constant(''))();

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
  // Modalidade: 'quadra' | 'areia'
  TextColumn get modalidade =>
      text().withDefault(const Constant('quadra'))();
  // Jogadores por time (quadra=6, duplas=2, trios=3)
  IntColumn get porTime => integer().withDefault(const Constant(6))();
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
  // Vitórias consecutivas na quadra. Reseta quando o time sai.
  IntColumn get vitorias => integer().withDefault(const Constant(0))();
}

// =============================================================================
// BANCO DE DADOS PRINCIPAL
// =============================================================================

@DriftDatabase(
    tables: [JogadoresTable, SessoesTable, CheckInsTable, PartidasTable, TimesTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 8;

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
          if (from < 6) {
            // v5→v6: coluna de vitórias consecutivas por time
            await customStatement(
              'ALTER TABLE times ADD COLUMN vitorias INTEGER NOT NULL DEFAULT 0',
            );
          }
          if (from < 7) {
            // v6→v7: substitui 5 atributos numéricos por nivel + papeis
            await customStatement(
              "ALTER TABLE jogadores ADD COLUMN nivel TEXT NOT NULL DEFAULT 'intermediario'",
            );
            await customStatement(
              "ALTER TABLE jogadores ADD COLUMN papeis TEXT NOT NULL DEFAULT ''",
            );
            // Converte média dos atributos antigos para nivel
            await customStatement('''
              UPDATE jogadores SET nivel = CASE
                WHEN (ataque + defesa + bloqueio + saque + passe) / 5.0 < 2.33 THEN 'iniciante'
                WHEN (ataque + defesa + bloqueio + saque + passe) / 5.0 >= 3.66 THEN 'avancado'
                ELSE 'intermediario'
              END
            ''');
            // Migra levantadores antigos para o papel correspondente
            await customStatement(
              "UPDATE jogadores SET papeis = 'levantador' WHERE is_levantador = 1",
            );
          }
          if (from < 8) {
            // v7→v8: modalidade e porTime na sessão
            await customStatement(
              "ALTER TABLE sessoes ADD COLUMN modalidade TEXT NOT NULL DEFAULT 'quadra'",
            );
            await customStatement(
              'ALTER TABLE sessoes ADD COLUMN por_time INTEGER NOT NULL DEFAULT 6',
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
    required Nivel nivel,
    required List<Papel> papeis,
  }) {
    return into(jogadoresTable).insert(
      JogadoresTableCompanion.insert(
        nome: nome,
        genero: genero.name,
        nivel: Value(nivel.name),
        papeis: Value(_serializePapeis(papeis)),
      ),
    );
  }

  Future<void> updateJogador(
    int id, {
    required String nome,
    required Genero genero,
    required Nivel nivel,
    required List<Papel> papeis,
  }) async {
    await (update(jogadoresTable)..where((t) => t.id.equals(id))).write(
      JogadoresTableCompanion(
        nome: Value(nome),
        genero: Value(genero.name),
        nivel: Value(nivel.name),
        papeis: Value(_serializePapeis(papeis)),
      ),
    );
  }

  Future<int> deleteJogador(int id) {
    return (delete(jogadoresTable)..where((t) => t.id.equals(id))).go();
  }

  /// Retorna o conjunto de nomes em minúsculo já cadastrados (para dedup).
  Future<Set<String>> getNomesJogadores() async {
    final rows = await select(jogadoresTable).get();
    return rows.map((r) => r.nome.toLowerCase()).toSet();
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

  Future<int> criarSessao({
    Modalidade modalidade = Modalidade.quadra,
    int porTime = 6,
  }) {
    return into(sessoesTable).insert(
      SessoesTableCompanion.insert(
        criadaEm: DateTime.now().millisecondsSinceEpoch,
        modalidade: Value(modalidade.name),
        porTime: Value(porTime),
      ),
    );
  }

  /// Cria uma sessão e faz check-in automático de todos os jogadores.
  Future<void> criarSessaoComCheckIns({
    Modalidade modalidade = Modalidade.quadra,
    int porTime = 6,
  }) async {
    await transaction(() async {
      final sessaoId = await criarSessao(modalidade: modalidade, porTime: porTime);
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

  /// Encerra automaticamente sessões ativas criadas em dias anteriores.
  /// Chamado no startup do app para garantir estado limpo a cada dia.
  Future<void> encerrarSessoesAntigas() async {
    final hoje = DateTime.now();
    final inicioDoDia =
        DateTime(hoje.year, hoje.month, hoje.day).millisecondsSinceEpoch;

    await (update(sessoesTable)
          ..where((t) =>
              t.status.equals('ativa') &
              t.criadaEm.isSmallerThanValue(inicioDoDia)))
        .write(const SessoesTableCompanion(status: Value('encerrada')));
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
  Future<void> salvarTimes(
    int sessaoId,
    List<List<int>> timesIds, {
    String nomePrefix = 'Time',
  }) async {
    await transaction(() async {
      await (delete(timesTable)
            ..where((t) => t.sessaoId.equals(sessaoId)))
          .go();
      for (var i = 0; i < timesIds.length; i++) {
        await into(timesTable).insert(
          TimesTableCompanion.insert(
            sessaoId: sessaoId,
            nome: '$nomePrefix ${i + 1}',
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

  /// Encerra a partida, incrementa [partidasJogadas] de todos os participantes
  /// e aplica a lógica de rotação "ganhou 2 sai":
  /// - Vencedor ganha +1 vitória; perdedor reseta para 0.
  /// - Se o vencedor chegar a 2 vitórias, ambos os times saem (reset para 0).
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

      // Rotação: empate não altera vitórias
      if (row.placarA == row.placarB) return;

      final nomeVencedor =
          row.placarA > row.placarB ? row.timeANome : row.timeBNome;
      final nomePerdedor =
          row.placarA > row.placarB ? row.timeBNome : row.timeANome;

      final timeVencedor = await (select(timesTable)
            ..where((t) =>
                t.sessaoId.equals(row.sessaoId) &
                t.nome.equals(nomeVencedor)))
          .getSingleOrNull();
      final timePerdedor = await (select(timesTable)
            ..where((t) =>
                t.sessaoId.equals(row.sessaoId) &
                t.nome.equals(nomePerdedor)))
          .getSingleOrNull();

      if (timeVencedor == null) return;

      final novasVitorias = timeVencedor.vitorias + 1;

      if (novasVitorias >= 2) {
        // Vencedor ganhou 2 seguidas: ambos saem da quadra → reset tudo
        await customUpdate(
          'UPDATE times SET vitorias = 0 WHERE sessao_id = ?',
          variables: [Variable.withInt(row.sessaoId)],
          updates: {timesTable},
        );
      } else {
        // Vencedor fica com 1 vitória; perdedor sai (reset 0)
        await (update(timesTable)
              ..where((t) => t.id.equals(timeVencedor.id)))
            .write(TimesTableCompanion(vitorias: Value(novasVitorias)));
        if (timePerdedor != null) {
          await (update(timesTable)
                ..where((t) => t.id.equals(timePerdedor.id)))
              .write(const TimesTableCompanion(vitorias: Value(0)));
        }
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
        nivel: Nivel.fromString(row.nivel),
        papeis: _deserializePapeis(row.papeis),
        partidasJogadas: row.partidasJogadas,
      );

  Sessao _sessaoRowToDomain(SessaoRow row) => Sessao(
        id: row.id,
        criadaEm: DateTime.fromMillisecondsSinceEpoch(row.criadaEm),
        ativa: row.status == 'ativa',
        modalidade: Modalidade.fromString(row.modalidade),
        porTime: row.porTime,
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
        vitorias: row.vitorias,
      );

  String _serializeIds(List<int> ids) => ids.join(',');

  List<int> _deserializeIds(String raw) {
    if (raw.isEmpty) return [];
    return raw.split(',').map(int.parse).toList();
  }

  String _serializePapeis(List<Papel> papeis) =>
      papeis.map((p) => p.name).join(',');

  List<Papel> _deserializePapeis(String raw) {
    if (raw.isEmpty) return [];
    return raw.split(',').map(Papel.fromString).toList();
  }
}

// =============================================================================
// CONEXÃO
// =============================================================================

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'sportscontrol.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

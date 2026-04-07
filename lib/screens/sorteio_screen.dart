import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../db.dart';
import '../models/jogador.dart';
import '../models/time.dart';
import '../signals.dart';

// ─── Cores por ordem do time ─────────────────────────────────────────────────
const _coresTimes = [
  Color(0xFFFF6B35), // Time 1 — laranja
  Color(0xFF00BCD4), // Time 2 — ciano
  Color(0xFF4CAF50), // Time 3 — verde
  Color(0xFF9C27B0), // Time 4 — roxo
  Color(0xFFFF9800), // Time 5 — âmbar
  Color(0xFF2196F3), // Time 6 — azul
];

Color _corTime(int ordem) => _coresTimes[ordem % _coresTimes.length];

// ─── Snake-draft generalizado (N times) ──────────────────────────────────────
// Ordena por pesoTecnico desc e distribui em snake ABBA... para equalizar somas.
List<List<Jogador>> _sortearTimes(List<Jogador> presentes, int porTime) {
  final n = presentes.length ~/ porTime;
  if (n < 2) return [];

  final shuffled = List<Jogador>.from(presentes)..shuffle(Random());
  shuffled.sort((a, b) => b.pesoTecnico.compareTo(a.pesoTecnico));

  final times = List.generate(n, (_) => <Jogador>[]);
  final jogando = shuffled.take(n * porTime).toList();

  for (var i = 0; i < jogando.length; i++) {
    final round = i ~/ n;
    final posInRound = i % n;
    final teamIndex = round.isEven ? posInRound : (n - 1 - posInRound);
    times[teamIndex].add(jogando[i]);
  }

  return times;
}

// ─── Geração da escala round-robin ───────────────────────────────────────────
// Retorna pares (índiceA, índiceB) sem que o mesmo time jogue partidas seguidas.
List<(int, int)> _gerarEscala(int n) {
  if (n < 2) return [];
  if (n == 2) return [(0, 1)];

  // Todos os pares únicos
  final todos = <(int, int)>[];
  for (var i = 0; i < n; i++) {
    for (var j = i + 1; j < n; j++) {
      todos.add((i, j));
    }
  }

  // Reordena para minimizar repetição de times consecutivos (greedy)
  final escala = <(int, int)>[];
  final restantes = List<(int, int)>.from(todos);

  while (restantes.isNotEmpty) {
    final prev = escala.isEmpty ? null : escala.last;
    final idx = prev == null
        ? 0
        : restantes.indexWhere((p) =>
            p.$1 != prev.$1 &&
            p.$1 != prev.$2 &&
            p.$2 != prev.$1 &&
            p.$2 != prev.$2);
    escala.add(restantes.removeAt(idx == -1 ? 0 : idx));
  }

  return escala;
}

// ─── Signal local ─────────────────────────────────────────────────────────────
final _porTimeSignal = signal<int>(6);

// ─── Tela ─────────────────────────────────────────────────────────────────────
class SorteioScreen extends StatelessWidget {
  const SorteioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF070B18), Color(0xFF0D1F3C), Color(0xFF1A0A2E)],
          ),
        ),
        child: SafeArea(child: Watch((ctx) => _buildConteudo(ctx))),
      ),
    );
  }

  Widget _buildConteudo(BuildContext context) {
    final sessao = sessaoAtualSignal.value.value;
    final checkins = checkinsSignal.value.value ?? [];
    final times = timesSignal.value.value ?? [];
    final jogMap = jogadoresMapSignal.value;
    final porTime = _porTimeSignal.value;

    if (sessao == null) {
      return _buildMsg(Icons.play_circle_outline_rounded,
          'Nenhum rachão ativo', 'Inicie o rachão na aba Check-in');
    }

    if (checkins.isEmpty) {
      return _buildMsg(Icons.how_to_reg_outlined, 'Ninguém fez check-in',
          'Confirme a presença dos jogadores na aba Check-in');
    }

    // Bench = jogadores no check-in mas não em nenhum time
    final timesIds = times.expand((t) => t.jogadorIds).toSet();
    final bancal = checkins.where((j) => !timesIds.contains(j.id)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(checkins.length, porTime),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (times.isEmpty) ...[
                  _buildBotaoSortear(context, checkins, porTime, sessao.id),
                ] else ...[
                  _buildTimesGrid(context, times, jogMap, bancal, sessao.id),
                  if (bancal.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildBancal(bancal),
                  ],
                  const SizedBox(height: 16),
                  _buildEscala(context, times, jogMap, sessao.id),
                  const SizedBox(height: 16),
                  _buildBotaoResortear(
                      context, checkins, porTime, sessao.id),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(int presentes, int porTime) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sorteio',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2)),
                Text('$presentes no check-in',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 14)),
              ],
            ),
          ),
          _buildPorTimeControl(porTime),
        ],
      ),
    );
  }

  Widget _buildPorTimeControl(int porTime) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.15)),
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Por time:',
                  style: TextStyle(
                      color: Colors.white54, fontSize: 12)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  if (_porTimeSignal.value > 2) _porTimeSignal.value--;
                },
                child: const Icon(Icons.remove_circle_outline,
                    color: Colors.white54, size: 22),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10),
                child: Text('$porTime',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
              GestureDetector(
                onTap: () => _porTimeSignal.value++,
                child: const Icon(Icons.add_circle_outline,
                    color: Colors.white54, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Grid de times ──────────────────────────────────────────────────────────
  Widget _buildTimesGrid(
    BuildContext context,
    List<Time> times,
    Map<int, Jogador> jogMap,
    List<Jogador> bancal,
    int sessaoId,
  ) {
    if (times.length == 2) {
      // Layout lado a lado para 2 times
      return LayoutBuilder(builder: (ctx, constraints) {
        final isWide = constraints.maxWidth > 520;
        final cardA = _buildTimeCard(
            context, times[0], jogMap, bancal, sessaoId);
        final cardB = _buildTimeCard(
            context, times[1], jogMap, bancal, sessaoId);
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cardA),
              const SizedBox(width: 12),
              Expanded(child: cardB),
            ],
          );
        }
        return Column(
            children: [cardA, const SizedBox(height: 12), cardB]);
      });
    }

    // 3+ times: lista vertical
    return Column(
      children: [
        for (var i = 0; i < times.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _buildTimeCard(
              context, times[i], jogMap, bancal, sessaoId),
        ],
      ],
    );
  }

  Widget _buildTimeCard(
    BuildContext context,
    Time time,
    Map<int, Jogador> jogMap,
    List<Jogador> bancal,
    int sessaoId,
  ) {
    final cor = _corTime(time.ordem);
    final jogadores = time.jogadorIds
        .map((id) => jogMap[id])
        .whereType<Jogador>()
        .toList();
    final pesoMedio = jogadores.isEmpty
        ? 0.0
        : jogadores.fold(0.0, (s, j) => s + j.pesoTecnico) /
            jogadores.length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: cor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: cor.withValues(alpha: 0.4), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho do time
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.15),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15)),
                ),
                child: Row(
                  children: [
                    Text(time.nome,
                        style: TextStyle(
                            color: cor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text(
                      'peso ${(pesoMedio * 100).round()}% médio',
                      style: TextStyle(
                          color: cor.withValues(alpha: 0.6),
                          fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    // Botão substituição
                    if (bancal.isNotEmpty)
                      GestureDetector(
                        onTap: () => _dialogSubstituir(
                            context, time, jogadores, bancal, sessaoId),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9800)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFFF9800)
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Icon(Icons.swap_horiz_rounded,
                              color: Color(0xFFFF9800), size: 16),
                        ),
                      ),
                  ],
                ),
              ),
              // Jogadores
              ...jogadores.map((j) => Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 10, 16, 2),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor:
                              cor.withValues(alpha: 0.2),
                          child: Text(j.nome[0].toUpperCase(),
                              style: TextStyle(
                                  color: cor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(j.nome,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14)),
                        ),
                        if (j.isLevantador)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            margin:
                                const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700)
                                  .withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(5),
                              border: Border.all(
                                  color: const Color(0xFFFFD700)
                                      .withValues(alpha: 0.5)),
                            ),
                            child: const Text('LEV',
                                style: TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold)),
                          ),
                        Text(
                          '${(j.pesoTecnico * 100).round()}%',
                          style: TextStyle(
                              color: cor.withValues(alpha: 0.6),
                              fontSize: 11),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // ── Banco (jogadores fora dos times) ─────────────────────────────────────
  Widget _buildBancal(List<Jogador> bancal) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.queue, color: Colors.white38, size: 16),
                const SizedBox(width: 6),
                Text('Banco (${bancal.length})',
                    style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: bancal
                    .map((j) => Chip(
                          label: Text(j.nome,
                              style:
                                  const TextStyle(fontSize: 12)),
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.08),
                          side: BorderSide(
                              color: Colors.white
                                  .withValues(alpha: 0.15)),
                          labelStyle: const TextStyle(
                              color: Colors.white70),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Escala de partidas (round-robin) ──────────────────────────────────────
  Widget _buildEscala(
    BuildContext context,
    List<Time> times,
    Map<int, Jogador> jogMap,
    int sessaoId,
  ) {
    final escala = _gerarEscala(times.length);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: Colors.white54, size: 16),
                    const SizedBox(width: 8),
                    const Text('Escala de Partidas',
                        style: TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('${escala.length} jogo${escala.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                            color: Colors.white30, fontSize: 12)),
                  ],
                ),
              ),
              const Divider(
                  color: Colors.white12, height: 1, thickness: 1),
              ...escala.asMap().entries.map((e) {
                final num = e.key + 1;
                final par = e.value;
                final tA = times[par.$1];
                final tB = times[par.$2];
                final corA = _corTime(tA.ordem);
                final corB = _corTime(tB.ordem);

                return _buildEscalaItem(
                  context,
                  num: num,
                  tA: tA,
                  tB: tB,
                  corA: corA,
                  corB: corB,
                  sessaoId: sessaoId,
                  isLast: num == escala.length,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEscalaItem(
    BuildContext context, {
    required int num,
    required Time tA,
    required Time tB,
    required Color corA,
    required Color corB,
    required int sessaoId,
    required bool isLast,
  }) {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Número do jogo
              SizedBox(
                width: 24,
                child: Text('#$num',
                    style: const TextStyle(
                        color: Colors.white30, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              // Time A
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: corA),
                    ),
                    const SizedBox(width: 6),
                    Text(tA.nome,
                        style: TextStyle(
                            color: corA,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              // vs
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('vs',
                    style: TextStyle(
                        color: Colors.white30, fontSize: 12)),
              ),
              // Time B
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(tB.nome,
                        style: TextStyle(
                            color: corB,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: corB),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Botão iniciar
              GestureDetector(
                onTap: () async {
                  await db.criarPartida(
                    sessaoId: sessaoId,
                    timeAIds: tA.jogadorIds,
                    timeBIds: tB.jogadorIds,
                    timeANome: tA.nome,
                    timeBNome: tB.nome,
                  );
                  tabIndexSignal.value = 3;
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFF4CAF50)
                            .withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.play_arrow_rounded,
                          color: Color(0xFF4CAF50), size: 16),
                      SizedBox(width: 4),
                      Text('Iniciar',
                          style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
              color: Colors.white12,
              height: 1,
              thickness: 1,
              indent: 48),
      ],
    );
  }

  // ── Botão sortear (estado inicial) ────────────────────────────────────────
  Widget _buildBotaoSortear(
    BuildContext context,
    List<Jogador> checkins,
    int porTime,
    int sessaoId,
  ) {
    final nTimes = checkins.length ~/ porTime;
    final pode = nTimes >= 2;

    return Column(
      children: [
        const SizedBox(height: 40),
        Icon(Icons.shuffle_rounded,
            size: 64,
            color: Colors.white.withValues(alpha: 0.12)),
        const SizedBox(height: 16),
        if (!pode)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'São necessários pelo menos ${porTime * 2} jogadores ($porTime por time) para sortear 2 times.',
              style: const TextStyle(
                  color: Colors.white38, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              '${checkins.length} jogadores → $nTimes times de $porTime',
              style: const TextStyle(
                  color: Colors.white54, fontSize: 13),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: pode
                  ? const Color(0xFFFF6B35)
                  : Colors.white.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon:
                const Icon(Icons.shuffle_rounded, size: 22),
            label: const Text('Sortear Times',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            onPressed: pode
                ? () async {
                    final novosTimes =
                        _sortearTimes(checkins, porTime);
                    await db.salvarTimes(
                      sessaoId,
                      novosTimes
                          .map((t) => t.map((j) => j.id).toList())
                          .toList(),
                    );
                  }
                : null,
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // ── Botão re-sortear ──────────────────────────────────────────────────────
  Widget _buildBotaoResortear(
    BuildContext context,
    List<Jogador> checkins,
    int porTime,
    int sessaoId,
  ) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white54,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      icon: const Icon(Icons.refresh_rounded, size: 18),
      label: const Text('Re-sortear'),
      onPressed: () => _confirmarResortear(context, checkins, porTime, sessaoId),
    );
  }

  void _confirmarResortear(BuildContext context, List<Jogador> checkins,
      int porTime, int sessaoId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1F3C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text('Re-sortear os times?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Os times atuais serão descartados e um novo sorteio será feito.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white38)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35)),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final novosTimes = _sortearTimes(checkins, porTime);
              await db.salvarTimes(
                sessaoId,
                novosTimes
                    .map((t) => t.map((j) => j.id).toList())
                    .toList(),
              );
            },
            child: const Text('Re-sortear'),
          ),
        ],
      ),
    );
  }

  // ── Dialog de substituição por time ──────────────────────────────────────
  /// Substituição dentro de um time específico.
  /// Bancal = jogadores no check-in que não estão em nenhum time.
  /// Prioridade de sugestão: 1º menos partidas jogadas, 2º peso mais próximo.
  void _dialogSubstituir(
    BuildContext context,
    Time time,
    List<Jogador> jogadoresDoTime,
    List<Jogador> bancal,
    int sessaoId,
  ) {
    Jogador? ausente;
    Jogador? substituto;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final sugestoes = ausente == null
              ? bancal
              : ([...bancal]
                ..sort((a, b) {
                  final jDiff =
                      a.partidasJogadas.compareTo(b.partidasJogadas);
                  if (jDiff != 0) return jDiff;
                  return (a.pesoTecnico - ausente!.pesoTecnico)
                      .abs()
                      .compareTo(
                          (b.pesoTecnico - ausente!.pesoTecnico).abs());
                }));

          return AlertDialog(
            backgroundColor: const Color(0xFF0D1F3C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                  color: const Color(0xFFFF9800).withValues(alpha: 0.3)),
            ),
            title: Text('Substituir em ${time.nome}',
                style: const TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quem vai faltar?',
                      style: TextStyle(
                          color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: jogadoresDoTime
                        .map((j) => ChoiceChip(
                              label: Text(j.nome,
                                  style:
                                      const TextStyle(fontSize: 12)),
                              selected: ausente?.id == j.id,
                              onSelected: (_) => setState(() {
                                ausente = j;
                                substituto = null;
                              }),
                              selectedColor: const Color(0xFFFF9800)
                                  .withValues(alpha: 0.3),
                              labelStyle: TextStyle(
                                color: ausente?.id == j.id
                                    ? const Color(0xFFFF9800)
                                    : Colors.white70,
                              ),
                              side: BorderSide(
                                color: ausente?.id == j.id
                                    ? const Color(0xFFFF9800)
                                        .withValues(alpha: 0.6)
                                    : Colors.white
                                        .withValues(alpha: 0.15),
                              ),
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.05),
                            ))
                        .toList(),
                  ),
                  if (ausente != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                        'Quem entra? (prioridade: menos partidas jogadas)',
                        style: TextStyle(
                            color: Colors.white54, fontSize: 13)),
                    const SizedBox(height: 8),
                    ...sugestoes.map((j) {
                      final pesoDiff =
                          ((j.pesoTecnico - ausente!.pesoTecnico) * 100)
                              .abs()
                              .round();
                      final minPartidas = sugestoes
                          .map((s) => s.partidasJogadas)
                          .reduce((a, b) => a < b ? a : b);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: InkWell(
                          onTap: () =>
                              setState(() => substituto = j),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: substituto?.id == j.id
                                  ? const Color(0xFF4CAF50)
                                      .withValues(alpha: 0.15)
                                  : Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: substituto?.id == j.id
                                    ? const Color(0xFF4CAF50)
                                        .withValues(alpha: 0.5)
                                    : Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(j.nome,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withValues(alpha: 0.08),
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${j.partidasJogadas}j',
                                    style: TextStyle(
                                      color:
                                          j.partidasJogadas == minPartidas
                                              ? const Color(0xFF4CAF50)
                                              : Colors.white54,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  pesoDiff == 0 ? '=' : '±$pesoDiff%',
                                  style: TextStyle(
                                    color: pesoDiff <= 10
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFFFF9800),
                                    fontSize: 11,
                                  ),
                                ),
                                if (j.isLevantador) ...[
                                  const SizedBox(width: 6),
                                  const Text('LEV',
                                      style: TextStyle(
                                          color: Color(0xFFFFD700),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar',
                    style: TextStyle(color: Colors.white38)),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800)),
                onPressed: ausente != null && substituto != null
                    ? () async {
                        final novosIds = time.jogadorIds
                            .map((id) =>
                                id == ausente!.id ? substituto!.id : id)
                            .toList();
                        await db.atualizarTimeJogadores(
                            time.id, novosIds);
                        if (ctx.mounted) Navigator.of(ctx).pop();
                      }
                    : null,
                child: const Text('Confirmar'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Mensagem de estado vazio ───────────────────────────────────────────────
  Widget _buildMsg(IconData icon, String titulo, String sub) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          Text(titulo,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(sub,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 14),
                textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../db.dart';
import '../models/jogador.dart';
import '../models/sessao.dart';
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

// ─── Algoritmo de sorteio (N times) ──────────────────────────────────────────
// Garante regras da modalidade e Regra de Ocupação Total: Não deixa banco
// Criação de Vagas Dinâmicas: Preenche com emprestados nos times incompletos
List<List<Jogador>> _sortearTimes(
  List<Jogador> presentes,
  int porTime, {
  Modalidade modalidade = Modalidade.quadra,
}) {
  final n = (presentes.length / porTime).ceil();
  if (n < 2) return [];
  final rng = Random();

  final timesFixos = List.generate(n, (_) => <Jogador>[]);
  final Set<int> alocados = {};

  final int timesCompletosNum = presentes.length ~/ porTime;
  final int resto = presentes.length % porTime;

  List<int> capacidade = List.generate(n, (i) => i < timesCompletosNum ? porTime : resto);
  if (resto == 0) capacidade = List.generate(n, (_) => porTime);

  if (modalidade == Modalidade.quadra) {
    // 1. Levantadores: menos jogos têm prioridade
    final levs = presentes.where((j) => j.isLevantador).toList()
      ..sort((a, b) => a.partidasJogadas.compareTo(b.partidasJogadas));
    for (var i = 0; i < n && i < levs.length; i++) {
      timesFixos[i].add(levs[i]);
      alocados.add(levs[i].id);
    }

    // 2. Mulheres: garante ao menos 1 por time (melhores primeiro) se houver espaço
    final mulheres = presentes
        .where((j) => !alocados.contains(j.id) && j.genero == Genero.feminino)
        .toList()
      ..shuffle(rng)
      ..sort((a, b) => b.pesoTecnico.compareTo(a.pesoTecnico));
    for (var i = 0; i < n && mulheres.isNotEmpty; i++) {
      final jaTem = timesFixos[i].any((j) => j.genero == Genero.feminino);
      if (!jaTem && timesFixos[i].length < capacidade[i]) {
        final m = mulheres.removeAt(0);
        timesFixos[i].add(m);
        alocados.add(m.id);
      }
    }
  }

  // 3. Restantes → snake-draft respeitando a capacidade fixa
  final restantes = presentes
      .where((j) => !alocados.contains(j.id))
      .toList()
    ..shuffle(rng)
    ..sort((a, b) => b.pesoTecnico.compareTo(a.pesoTecnico));

  final slots = List.generate(n, (i) => capacidade[i] - timesFixos[i].length);
  final fillOrder = <int>[];
  var fwd = true;
  while (fillOrder.length < restantes.length) {
    final seq = fwd
        ? List.generate(n, (i) => i)
        : List.generate(n, (i) => n - 1 - i);
    fwd = !fwd;
    var addedAny = false;
    for (final ti in seq) {
      if (slots[ti] > 0 && fillOrder.length < restantes.length) {
        fillOrder.add(ti);
        slots[ti]--;
        addedAny = true;
      }
    }
    if (!addedAny) break;
  }

  for (var i = 0; i < restantes.length && i < fillOrder.length; i++) {
    timesFixos[fillOrder[i]].add(restantes[i]);
  }

  // 4. Criação Dinâmica Das Vagas Completas (completa até porTime, não até 6:
  //    na areia porTime é 2 ou 3)
  final timesCompletos = <List<Jogador>>[];
  for (int i = 0; i < n; i++) {
    final fixos = timesFixos[i];
    final faltam = porTime - fixos.length;
    final completos = List<Jogador>.from(fixos);

    if (faltam > 0) {
      final candidatos = timesFixos.asMap().entries
          .where((e) => e.key != i)
          .expand((e) => e.value)
          .toList();

      candidatos.sort((a, b) {
        int cmp = a.partidasJogadas.compareTo(b.partidasJogadas);
        if (cmp == 0) return (a.id.hashCode ^ i.hashCode).compareTo(b.id.hashCode ^ i.hashCode);
        return cmp;
      });

      if (modalidade == Modalidade.quadra && !fixos.any((j) => j.isLevantador)) {
        final levIndex = candidatos.indexWhere((j) => j.isLevantador);
        if (levIndex != -1) {
          final selecionado = candidatos.removeAt(levIndex);
          completos.add(selecionado.copyWith(isEmprestado: true));
        }
      }

      while (completos.length < porTime && candidatos.isNotEmpty) {
        final selecionado = candidatos.removeAt(0);
        completos.add(selecionado.copyWith(isEmprestado: true));
      }
    }
    timesCompletos.add(completos);
  }

  return timesCompletos;
}

// ─── Geração da escala round-robin ───────────────────────────────────────────
List<(int, int)> _gerarEscala(int n) {
  if (n < 2) return [];
  if (n == 2) return [(0, 1)];

  final todos = <(int, int)>[];
  for (var i = 0; i < n; i++) {
    for (var j = i + 1; j < n; j++) {
      todos.add((i, j));
    }
  }

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

// ─── Recomendação da próxima partida ─────────────────────────────────────────
(Time, Time)? _recomendarProxima(
    List<Time> times, Map<int, Jogador> jogMap) {
  if (times.length < 2) return null;

  int totalJogos(Time t) => t.jogadorIds
      .map((id) => jogMap[id]?.partidasJogadas ?? 0)
      .fold(0, (a, b) => a + b);

  final defensor = times.where((t) => t.vitorias == 1).firstOrNull;
  final espera = times.where((t) => t.vitorias == 0).toList()
    ..sort((a, b) => totalJogos(a).compareTo(totalJogos(b)));

  if (defensor != null && espera.isNotEmpty) {
    return (defensor, espera.first);
  }
  if (espera.length >= 2) return (espera[0], espera[1]);
  return null;
}

// ─── Empréstimos Dinâmicos ───────────────────────────────────────────────────
List<Jogador> _calcularEmprestados({
  required Time time,
  required int porTime,
  required List<Time> todosTimes,
  required Map<int, Jogador> jogMap,
  Time? oponente,
}) {
  final faltam = porTime - time.jogadorIds.length;
  if (faltam <= 0) return [];

  // Exclui o próprio time e o oponente (se houver) para evitar conflitos!
  final timesLivres = todosTimes
      .where((t) => t.id != time.id && t.id != oponente?.id)
      .toList();
      
  final candidatos = timesLivres
      .expand((t) => t.jogadorIds.map((id) => jogMap[id]))
      .whereType<Jogador>()
      .toList();

  // Prioriza jogadores com menos partidas jogadas para rodar o banco imaginário de forma justa
  // Usa um hash baseado nos IDs para ser "aleatório" porém determinístico (evita que a tela pisque a cada frame)
  candidatos.sort((a, b) {
    int cmp = a.partidasJogadas.compareTo(b.partidasJogadas);
    if (cmp == 0) {
      final hashA = a.id.hashCode ^ time.id.hashCode ^ (oponente?.id.hashCode ?? 0);
      final hashB = b.id.hashCode ^ time.id.hashCode ^ (oponente?.id.hashCode ?? 0);
      return hashA.compareTo(hashB);
    }
    return cmp;
  });

  final emprestados = <Jogador>[];

  // 1. REQUISITO ESTRITO: O time de destino precisa OBRIGATORIAMENTE de um levantador?
  final temLevantadorOriginal = time.jogadorIds
      .map((id) => jogMap[id])
      .whereType<Jogador>()
      .any((j) => j.isLevantador);

  if (!temLevantadorOriginal) {
    // Busca o primeiro candidato livre que seja Levantador
    final levIndex = candidatos.indexWhere((j) => j.isLevantador);
    if (levIndex != -1) {
      emprestados.add(candidatos.removeAt(levIndex));
    }
  }

  // 2. Preenche o que sobrou
  while (emprestados.length < faltam && candidatos.isNotEmpty) {
    emprestados.add(candidatos.removeAt(0));
  }

  return emprestados;
}

// ─── Signal local ─────────────────────────────────────────────────────────────
final _porTimeSignal = signal<int>(6);

// ─── Tela ─────────────────────────────────────────────────────────────────────
bool _isAlocandoAtrasados = false;

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

    if (sessao == null) {
      return _buildMsg(Icons.play_circle_outline_rounded,
          'Nenhum rachão ativo', 'Inicie o rachão na aba Check-in');
    }

    // Para areia o porTime é fixo na sessão; para quadra o usuário pode ajustar.
    final isAreia = sessao.modalidade == Modalidade.areia;
    final porTime =
        isAreia ? sessao.porTime : _porTimeSignal.value;

    if (checkins.isEmpty) {
      return _buildMsg(Icons.how_to_reg_outlined, 'Ninguém fez check-in',
          'Confirme a presença dos jogadores na aba Check-in');
    }

    final timesIds = times.expand((t) => t.jogadorIds).toSet();
    final bancal = checkins.where((j) => !timesIds.contains(j.id)).toList();

    // ─── Alocação Automática de Atrasados ─────────────────────────────────
    if (times.isNotEmpty && bancal.isNotEmpty && !_isAlocandoAtrasados) {
      final timesIncompletos = times.where((t) => t.jogadorIds.length < porTime).toList();
      if (timesIncompletos.isNotEmpty) {
        _isAlocandoAtrasados = true;
        Future.microtask(() async {
          await _alocarJogadoresAtrasados(bancal, porTime, jogMap);
          _isAlocandoAtrasados = false;
        });
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(checkins.length, porTime, sessao),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (times.isEmpty) ...[
                  _buildBotaoSortear(context, checkins, porTime, sessao),
                ] else ...[
                  _buildTimesGrid(context, times, jogMap, bancal, sessao.id),
                  if (bancal.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildBancal(bancal),
                  ],
                  const SizedBox(height: 16),
                  _buildProximaPartida(context, times, jogMap, sessao.id),
                  const SizedBox(height: 16),
                  _buildEscala(context, times, jogMap, sessao.id),
                  const SizedBox(height: 16),
                  _buildBotaoResortear(context, checkins, porTime, sessao),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _alocarJogadoresAtrasados(
    List<Jogador> atrasados,
    int porTime,
    Map<int, Jogador> jogMap,
  ) async {
    try {
      List<Time> timesAtualizados = List.from(timesSignal.value.value ?? []);

      for (final atrasado in atrasados) {
        final timesIncompletos = timesAtualizados.where((t) => t.jogadorIds.length < porTime).toList();
        
        if (timesIncompletos.isEmpty) break; // Não há mais vagas

        Time? timeDestino;

        // 1. Prioridade Levantador: Se o atrasado for levantador, buscar time sem levantador
        if (atrasado.isLevantador) {
          timeDestino = timesIncompletos.where((t) {
            final temLev = t.jogadorIds.any((id) => jogMap[id]?.isLevantador == true);
            return !temLev;
          }).firstOrNull;
        }

        // 2. Se não for levantador (ou não achou vaga de levantador), vai para o time mais desfalcado
        if (timeDestino == null) {
          timesIncompletos.sort((a, b) => a.jogadorIds.length.compareTo(b.jogadorIds.length));
          timeDestino = timesIncompletos.first;
        }

        final novosIds = [...timeDestino.jogadorIds, atrasado.id];
        
        // Atualiza na memória para a próxima iteração do loop
        final idx = timesAtualizados.indexWhere((t) => t.id == timeDestino!.id);
        if (idx != -1) {
          timesAtualizados[idx] = timeDestino.copyWith(jogadorIds: novosIds);
        }

        await db.atualizarTimeJogadores(timeDestino.id, novosIds);
      }
    } finally {
      _isAlocandoAtrasados = false;
    }
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(int presentes, int porTime, Sessao sessao) {
    final isAreia = sessao.modalidade == Modalidade.areia;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text('Sorteio',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2)),
                  if (isAreia) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFFFFD700)
                                .withValues(alpha: 0.4)),
                      ),
                      child: Text('🏖️ ${sessao.prefixoTime}s',
                          style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ]),
                Text('$presentes no check-in',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 14)),
              ],
            ),
          ),
          if (!isAreia) _buildPorTimeControl(porTime),
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
    final jogadoresOriginais = time.jogadorIds
        .map((id) => jogMap[id])
        .whereType<Jogador>()
        .toList();

    final todosTimes = timesSignal.value.value ?? [];
    final emprestados = _calcularEmprestados(
      time: time,
      porTime: _porTimeSignal.value,
      todosTimes: todosTimes,
      jogMap: jogMap,
    );

    final todosJogadores = [...jogadoresOriginais, ...emprestados];
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
                    if (time.vitorias > 0) ...[
                      const SizedBox(width: 8),
                      _buildVitoriasBadge(time.vitorias),
                    ],
                    const Spacer(),
                    Text(
                      _resumoNivel(todosJogadores),
                      style: TextStyle(
                          color: cor.withValues(alpha: 0.6),
                          fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    // Botão substituição — sempre visível
                    GestureDetector(
                      onTap: () => _dialogSubstituir(
                          context, time, jogadoresOriginais, bancal, sessaoId),
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
              ...todosJogadores.map((j) {
                final isEmprestado = emprestados.any((e) => e.id == j.id);
                return Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 10, 16, 2),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: isEmprestado 
                              ? Colors.white.withValues(alpha: 0.1) 
                              : cor.withValues(alpha: 0.2),
                          child: Text(j.nome[0].toUpperCase(),
                              style: TextStyle(
                                  color: isEmprestado ? Colors.white54 : cor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(j.nome,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: isEmprestado ? Colors.white70 : Colors.white,
                                        fontWeight: isEmprestado ? FontWeight.w400 : FontWeight.w500,
                                        fontStyle: isEmprestado ? FontStyle.italic : FontStyle.normal,
                                        fontSize: 14)),
                              ),
                              if (isEmprestado) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                  ),
                                  child: const Text('EMP',
                                    style: TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
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
                        if (j.genero == Genero.feminino)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(Icons.female_rounded,
                                color: const Color(0xFFE91E8C)
                                    .withValues(alpha: 0.8),
                                size: 14),
                          ),
                        Text(
                          j.nivel.label,
                          style: TextStyle(
                              color: cor.withValues(alpha: 0.6),
                              fontSize: 11),
                        ),
                      ],
                    ),
                  );
              }),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  /// Resumo de níveis do time, ex: "2 Avançado · 1 Intermediário"
  String _resumoNivel(List<Jogador> jogadores) {
    final contagem = <Nivel, int>{};
    for (final j in jogadores) {
      contagem[j.nivel] = (contagem[j.nivel] ?? 0) + 1;
    }
    return [Nivel.avancado, Nivel.intermediario, Nivel.iniciante]
        .where((n) => contagem.containsKey(n))
        .map((n) => '${contagem[n]} ${n.label}')
        .join(' · ');
  }

  Widget _buildVitoriasBadge(int v) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.military_tech_rounded,
              color: Color(0xFFFFD700), size: 11),
          const SizedBox(width: 2),
          Text('$v/2',
              style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
        ],
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

  // ── Próxima partida recomendada ───────────────────────────────────────────
  Widget _buildProximaPartida(
    BuildContext context,
    List<Time> times,
    Map<int, Jogador> jogMap,
    int sessaoId,
  ) {
    final rec = _recomendarProxima(times, jogMap);
    if (rec == null) return const SizedBox.shrink();

    final tA = rec.$1;
    final tB = rec.$2;
    final corA = _corTime(tA.ordem);
    final corB = _corTime(tB.ordem);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.recommend_rounded,
                      color: Color(0xFF4CAF50), size: 15),
                  SizedBox(width: 6),
                  Text('Próxima Partida Recomendada',
                      style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Time A
                  Expanded(
                    child: Row(children: [
                      Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: corA)),
                      const SizedBox(width: 6),
                      Text(tA.nome,
                          style: TextStyle(
                              color: corA,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      if (tA.vitorias > 0) ...[
                        const SizedBox(width: 6),
                        _buildVitoriasBadge(tA.vitorias),
                      ],
                    ]),
                  ),
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
                          if (tB.vitorias > 0) ...[
                            _buildVitoriasBadge(tB.vitorias),
                            const SizedBox(width: 6),
                          ],
                          Text(tB.nome,
                              style: TextStyle(
                                  color: corB,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                          const SizedBox(width: 6),
                          Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: corB)),
                        ]),
                  ),
                  const SizedBox(width: 12),
                  // Botão iniciar
                  GestureDetector(
                    onTap: () => _iniciarPartida(context, sessaoId, tA, tB),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFF4CAF50)
                                .withValues(alpha: 0.5)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                    Text(
                        '${escala.length} jogo${escala.length != 1 ? 's' : ''}',
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
              SizedBox(
                width: 24,
                child: Text('#$num',
                    style: const TextStyle(
                        color: Colors.white30, fontSize: 12)),
              ),
              const SizedBox(width: 8),
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('vs',
                    style: TextStyle(
                        color: Colors.white30, fontSize: 12)),
              ),
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
              GestureDetector(
                onTap: () => _iniciarPartida(context, sessaoId, tA, tB),
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
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
    Sessao sessao,
  ) {
    final nTimes = checkins.length ~/ porTime;
    final pode = nTimes >= 2;
    final label = sessao.prefixoTime.toLowerCase();

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
              'São necessários pelo menos ${porTime * 2} jogadores ($porTime por $label) para sortear 2 ${label}s.',
              style: const TextStyle(
                  color: Colors.white38, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              '${checkins.length} jogadores → $nTimes ${label}s de $porTime',
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
            icon: const Icon(Icons.shuffle_rounded, size: 22),
            label: const Text('Sortear Times',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            onPressed: pode
                ? () => _sortearESalvar(context, checkins, porTime, sessao)
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
    Sessao sessao,
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
      onPressed: () =>
          _confirmarResortear(context, checkins, porTime, sessao),
    );
  }

  void _confirmarResortear(BuildContext context, List<Jogador> checkins,
      int porTime, Sessao sessao) {
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
              await _sortearESalvar(context, checkins, porTime, sessao);
            },
            child: const Text('Re-sortear'),
          ),
        ],
      ),
    );
  }

  // ── Dialog de substituição por time ──────────────────────────────────────
  void _dialogSubstituir(
    BuildContext context,
    Time time,
    List<Jogador> jogadoresDoTime,
    List<Jogador> bancal,
    int sessaoId,
  ) {
    // Se banco vazio, usa todos os jogadores cadastrados fora deste time (empréstimo)
    final jogMap = jogadoresMapSignal.value;
    final emprestimo = jogMap.values
        .where((j) => !time.jogadorIds.contains(j.id))
        .toList()
      ..sort((a, b) => a.partidasJogadas.compareTo(b.partidasJogadas));
    final candidatos = bancal.isNotEmpty ? bancal : emprestimo;
    final isEmprestimo = bancal.isEmpty;

    Jogador? ausente;
    Jogador? substituto;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final sugestoes = ausente == null
              ? candidatos
              : ([...candidatos]
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
                    Text(
                      isEmprestimo
                          ? 'Quem entra? (empréstimo — todos os jogadores)'
                          : 'Quem entra? (prioridade: menos partidas jogadas)',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    ...sugestoes.map((j) {
                      final mesmoNivel = j.nivel == ausente!.nivel;
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
                                      color: j.partidasJogadas ==
                                              minPartidas
                                          ? const Color(0xFF4CAF50)
                                          : Colors.white54,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  j.nivel.label,
                                  style: TextStyle(
                                    color: mesmoNivel
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

  // ── Helper: iniciar partida com proteção contra duplicatas ───────────────
  Future<void> _iniciarPartida(
    BuildContext context,
    int sessaoId,
    Time tA,
    Time tB,
  ) async {
    final emAndamento = partidaAtualSignal.value.value;
    if (emAndamento != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Já há uma partida em andamento: ${emAndamento.timeANome} vs ${emAndamento.timeBNome}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    final porTime = _porTimeSignal.value;
    final times = timesSignal.value.value ?? [];
    final jogMap = jogadoresMapSignal.value;

    final emprestadosA = _calcularEmprestados(
      time: tA,
      porTime: porTime,
      todosTimes: times,
      jogMap: jogMap,
      oponente: tB,
    );

    final emprestadosB = _calcularEmprestados(
      time: tB,
      porTime: porTime,
      todosTimes: times,
      jogMap: jogMap,
      oponente: tA,
    );

    final idsA = [...tA.jogadorIds, ...emprestadosA.map((j) => j.id)];
    final idsB = [...tB.jogadorIds, ...emprestadosB.map((j) => j.id)];

    await db.criarPartida(
      sessaoId: sessaoId,
      timeAIds: idsA,
      timeBIds: idsB,
      timeANome: tA.nome,
      timeBNome: tB.nome,
    );
    tabIndexSignal.value = 3;
  }

  // ── Helper: sortear e avisar se times ficaram sem mulher ─────────────────
  Future<void> _sortearESalvar(
    BuildContext context,
    List<Jogador> checkins,
    int porTime,
    Sessao sessao,
  ) async {
    final novosTimes = _sortearTimes(checkins, porTime,
        modalidade: sessao.modalidade);
    await db.salvarTimes(
      sessao.id,
      novosTimes.map((t) => t.where((j) => !j.isEmprestado).map((j) => j.id).toList()).toList(),
      nomePrefix: sessao.prefixoTime,
    );
    // Aviso de times sem mulher só faz sentido no vôlei de quadra
    if (sessao.modalidade == Modalidade.quadra) {
      final semMulher = novosTimes
          .where((t) => !t.any((j) => j.genero == Genero.feminino))
          .length;
      if (semMulher > 0 && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '$semMulher time${semMulher > 1 ? 's' : ''} sem mulher — jogadoras insuficientes para cobrir todos'),
            backgroundColor: const Color(0xFFFF9800),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }


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

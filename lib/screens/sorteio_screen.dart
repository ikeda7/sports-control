import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../db.dart';
import '../design/design.dart';
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

  // 1. Levantadores: menos jogos têm prioridade (Apenas Quadra)
  if (modalidade == Modalidade.quadra) {
    final levs = presentes.where((j) => j.isLevantador).toList()
      ..sort((a, b) => a.partidasJogadas.compareTo(b.partidasJogadas));
    for (var i = 0; i < n && i < levs.length; i++) {
      timesFixos[i].add(levs[i]);
      alocados.add(levs[i].id);
    }
  }

  // 2. Mulheres: Teto e Distribuição Equitativa (Ambas modalidades)
  final mulheres = presentes
      .where((j) => !alocados.contains(j.id) && j.genero == Genero.feminino)
      .toList()
    ..shuffle(rng)
    ..sort((a, b) => b.pesoTecnico.compareTo(a.pesoTecnico));

  // O teto cede se a quantidade for muito alta para não deixar ninguém de fora na 1a rodada
  final int maxMulheresPorTime = max(2, (mulheres.length / n).ceil());

  final slotsMulheres = List.generate(n, (i) => maxMulheresPorTime);
  final fillOrderMulheres = <int>[];
  var fwdMulheres = true;
  while (fillOrderMulheres.length < mulheres.length) {
    final seq = fwdMulheres
        ? List.generate(n, (i) => i)
        : List.generate(n, (i) => n - 1 - i);
    fwdMulheres = !fwdMulheres;
    var addedAny = false;
    for (final ti in seq) {
      if (slotsMulheres[ti] > 0 && fillOrderMulheres.length < mulheres.length && timesFixos[ti].length < capacidade[ti]) {
        fillOrderMulheres.add(ti);
        slotsMulheres[ti]--;
        addedAny = true;
      }
    }
    if (!addedAny) break;
  }

  for (var i = 0; i < mulheres.length && i < fillOrderMulheres.length; i++) {
    timesFixos[fillOrderMulheres[i]].add(mulheres[i]);
    alocados.add(mulheres[i].id);
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
    alocados.add(restantes[i].id);
  }

  // 4. Criação Dinâmica Das Vagas Completas
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
  Set<int>? jaEmprestados,
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
      .where((j) => jaEmprestados == null || !jaEmprestados.contains(j.id))
      .toList();

  // Prioriza jogadores com menos partidas jogadas para rodar o banco imaginário de forma justa
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
bool _isAtualizandoTimes = false;

class SorteioScreen extends StatelessWidget {
  const SorteioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Gradiente e largura de conteúdo vêm do shell (MainScreen).
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Watch((ctx) => _buildConteudo(ctx)),
      ),
    );
  }

  Widget _buildConteudo(BuildContext context) {
    final sessao = sessaoAtualSignal.value.value;
    final checkins = checkinsSignal.value.value ?? [];
    final times = timesSignal.value.value ?? [];
    final jogMap = jogadoresMapSignal.value;

    // O cabeçalho fica sempre visível, inclusive nos estados vazios: sem ele a
    // tela perde o título e o usuário não sabe em que aba está — só via um
    // ícone solto no meio do nada.
    if (sessao == null) {
      return _semConteudo(
        titulo: 'Sorteio',
        vazio: _buildMsg(
          Icons.play_circle_outline_rounded,
          'Nenhum rachão ativo',
          'Inicie o rachão na aba Check-in',
        ),
      );
    }

    // Para areia o porTime é fixo na sessão; para quadra o usuário pode ajustar.
    final isAreia = sessao.modalidade == Modalidade.areia;
    final porTime =
        isAreia ? sessao.porTime : _porTimeSignal.value;

    if (checkins.isEmpty) {
      return _semConteudo(
        titulo: 'Sorteio',
        vazio: _buildMsg(
          Icons.how_to_reg_outlined,
          'Ninguém fez check-in',
          'Confirme a presença dos jogadores na aba Check-in',
        ),
      );
    }

    final timesIds = times.expand((t) => t.jogadorIds).toSet();
    final checkinsIds = checkins.map((j) => j.id).toSet();
    
    final bancal = checkins.where((j) => !timesIds.contains(j.id)).toList();
    final fugioes = timesIds.difference(checkinsIds);

    // ─── Atualização Automática de Vagas ─────────────────────────────────
    if (times.isNotEmpty && (bancal.isNotEmpty || fugioes.isNotEmpty) && !_isAtualizandoTimes) {
      final timesIncompletos = times.where((t) => t.jogadorIds.length < porTime).toList();
      if (fugioes.isNotEmpty || timesIncompletos.isNotEmpty) {
        _isAtualizandoTimes = true;
        Future.microtask(() async {
          await _atualizarTimesAutomaticamente(bancal, fugioes, porTime, jogMap, onSwap: (msg) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(msg),
                  backgroundColor: const Color(0xFF4CAF50),
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          });
          _isAtualizandoTimes = false;
        });
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(checkins.length, porTime, sessao),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: SCSpace.x8,
              right: SCSpace.x8,
              // Folga para a barra de navegação de vidro não cobrir o botão de
              // re-sortear, que fica no fim da coluna.
              bottom: SCLayout.bottomNavClearance,
            ),
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

  Future<void> _atualizarTimesAutomaticamente(
    List<Jogador> atrasados,
    Set<int> fugioes,
    int porTime,
    Map<int, Jogador> jogMap, {
    void Function(String)? onSwap,
  }) async {
    try {
      List<Time> timesAtualizados = List.from(timesSignal.value.value ?? []);

      // 1. Remove quem saiu (fugiões)
      if (fugioes.isNotEmpty) {
        for (var i = 0; i < timesAtualizados.length; i++) {
          final t = timesAtualizados[i];
          final hasFugiao = t.jogadorIds.any((id) => fugioes.contains(id));
          if (hasFugiao) {
            final novosIds = t.jogadorIds.where((id) => !fugioes.contains(id)).toList();
            timesAtualizados[i] = t.copyWith(jogadorIds: novosIds);
            await db.atualizarTimeJogadores(t.id, novosIds);
          }
        }
      }

      // 2. Aloca quem chegou atrasado (bancal)
      for (final atrasado in atrasados) {
        var timesIncompletos = timesAtualizados.where((t) => t.jogadorIds.length < porTime).toList();
        
        bool fezTroca = false;

        // Prioridade Levantador
        if (atrasado.isLevantador) {
          Time? timeDestino = timesIncompletos.where((t) => !t.jogadorIds.any((id) => jogMap[id]?.isLevantador == true)).firstOrNull;

          if (timeDestino == null) {
            final timesCompletos = timesAtualizados.where((t) => t.jogadorIds.length >= porTime).toList();
            final timeCompletoSemLev = timesCompletos.where((t) => !t.jogadorIds.any((id) => jogMap[id]?.isLevantador == true)).firstOrNull;

            if (timeCompletoSemLev != null) {
              final idPraSair = timeCompletoSemLev.jogadorIds.last;
              final nomeSaindo = jogMap[idPraSair]?.nome ?? 'Jogador';
              final novosIdsCompleto = timeCompletoSemLev.jogadorIds.where((id) => id != idPraSair).toList()..add(atrasado.id);
              final idxComp = timesAtualizados.indexWhere((t) => t.id == timeCompletoSemLev.id);
              timesAtualizados[idxComp] = timeCompletoSemLev.copyWith(jogadorIds: novosIdsCompleto);
              await db.atualizarTimeJogadores(timeCompletoSemLev.id, novosIdsCompleto);
              onSwap?.call('🔄 ${atrasado.nome} (Lev) entrou no lugar de $nomeSaindo no ${timeCompletoSemLev.nome}');

              if (timesIncompletos.isNotEmpty) {
                timesIncompletos.sort((a, b) => a.jogadorIds.length.compareTo(b.jogadorIds.length));
                final timeDestinoInc = timesIncompletos.first;
                final novosIdsInc = [...timeDestinoInc.jogadorIds, idPraSair];
                final idxInc = timesAtualizados.indexWhere((t) => t.id == timeDestinoInc.id);
                timesAtualizados[idxInc] = timeDestinoInc.copyWith(jogadorIds: novosIdsInc);
                await db.atualizarTimeJogadores(timeDestinoInc.id, novosIdsInc);
              }
              fezTroca = true;
            }
          } else {
            final novosIds = [...timeDestino.jogadorIds, atrasado.id];
            final idx = timesAtualizados.indexWhere((t) => t.id == timeDestino.id);
            timesAtualizados[idx] = timeDestino.copyWith(jogadorIds: novosIds);
            await db.atualizarTimeJogadores(timeDestino.id, novosIds);
            fezTroca = true;
          }
        }

        if (fezTroca) continue;

        // Regra de Mulheres
        if (atrasado.genero == Genero.feminino) {
          timesIncompletos.sort((a, b) => a.jogadorIds.length.compareTo(b.jogadorIds.length));
          Time? timeDestino = timesIncompletos.where((t) {
            return t.jogadorIds.where((id) => jogMap[id]?.genero == Genero.feminino).length < 2;
          }).firstOrNull;

          if (timeDestino != null) {
            final novosIds = [...timeDestino.jogadorIds, atrasado.id];
            final idx = timesAtualizados.indexWhere((t) => t.id == timeDestino.id);
            timesAtualizados[idx] = timeDestino.copyWith(jogadorIds: novosIds);
            await db.atualizarTimeJogadores(timeDestino.id, novosIds);
            continue;
          }

          // Troca por um homem num time que tenha menos de 2 mulheres
          final timesMenos2Mulheres = timesAtualizados.where((t) {
            return t.jogadorIds.where((id) => jogMap[id]?.genero == Genero.feminino).length < 2;
          }).toList();

          if (timesMenos2Mulheres.isNotEmpty) {
            final tDest = timesMenos2Mulheres.first;
            final homens = tDest.jogadorIds.where((id) => jogMap[id]?.genero != Genero.feminino).toList();
            if (homens.isNotEmpty) {
              homens.sort((a, b) {
                final jA = jogMap[a]!;
                final jB = jogMap[b]!;
                if (jA.isLevantador && !jB.isLevantador) return 1;
                if (!jA.isLevantador && jB.isLevantador) return -1;
                return jB.partidasJogadas.compareTo(jA.partidasJogadas);
              });
              final idPraSair = homens.first;
              final nomeSaindo = jogMap[idPraSair]?.nome ?? 'Jogador';
              final novosIds = tDest.jogadorIds.where((id) => id != idPraSair).toList()..add(atrasado.id);
              final idx = timesAtualizados.indexWhere((t) => t.id == tDest.id);
              timesAtualizados[idx] = tDest.copyWith(jogadorIds: novosIds);
              await db.atualizarTimeJogadores(tDest.id, novosIds);
              onSwap?.call('🔄 Ajuste: $nomeSaindo cedeu vaga p/ ${atrasado.nome} no ${tDest.nome} (Regra Mulheres)');
              continue;
            }
          }

          // Rodízio de mulheres
          Jogador? mulherParaSair;
          Time? timeDaMulher;
          int maxPartidas = -1;

          for (final t in timesAtualizados) {
            for (final id in t.jogadorIds) {
              final j = jogMap[id];
              if (j != null && j.genero == Genero.feminino) {
                if (j.partidasJogadas > atrasado.partidasJogadas && j.partidasJogadas > maxPartidas) {
                  maxPartidas = j.partidasJogadas;
                  mulherParaSair = j;
                  timeDaMulher = t;
                }
              }
            }
          }

          if (mulherParaSair != null && timeDaMulher != null) {
            final novosIds = timeDaMulher.jogadorIds.where((id) => id != mulherParaSair!.id).toList()..add(atrasado.id);
            final idx = timesAtualizados.indexWhere((t) => t.id == timeDaMulher!.id);
            timesAtualizados[idx] = timeDaMulher.copyWith(jogadorIds: novosIds);
            await db.atualizarTimeJogadores(timeDaMulher.id, novosIds);
            onSwap?.call('🔄 Rodízio: ${atrasado.nome} entrou no lugar de ${mulherParaSair.nome} no ${timeDaMulher.nome}');
            continue;
          }

          continue;
        }

        // Se for homem não levantador
        if (timesIncompletos.isEmpty) break; // Não há mais vagas
        timesIncompletos.sort((a, b) => a.jogadorIds.length.compareTo(b.jogadorIds.length));
        final timeDestino = timesIncompletos.first;
        final novosIds = [...timeDestino.jogadorIds, atrasado.id];
        final idx = timesAtualizados.indexWhere((t) => t.id == timeDestino.id);
        timesAtualizados[idx] = timeDestino.copyWith(jogadorIds: novosIds);
        await db.atualizarTimeJogadores(timeDestino.id, novosIds);
      }
    } finally {
      _isAtualizandoTimes = false;
    }
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(int presentes, int porTime, Sessao sessao) {
    final isAreia = sessao.modalidade == Modalidade.areia;
    return Padding(
      padding: const EdgeInsets.only(
        left: SCSpace.x8,
        right: SCSpace.x8,
        top: SCSpace.x10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SCScreenHeader(
            title: 'Sorteio',
            status: '$presentes no check-in',
            // Na areia o tamanho do time é fixo na sessão, então em vez do
            // controle mostra só a modalidade.
            trailing: isAreia
                ? SCBadge(
                    label: '🏖️ ${sessao.prefixoTime}s',
                    color: SCColors.setter,
                  )
                : null,
          ),
          if (!isAreia) ...[
            _buildPorTimeControl(porTime),
            const SizedBox(height: SCSpace.x3),
          ],
        ],
      ),
    );
  }

  Widget _buildPorTimeControl(int porTime) {
    return GlassCard(
      radius: SCRadius.lg,
      tint: Colors.white.withValues(alpha: 0.08),
      borderColor: SCColors.line3,
      padding: const EdgeInsets.symmetric(
        horizontal: SCSpace.x6,
        vertical: SCSpace.x4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Jogadores por time',
            style: TextStyle(
              color: SCColors.textTertiary,
              fontSize: SCType.fsBodySm,
            ),
          ),
          SCStepper(
            value: porTime,
            min: 2,
            max: 12,
            onChanged: (v) => _porTimeSignal.value = v,
          ),
        ],
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
    final Map<int, List<Jogador>> todosEmprestados = {};
    final Set<int> jaEmprestados = {};
    for (final time in times) {
      final emp = _calcularEmprestados(
        time: time,
        porTime: _porTimeSignal.value,
        todosTimes: times,
        jogMap: jogMap,
        jaEmprestados: jaEmprestados,
      );
      todosEmprestados[time.id] = emp;
      jaEmprestados.addAll(emp.map((j) => j.id));
    }

    if (times.length == 2) {
      return LayoutBuilder(builder: (ctx, constraints) {
        final isWide = constraints.maxWidth > 520;
        final cardA = _buildTimeCard(
            context, times[0], jogMap, bancal, sessaoId, todosEmprestados[times[0].id]!);
        final cardB = _buildTimeCard(
            context, times[1], jogMap, bancal, sessaoId, todosEmprestados[times[1].id]!);
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
              context, times[i], jogMap, bancal, sessaoId, todosEmprestados[times[i].id]!),
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
    List<Jogador> emprestados,
  ) {
    final cor = _corTime(time.ordem);
    final jogadoresOriginais = time.jogadorIds
        .map((id) => jogMap[id])
        .whereType<Jogador>()
        .toList();

    final todosJogadores = [...jogadoresOriginais, ...emprestados];

    return SCTeamCard(
      name: time.nome,
      color: cor,
      wins: time.vitorias,
      summary: _resumoNivel(todosJogadores),
      onSubstitute: () => _dialogSubstituir(
        context,
        time,
        jogadoresOriginais,
        bancal,
        sessaoId,
      ),
      players: [
        for (final j in todosJogadores)
          SCTeamPlayer(
            name: j.nome,
            level: j.nivel.label,
            isSetter: j.isLevantador,
            isFemale: j.genero == Genero.feminino,
            borrowed: emprestados.any((e) => e.id == j.id),
          ),
      ],
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
    // Mesmo cálculo do _sortearTimes: arredonda para CIMA. Antes aqui usava
    // `~/` (para baixo), então o preview mentia — com 22 presentes e 6 por time
    // dizia "3 times" e o sorteio produzia 4. Times incompletos são preenchidos
    // com emprestados pela Regra de Ocupação Total.
    final nTimes = (checkins.length / porTime).ceil();
    final pode = nTimes >= 2;
    final label = sessao.prefixoTime.toLowerCase();

    return Column(
      children: [
        const SizedBox(height: SCSpace.x12),
        Icon(
          Icons.shuffle_rounded,
          size: 64,
          color: Colors.white.withValues(alpha: 0.12),
        ),
        const SizedBox(height: SCSpace.x8),
        Padding(
          padding: const EdgeInsets.only(bottom: SCSpace.x8),
          child: Text(
            pode
                ? '${checkins.length} jogadores → $nTimes ${label}s de $porTime'
                : 'São necessários pelo menos ${porTime + 1} jogadores '
                    'para formar 2 ${label}s.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: pode ? SCColors.textTertiary : SCColors.textDisabled,
              fontSize: SCType.fsBodySm,
              height: 1.4,
            ),
          ),
        ),
        SCButton(
          label: 'Sortear times',
          icon: Icons.shuffle_rounded,
          size: SCButtonSize.lg,
          fullWidth: true,
          onPressed: pode
              ? () => _sortearESalvar(context, checkins, porTime, sessao)
              : null,
        ),
        const SizedBox(height: SCSpace.x12),
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
    return SCButton(
      label: 'Re-sortear',
      icon: Icons.refresh_rounded,
      variant: SCButtonVariant.outlined,
      fullWidth: true,
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
      jaEmprestados: emprestadosA.map((j) => j.id).toSet(),
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
    return SCEmptyState(icon: icon, title: titulo, subtitle: sub);
  }

  /// Tela em estado vazio, mas com o cabeçalho preservado.
  ///
  /// O `status` fica de fora por padrão: a mensagem já é dada pelo estado vazio
  /// no meio da tela, e repetir a mesma frase logo abaixo do título é ruído.
  Widget _semConteudo({
    required String titulo,
    String? status,
    required Widget vazio,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: SCSpace.x8,
            right: SCSpace.x8,
            top: SCSpace.x10,
          ),
          child: SCScreenHeader(title: titulo, status: status),
        ),
        // Expanded + Center dentro do SCEmptyState = conteúdo no meio do espaço
        // que sobra, em vez de colado embaixo do cabeçalho.
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: SCLayout.bottomNavClearance,
            ),
            child: vazio,
          ),
        ),
      ],
    );
  }
}

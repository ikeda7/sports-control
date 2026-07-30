import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../db.dart';
import '../models/jogador.dart';
import '../models/partida.dart';
import '../signals.dart';

const _corA = Color(0xFFFF6B35); // laranja — Time A
const _corB = Color(0xFF00BCD4); // ciano   — Time B

class PlacarScreen extends StatefulWidget {
  const PlacarScreen({super.key});

  @override
  State<PlacarScreen> createState() => _PlacarScreenState();
}

class _PlacarScreenState extends State<PlacarScreen> {
  bool _mostrarGlobal = false;
  DateTime? _dataFiltro;

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
    final partida = partidaAtualSignal.value.value;
    final historicoLocal = historicoSignal.value.value ?? [];
    final historicoGlobal = historicoGlobalSignal.value.value ?? [];
    final jogMap = jogadoresMapSignal.value;

    var historicoAtivo = _mostrarGlobal ? historicoGlobal : historicoLocal;
    if (_dataFiltro != null) {
      historicoAtivo = historicoAtivo.where((p) {
        final dataP = p.iniciadaEm;
        return dataP.year == _dataFiltro!.year && 
               dataP.month == _dataFiltro!.month && 
               dataP.day == _dataFiltro!.day;
      }).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(partida),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              children: [
                if (sessao == null)
                  _buildSemSessao()
                else if (partida != null)
                  _buildPlacarAtivo(context, partida, jogMap)
                else
                  _buildSemPartida(),
                  
                const SizedBox(height: 24),
                _buildHistorico(historicoAtivo, jogMap),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------
  Widget _buildHeader(Partida? partida) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Placar',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2)),
          Text(
            partida != null ? 'Partida em andamento' : 'Aguardando partida',
            style: TextStyle(
              color: partida != null
                  ? const Color(0xFF4CAF50)
                  : Colors.white38,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sem sessão
  // ---------------------------------------------------------------------------
  Widget _buildSemSessao() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.scoreboard_outlined,
              size: 64, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          const Text('Nenhum rachão ativo',
              style: TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Inicie o rachão na aba Check-in',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4), fontSize: 14)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sem partida ativa
  // ---------------------------------------------------------------------------
  Widget _buildSemPartida() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_volleyball_rounded,
                size: 52, color: Colors.white.withValues(alpha: 0.15)),
            const SizedBox(height: 16),
            const Text('Nenhuma partida em andamento',
                style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 8),
            Text('Sorteie os times e toque em "Iniciar Partida"',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Placar ativo — o coração da tela
  // ---------------------------------------------------------------------------
  Widget _buildPlacarAtivo(
    BuildContext context,
    Partida partida,
    Map<int, Jogador> jogMap,
  ) {
    final timeA = partida.timeAIds
        .map((id) => jogMap[id])
        .whereType<Jogador>()
        .toList();
    final timeB = partida.timeBIds
        .map((id) => jogMap[id])
        .whereType<Jogador>()
        .toList();

    final timesOriginais = timesSignal.value.value ?? [];
    final timeOrigA = timesOriginais.where((t) => t.nome == partida.timeANome).firstOrNull;
    final timeOrigB = timesOriginais.where((t) => t.nome == partida.timeBNome).firstOrNull;

    final emprestadosA = timeOrigA == null ? <String>[] : partida.timeAIds
        .where((id) => !timeOrigA.jogadorIds.contains(id))
        .map((id) => jogMap[id]?.nome ?? '')
        .where((n) => n.isNotEmpty)
        .toList();

    final emprestadosB = timeOrigB == null ? <String>[] : partida.timeBIds
        .where((id) => !timeOrigB.jogadorIds.contains(id))
        .map((id) => jogMap[id]?.nome ?? '')
        .where((n) => n.isNotEmpty)
        .toList();

    Widget? warningWidget;
    if (emprestadosA.isNotEmpty || emprestadosB.isNotEmpty) {
      warningWidget = Container(
        margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFF9800).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFF9800).withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.swap_horizontal_circle_outlined, color: Color(0xFFFF9800)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jogadores Emprestados',
                    style: TextStyle(color: Color(0xFFFF9800), fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  if (emprestadosA.isNotEmpty)
                    Text(
                      '${partida.timeANome}: ${emprestadosA.join(', ')}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  if (emprestadosB.isNotEmpty)
                    Text(
                      '${partida.timeBNome}: ${emprestadosB.join(', ')}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        ?warningWidget,
        // ── PLACAR PRINCIPAL ──────────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Column(
                children: [
                  // Cabeçalho times
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(partida.timeANome,
                              style: const TextStyle(
                                  color: _corA,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                        const SizedBox(
                          width: 60,
                          child: Center(
                            child: Text('vs',
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 14)),
                          ),
                        ),
                        Expanded(
                          child: Text(partida.timeBNome,
                              style: const TextStyle(
                                  color: _corB,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ),

                  // PLACARES GRANDES + botões +/-
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildPlacarTime(
                              partida.placarA, partida.id, true, _corA),
                        ),
                        Container(
                          width: 1,
                          height: 80,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        Expanded(
                          child: _buildPlacarTime(
                              partida.placarB, partida.id, false, _corB),
                        ),
                      ],
                    ),
                  ),

                  // Listas de jogadores dos times
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildListaJogadores(timeA, _corA)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildListaJogadores(timeB, _corB)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ── BOTÃO ENCERRAR ────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade300,
              side: BorderSide(color: Colors.red.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.stop_circle_outlined),
            label: const Text('Encerrar Partida',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            onPressed: () => _confirmarEncerramento(context, partida),
          ),
        ),
      ],
    );
  }

  Widget _buildPlacarTime(
      int placar, int partidaId, bool isTimeA, Color cor) {
    return Column(
      children: [
        // Número gigante do placar
        Text(
          '$placar',
          style: TextStyle(
            color: cor,
            fontSize: 72,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        const SizedBox(height: 12),
        // Botões +/-
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildScoreBtn(
              icon: Icons.remove_rounded,
              color: Colors.white38,
              onTap: () => db.decrementarPlacar(partidaId, isTimeA: isTimeA),
            ),
            const SizedBox(width: 16),
            _buildScoreBtn(
              icon: Icons.add_rounded,
              color: cor,
              onTap: () => db.incrementarPlacar(partidaId, isTimeA: isTimeA),
              large: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool large = false,
  }) {
    final size = large ? 44.0 : 32.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.15),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Icon(icon, color: color, size: large ? 24 : 18),
      ),
    );
  }

  Widget _buildListaJogadores(List<Jogador> jogadores, Color cor) {
    return Column(
      children: jogadores
          .map(
            (j) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cor.withValues(alpha: 0.15),
                      border: Border.all(
                          color: cor.withValues(alpha: 0.5), width: 1),
                    ),
                    child: Center(
                      child: Text(
                        j.nome[0].toUpperCase(),
                        style: TextStyle(
                            color: cor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      j.nome,
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Histórico de partidas encerradas
  // ---------------------------------------------------------------------------
  Widget _buildHistorico(
      List<Partida> historico, Map<int, Jogador> jogMap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Histórico',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5)),
            Row(
              children: [
                if (_dataFiltro != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      label: Text('${_dataFiltro!.day.toString().padLeft(2, '0')}/${_dataFiltro!.month.toString().padLeft(2, '0')}'),
                      onPressed: () => setState(() => _dataFiltro = null),
                      avatar: const Icon(Icons.close, size: 16),
                      backgroundColor: const Color(0xFFFF9800).withValues(alpha: 0.2),
                      side: BorderSide.none,
                      labelStyle: const TextStyle(color: Color(0xFFFF9800)),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white70),
                  onPressed: () => _confirmarLimpezaHistorico(context),
                ),
                IconButton(
                  icon: const Icon(Icons.date_range, color: Colors.white70),
                  onPressed: () async {
                    final data = await showDatePicker(
                      context: context,
                      initialDate: _dataFiltro ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Color(0xFFFF9800),
                              onPrimary: Colors.white,
                              surface: Color(0xFF0D1F3C),
                              onSurface: Colors.white,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (data != null) {
                      setState(() => _dataFiltro = data);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                label: Text('Sessão Atual'),
                icon: Icon(Icons.sports_volleyball),
              ),
              ButtonSegment(
                value: true,
                label: Text('Global'),
                icon: Icon(Icons.public),
              ),
            ],
            selected: {_mostrarGlobal},
            onSelectionChanged: (set) {
              setState(() => _mostrarGlobal = set.first);
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFFFF9800).withValues(alpha: 0.2);
                }
                return Colors.transparent;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFFFF9800);
                }
                return Colors.white70;
              }),
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (historico.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text('Nenhuma partida encontrada.',
                  style: TextStyle(color: Colors.white54, fontSize: 14)),
            ),
          )
        else
          ...historico.asMap().entries.map((e) {
            final i = historico.length - e.key;
            return _buildItemHistorico(i, e.value, jogMap);
          }),
      ],
    );
  }

  Widget _buildItemHistorico(
      int num, Partida partida, Map<int, Jogador> jogMap) {
    final venceuA = partida.placarA > partida.placarB;
    final venceuB = partida.placarB > partida.placarA;

    final data = partida.iniciadaEm;
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final hora = data.hour.toString().padLeft(2, '0');
    final min = data.minute.toString().padLeft(2, '0');
    final dataFormatada = '$dia/$mes $hora:$min';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Text('#$num • $dataFormatada',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12)),
                const SizedBox(width: 12),
                // Time A
                Expanded(
                  child: Text(
                    partida.timeANome,
                    style: TextStyle(
                      color: venceuA ? _corA : Colors.white54,
                      fontSize: 12,
                      fontWeight: venceuA
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Placar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${partida.placarA}',
                          style: TextStyle(
                            color: venceuA ? _corA : Colors.white54,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(
                          text: ' × ',
                          style: TextStyle(
                              color: Colors.white38, fontSize: 14),
                        ),
                        TextSpan(
                          text: '${partida.placarB}',
                          style: TextStyle(
                            color: venceuB ? _corB : Colors.white54,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Time B
                Expanded(
                  child: Text(
                    partida.timeBNome,
                    style: TextStyle(
                      color: venceuB ? _corB : Colors.white54,
                      fontSize: 12,
                      fontWeight: venceuB
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Confirmar encerramento da partida
  // ---------------------------------------------------------------------------
  void _confirmarEncerramento(BuildContext context, Partida partida) {
    // Vôlei não tem empate — impede encerrar com placar igual
    if (partida.placarA == partida.placarB) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF0D1F3C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
                color: const Color(0xFFFF9800).withValues(alpha: 0.4)),
          ),
          title: const Text('Placar empatado',
              style: TextStyle(color: Colors.white)),
          content: Text(
            'Vôlei não tem empate!\n\n'
            'Placar atual: ${partida.timeANome} ${partida.placarA} × ${partida.placarB} ${partida.timeBNome}\n\n'
            'Continue jogando até um time vencer.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800)),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Continuar jogando'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1F3C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text('Encerrar partida?',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Placar final: ${partida.timeANome} ${partida.placarA} × ${partida.placarB} ${partida.timeBNome}\n\n'
          'As partidas jogadas de todos os participantes serão incrementadas.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white38)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50)),
            onPressed: () async {
              await db.encerrarPartida(partida.id);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Encerrar'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Confirmar limpeza do histórico
  // ---------------------------------------------------------------------------
  void _confirmarLimpezaHistorico(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1F3C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text('Apagar Histórico',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Deseja apagar o histórico?\n\n'
          'Você pode apagar apenas o histórico da sessão atual, ou o histórico global (todas as sessões). Esta ação não pode ser desfeita.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final sessao = sessaoAtualSignal.value.value;
              if (sessao != null) {
                await db.apagarHistoricoSessao(sessao.id);
              }
            },
            child: const Text('Sessão Atual',
                style: TextStyle(color: Color(0xFFFF9800))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await db.apagarHistoricoGlobal();
            },
            child: const Text('Global',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

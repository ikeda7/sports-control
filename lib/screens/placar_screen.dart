import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../db.dart';
import '../design/design.dart';
import '../models/jogador.dart';
import '../models/partida.dart';
import '../signals.dart';

// Cores de time 1 e 2 do design system. Referência direta às constantes porque
// indexar uma lista const não é expressão constante em Dart.
const _corA = SCColors.orange; // Time A
const _corB = SCColors.cyan; // Time B

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
            padding: const EdgeInsets.only(
              left: SCSpace.x8,
              right: SCSpace.x8,
              // Folga para a barra de navegação de vidro não cobrir o último
              // item do histórico.
              bottom: SCLayout.bottomNavClearance,
            ),
            child: Column(
              children: [
                if (sessao == null)
                  _buildSemSessao()
                else if (partida != null)
                  _buildPlacarAtivo(context, partida, jogMap)
                else
                  _buildSemPartida(),

                const SizedBox(height: SCSpace.x10),
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
    final emJogo = partida != null;
    return Padding(
      padding: const EdgeInsets.only(
        left: SCSpace.x8,
        right: SCSpace.x8,
        top: SCSpace.x9,
      ),
      child: SCScreenHeader(
        title: 'Placar',
        status: emJogo ? 'Partida em andamento' : 'Aguardando partida',
        // Verde quando há jogo rolando: é o estado que o organizador confere de
        // relance no meio da quadra.
        statusColor: emJogo ? SCColors.success : SCColors.textDisabled,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sem sessão
  // ---------------------------------------------------------------------------
  Widget _buildSemSessao() {
    return const SCEmptyState(
      icon: Icons.scoreboard_outlined,
      title: 'Nenhum rachão ativo',
      subtitle: 'Inicie o rachão na aba Check-in',
    );
  }

  // ---------------------------------------------------------------------------
  // Sem partida ativa
  // ---------------------------------------------------------------------------
  Widget _buildSemPartida() {
    return const SCEmptyState(
      icon: Icons.sports_volleyball_rounded,
      iconSize: 52,
      title: 'Nenhuma partida em andamento',
      subtitle: 'Sorteie os times e toque em "Iniciar" na aba Sorteio',
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

    // Aviso de empréstimo: âmbar é a cor de "substituição" no design system.
    Widget? warningWidget;
    if (emprestadosA.isNotEmpty || emprestadosB.isNotEmpty) {
      warningWidget = GlassCard(
        tint: SCColors.tintStrong(SCColors.warning),
        borderColor: SCColors.border(SCColors.warning),
        radius: SCRadius.lg,
        margin: const EdgeInsets.only(bottom: SCSpace.x8),
        padding: const EdgeInsets.symmetric(
          horizontal: SCSpace.x8,
          vertical: SCSpace.x6,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.swap_horizontal_circle_outlined,
              color: SCColors.warning,
            ),
            const SizedBox(width: SCSpace.x6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jogadores emprestados',
                    style: TextStyle(
                      color: SCColors.warning,
                      fontWeight: FontWeight.w700,
                      fontSize: SCType.fsBody,
                    ),
                  ),
                  const SizedBox(height: SCSpace.x2),
                  if (emprestadosA.isNotEmpty)
                    Text(
                      '${partida.timeANome}: ${emprestadosA.join(', ')}',
                      style: TextStyle(
                        color: SCColors.textSecondary,
                        fontSize: SCType.fsBodySm,
                      ),
                    ),
                  if (emprestadosB.isNotEmpty)
                    Text(
                      '${partida.timeBNome}: ${emprestadosB.join(', ')}',
                      style: TextStyle(
                        color: SCColors.textSecondary,
                        fontSize: SCType.fsBodySm,
                      ),
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
        GlassCard(
          radius: SCRadius.xxl,
          blur: SCFx.blurLg,
          tint: Colors.white.withValues(alpha: 0.06),
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // Cabeçalho times
              Padding(
                padding: const EdgeInsets.only(
                  left: SCSpace.x9,
                  right: SCSpace.x9,
                  top: SCSpace.x8,
                  bottom: SCSpace.x4,
                ),
                child: Row(
                  children: [
                    Expanded(child: _nomeTime(partida.timeANome, _corA)),
                    SizedBox(
                      width: 50,
                      child: Center(
                        child: Text(
                          'vs',
                          style: TextStyle(
                            color: SCColors.textFaint,
                            fontSize: SCType.fsBody,
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: _nomeTime(partida.timeBNome, _corB)),
                  ],
                ),
              ),

              // PLACARES GRANDES + botões +/-
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SCSpace.x9,
                  vertical: SCSpace.x4,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SCScoreCounter(
                        score: partida.placarA,
                        color: _corA,
                        onIncrement: () =>
                            db.incrementarPlacar(partida.id, isTimeA: true),
                        onDecrement: () =>
                            db.decrementarPlacar(partida.id, isTimeA: true),
                      ),
                    ),
                    Container(width: 1, height: 80, color: SCColors.line1),
                    Expanded(
                      child: SCScoreCounter(
                        score: partida.placarB,
                        color: _corB,
                        onIncrement: () =>
                            db.incrementarPlacar(partida.id, isTimeA: false),
                        onDecrement: () =>
                            db.decrementarPlacar(partida.id, isTimeA: false),
                      ),
                    ),
                  ],
                ),
              ),

              // Listas de jogadores dos times
              Padding(
                padding: const EdgeInsets.only(
                  left: SCSpace.x8,
                  right: SCSpace.x8,
                  top: SCSpace.x4,
                  bottom: SCSpace.x8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildListaJogadores(timeA, _corA)),
                    const SizedBox(width: SCSpace.x6),
                    Expanded(child: _buildListaJogadores(timeB, _corB)),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: SCSpace.x8),

        // ── BOTÃO ENCERRAR ────────────────────────────────────────────────
        SCButton(
          label: 'Encerrar partida',
          icon: Icons.stop_circle_outlined,
          variant: SCButtonVariant.outlined,
          color: SCColors.danger,
          fullWidth: true,
          onPressed: () => _confirmarEncerramento(context, partida),
        ),
      ],
    );
  }

  Widget _nomeTime(String nome, Color cor) {
    return Text(
      nome,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: cor,
        fontSize: SCType.fsSubtitle,
        fontWeight: FontWeight.w700,
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
        const SizedBox(height: SCSpace.x8),
        // Escopo do histórico. Trocado de âmbar para laranja: no design system
        // âmbar significa aviso/substituição, e isto é só um seletor.
        SCSegmentedTabs<bool>(
          value: _mostrarGlobal,
          onChanged: (v) => setState(() => _mostrarGlobal = v),
          segments: const [
            SCSegment(
              value: false,
              label: 'Sessão atual',
              icon: Icons.sports_volleyball,
            ),
            SCSegment(value: true, label: 'Global', icon: Icons.public),
          ],
        ),
        const SizedBox(height: SCSpace.x10),
        if (historico.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: SCSpace.x11),
            child: Center(
              child: Text(
                _dataFiltro != null
                    ? 'Nenhuma partida nesta data.'
                    : 'Nenhuma partida encerrada ainda.',
                style: TextStyle(
                  color: SCColors.textTertiary,
                  fontSize: SCType.fsBodySm,
                ),
              ),
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

    // O time vencedor fica na cor dele e em bold; o perdedor fica apagado. É o
    // que permite ler o resultado de relance, sem procurar o número.
    return GlassCard(
      radius: SCRadius.lg,
      blur: SCFx.blurSm,
      tint: SCColors.surface1,
      borderColor: SCColors.line1,
      margin: const EdgeInsets.only(bottom: SCSpace.x4),
      padding: const EdgeInsets.symmetric(
        horizontal: SCSpace.x8,
        vertical: SCSpace.x5,
      ),
      child: Row(
        children: [
          Text(
            '#$num • $dataFormatada',
            style: TextStyle(
              color: SCColors.textFaint,
              fontSize: SCType.fsCaption,
            ),
          ),
          const SizedBox(width: SCSpace.x6),
          Expanded(child: _nomeHistorico(partida.timeANome, _corA, venceuA)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SCSpace.x6),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${partida.placarA}',
                    style: TextStyle(
                      color: venceuA ? _corA : SCColors.textTertiary,
                      fontSize: SCType.fsBodyLg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: ' × ',
                    style: TextStyle(
                      color: SCColors.textFaint,
                      fontSize: SCType.fsBody,
                    ),
                  ),
                  TextSpan(
                    text: '${partida.placarB}',
                    style: TextStyle(
                      color: venceuB ? _corB : SCColors.textTertiary,
                      fontSize: SCType.fsBodyLg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _nomeHistorico(
              partida.timeBNome,
              _corB,
              venceuB,
              alinharDireita: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _nomeHistorico(
    String nome,
    Color cor,
    bool venceu, {
    bool alinharDireita = false,
  }) {
    return Text(
      nome,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: alinharDireita ? TextAlign.right : TextAlign.left,
      style: TextStyle(
        color: venceu ? cor : SCColors.textTertiary,
        fontSize: SCType.fsCaption,
        fontWeight: venceu ? FontWeight.w700 : FontWeight.w400,
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

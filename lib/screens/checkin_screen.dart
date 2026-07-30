import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../db.dart';
import '../design/design.dart';
import '../models/jogador.dart';
import '../models/sessao.dart';
import '../signals.dart';

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

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

    // Cabeçalho sempre presente, inclusive sem sessão: sem ele a tela vira um
    // botão solto no meio do nada, sem título nem contexto.
    if (sessao == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(
              left: SCSpace.x8,
              right: SCSpace.x8,
              top: SCSpace.x10,
            ),
            // Sem status: a mensagem já vem do bloco central, e repetir a mesma
            // frase logo abaixo do título é ruído.
            child: SCScreenHeader(title: 'Check-in'),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: SCLayout.bottomNavClearance,
              ),
              child: _buildSemSessao(context),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, sessao),
        Expanded(child: _buildLista(context, sessao.id)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Estado: nenhum rachão iniciado
  // ---------------------------------------------------------------------------
  Widget _buildSemSessao(BuildContext context) {
    // Aqui a ação é primária de propósito: iniciar o rachão é a única coisa a
    // fazer nesta tela quando não há sessão. Por isso não usa o SCEmptyState,
    // cuja ação é secundária por definição.
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SCSpace.x10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sports_volleyball_rounded,
              size: 72,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            const SizedBox(height: SCSpace.x10),
            const Text('Nenhum rachão ativo', style: SCType.title),
            const SizedBox(height: SCSpace.x4),
            Text(
              'Todos os jogadores serão marcados como presentes automaticamente',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: SCColors.textDisabled,
                fontSize: SCType.fsBody,
                height: 1.4,
              ),
            ),
            const SizedBox(height: SCSpace.x11),
            SCButton(
              label: 'Iniciar rachão',
              icon: Icons.play_arrow_rounded,
              size: SCButtonSize.lg,
              onPressed: () => _dialogIniciarRachao(context),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header com data, botões todos/nenhum e botão de encerrar
  // ---------------------------------------------------------------------------
  Widget _buildHeader(BuildContext context, Sessao sessao) {
    final dataFmt = _fmtData(sessao.criadaEm);
    final sessaoId = sessao.id;
    return Padding(
      padding: const EdgeInsets.only(
        left: SCSpace.x8,
        right: SCSpace.x8,
        top: SCSpace.x10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Watch((ctx) {
            final presentes = todosComStatusSignal.value.value
                    ?.where((j) => j.checkedIn)
                    .length ??
                0;
            return SCScreenHeader(
              title: 'Check-in',
              status: '$dataFmt • $presentes '
                  '${presentes == 1 ? 'presente' : 'presentes'}',
              trailing: SCButton(
                label: 'Encerrar',
                icon: Icons.stop_circle_outlined,
                variant: SCButtonVariant.outlined,
                color: SCColors.danger,
                size: SCButtonSize.sm,
                onPressed: () => _confirmarEncerramento(context),
              ),
            );
          }),
          // Modalidade e ações rápidas na mesma fileira: são todos controles de
          // escopo da sessão, e juntos economizam uma linha de altura.
          Row(
            children: [
              _buildModalidadeBadge(sessao),
              const SizedBox(width: SCSpace.x5),
              SCChip(
                label: 'Todos',
                icon: Icons.check_circle_outline,
                color: SCColors.success,
                onTap: () => db.checkInTodos(sessaoId),
              ),
              const SizedBox(width: SCSpace.x4),
              SCChip(
                label: 'Nenhum',
                icon: Icons.cancel_outlined,
                onTap: () => db.checkOutTodos(sessaoId),
              ),
            ],
          ),
          const SizedBox(height: SCSpace.x3),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Lista de jogadores com toggle de check-in
  // ---------------------------------------------------------------------------
  Widget _buildLista(BuildContext context, int sessaoId) {
    return Watch((ctx) {
      final estado = todosComStatusSignal.value;
      if (estado.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      final lista = estado.value ?? [];
      if (lista.isEmpty) {
        return const SCEmptyState(
          icon: Icons.people_outline,
          title: 'Nenhum jogador cadastrado',
          subtitle: 'Cadastre os jogadores na aba Jogadores para poder fazer check-in.',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.only(
          left: SCSpace.x8,
          right: SCSpace.x8,
          top: SCSpace.x4,
          bottom: SCLayout.bottomNavClearance,
        ),
        itemCount: lista.length,
        itemBuilder: (ctx, i) => _buildItemJogador(lista[i], sessaoId),
      );
    });
  }

  Widget _buildItemJogador(JogadorComStatus jcs, int sessaoId) {
    final jogador = jcs.jogador;
    final presente = jcs.checkedIn;

    return SCPlayerRow(
      name: jogador.nome,
      genderColor:
          jogador.genero == Genero.feminino ? SCColors.female : SCColors.male,
      // O SCPlayerRow já traduz "marcado" em tint verde, borda 1.5px e selo de
      // check no avatar — a mesma linguagem de seleção do resto do app.
      selectable: true,
      checked: presente,
      onTap: () => db.toggleCheckIn(sessaoId, jogador.id),
      badges: [
        if (jogador.isLevantador) const SCRowBadge('LEV', color: SCColors.setter),
        SCRowBadge(jogador.nivel.label, color: _corNivel(jogador.nivel)),
        SCRowBadge(
          '${jogador.partidasJogadas} '
          '${jogador.partidasJogadas == 1 ? 'partida' : 'partidas'}',
          color: SCColors.grey,
        ),
      ],
      trailing: AnimatedContainer(
        duration: SCFx.durMed,
        curve: SCFx.ease,
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: presente
              ? SCColors.success
              : Colors.white.withValues(alpha: 0.08),
          border: Border.all(
            color: presente ? SCColors.success : SCColors.line3,
          ),
        ),
        child: Icon(
          presente ? Icons.check : Icons.add,
          color: presente ? Colors.white : SCColors.textDisabled,
          size: 18,
        ),
      ),
    );
  }

  /// Cor do badge de nível, igual à da tela de Jogadores.
  Color _corNivel(Nivel n) => switch (n) {
        Nivel.iniciante => SCColors.grey,
        Nivel.intermediario => SCColors.blue,
        Nivel.avancado => SCColors.green,
      };

  // ---------------------------------------------------------------------------
  // Badge de modalidade
  // ---------------------------------------------------------------------------
  Widget _buildModalidadeBadge(Sessao sessao) {
    final isAreia = sessao.modalidade == Modalidade.areia;
    final cor = isAreia ? const Color(0xFFFFD700) : const Color(0xFF00BCD4);
    final label = isAreia
        ? '🏖️ ${sessao.prefixoTime}s'
        : '🏐 Quadra';
    // O emoji aqui é um dos dois casos que o design system permite: 🏐 quadra e
    // 🏖️ areia, sempre dentro de um badge, nunca decorativo.
    return SCBadge(label: label, color: cor);
  }

  // ---------------------------------------------------------------------------
  // Dialog para iniciar rachão (escolha de modalidade)
  // ---------------------------------------------------------------------------
  void _dialogIniciarRachao(BuildContext context) {
    var modalidade = Modalidade.quadra;
    var porTime = 6;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: const Color(0xFF0D1F3C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          title: const Text('Iniciar Rachão',
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Modalidade',
                  style: TextStyle(color: Colors.white54, fontSize: 13)),
              const SizedBox(height: 10),
              Row(
                children: Modalidade.values.map((m) {
                  final sel = modalidade == m;
                  final cor = m == Modalidade.areia
                      ? const Color(0xFFFFD700)
                      : const Color(0xFF00BCD4);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => setState(() {
                          modalidade = m;
                          porTime = m == Modalidade.areia ? 2 : 6;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: sel
                                ? cor.withValues(alpha: 0.18)
                                : Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: sel
                                  ? cor
                                  : Colors.white.withValues(alpha: 0.12),
                              width: sel ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(m.emoji,
                                  style: const TextStyle(fontSize: 22)),
                              const SizedBox(height: 4),
                              Text(m.label,
                                  style: TextStyle(
                                      color: sel ? cor : Colors.white54,
                                      fontSize: 13,
                                      fontWeight: sel
                                          ? FontWeight.bold
                                          : FontWeight.normal)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (modalidade == Modalidade.areia) ...[
                const SizedBox(height: 20),
                const Text('Formato',
                    style: TextStyle(color: Colors.white54, fontSize: 13)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _formatoBtn('Duplas', 2, porTime,
                        (v) => setState(() => porTime = v)),
                    const SizedBox(width: 10),
                    _formatoBtn('Trios', 3, porTime,
                        (v) => setState(() => porTime = v)),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 20),
                const Text('Jogadores por time',
                    style: TextStyle(color: Colors.white54, fontSize: 13)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (porTime > 2) setState(() => porTime--);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: const Icon(Icons.remove,
                            color: Colors.white54, size: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('$porTime',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => porTime++),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: const Icon(Icons.add,
                            color: Colors.white54, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar',
                  style: TextStyle(color: Colors.white38)),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35)),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Iniciar'),
              onPressed: () async {
                await db.criarSessaoComCheckIns(
                    modalidade: modalidade, porTime: porTime);
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _formatoBtn(
      String label, int value, int atual, void Function(int) onTap) {
    final sel = atual == value;
    const cor = Color(0xFFFFD700);
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: sel
                ? cor.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: sel ? cor : Colors.white.withValues(alpha: 0.12),
              width: sel ? 1.5 : 1,
            ),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: sel ? cor : Colors.white38,
                  fontSize: 14,
                  fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Confirmar encerramento da sessão
  // ---------------------------------------------------------------------------
  void _confirmarEncerramento(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1F3C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
        ),
        title: const Text('Encerrar rachão?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'O rachão será finalizado. Os dados de check-in serão arquivados e as estatísticas dos jogadores mantidas.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.white38)),
          ),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () async {
              final sessao = sessaoAtualSignal.value.value;
              if (sessao != null) await db.encerrarSessao(sessao.id);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Encerrar'),
          ),
        ],
      ),
    );
  }

  String _fmtData(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d/$m';
  }
}

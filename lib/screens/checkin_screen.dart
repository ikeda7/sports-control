import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../db.dart';
import '../models/jogador.dart';
import '../signals.dart';

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

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

    if (sessao == null) return _buildSemSessao(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, sessao.criadaEm, sessao.id),
        Expanded(child: _buildLista(context, sessao.id)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Estado: nenhum rachão iniciado
  // ---------------------------------------------------------------------------
  Widget _buildSemSessao(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sports_volleyball_rounded,
              size: 72, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 24),
          const Text('Nenhum rachão ativo',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Todos os jogadores serão marcados como presentes automaticamente',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4), fontSize: 14),
              textAlign: TextAlign.center),
          const SizedBox(height: 32),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            icon: const Icon(Icons.play_arrow_rounded, size: 28),
            label: const Text('Iniciar Rachão',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            onPressed: () async {
              await db.criarSessaoComCheckIns();
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header com data, botões todos/nenhum e botão de encerrar
  // ---------------------------------------------------------------------------
  Widget _buildHeader(BuildContext context, DateTime data, int sessaoId) {
    final dataFmt = _fmtData(data);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Check-in',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2)),
                    Watch((ctx) {
                      final presentes = todosComStatusSignal.value.value
                              ?.where((j) => j.checkedIn)
                              .length ??
                          0;
                      return Text(
                        '$dataFmt • $presentes presente${presentes != 1 ? 's' : ''}',
                        style:
                            const TextStyle(color: Colors.white54, fontSize: 14),
                      );
                    }),
                  ],
                ),
              ),
              // Botão encerrar sessão
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade300,
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.4)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                icon: const Icon(Icons.stop_circle_outlined, size: 18),
                label: const Text('Encerrar', style: TextStyle(fontSize: 13)),
                onPressed: () => _confirmarEncerramento(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Ações rápidas: selecionar / desselecionar todos
          Row(
            children: [
              _buildAcaoRapida(
                icon: Icons.check_circle_outline,
                label: 'Todos',
                color: const Color(0xFF4CAF50),
                onTap: () => db.checkInTodos(sessaoId),
              ),
              const SizedBox(width: 10),
              _buildAcaoRapida(
                icon: Icons.cancel_outlined,
                label: 'Nenhum',
                color: Colors.white38,
                onTap: () => db.checkOutTodos(sessaoId),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildAcaoRapida({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(color: color, fontSize: 13)),
          ],
        ),
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
        return Center(
          child: Text('Nenhum jogador cadastrado',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4), fontSize: 16)),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: lista.length,
        itemBuilder: (ctx, i) =>
            _buildItemJogador(lista[i], sessaoId),
      );
    });
  }

  Widget _buildItemJogador(JogadorComStatus jcs, int sessaoId) {
    final jogador = jcs.jogador;
    final presente = jcs.checkedIn;
    final corGenero = jogador.genero == Genero.feminino
        ? const Color(0xFFE91E8C)
        : const Color(0xFF2196F3);
    final bordaColor = presente
        ? const Color(0xFF4CAF50)
        : Colors.white.withValues(alpha: 0.12);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: presente
                  ? const Color(0xFF4CAF50).withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: bordaColor, width: presente ? 1.5 : 1),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              onTap: () => db.toggleCheckIn(sessaoId, jogador.id),
              leading: Stack(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: corGenero.withValues(alpha: 0.15),
                      border: Border.all(
                        color: presente ? const Color(0xFF4CAF50) : corGenero,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        jogador.nome[0].toUpperCase(),
                        style: TextStyle(
                            color: corGenero,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ),
                  ),
                  if (presente)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check,
                            color: Colors.white, size: 11),
                      ),
                    ),
                ],
              ),
              title: Text(
                jogador.nome,
                style: TextStyle(
                    color: presente ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 15),
              ),
              subtitle: Text(
                '${jogador.partidasJogadas} partidas  •  Peso ${(jogador.pesoTecnico * 100).round()}%',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
              trailing: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: presente
                      ? const Color(0xFF4CAF50)
                      : Colors.white.withValues(alpha: 0.08),
                  border: Border.all(
                    color: presente
                        ? const Color(0xFF4CAF50)
                        : Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  presente ? Icons.check : Icons.add,
                  color: presente ? Colors.white : Colors.white38,
                  size: 18,
                ),
              ),
            ),
          ),
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

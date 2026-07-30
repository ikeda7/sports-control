import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../db.dart';
import '../design/design.dart';
import '../models/jogador.dart';
import '../signals.dart';
import '../utils/seed.dart';

/// Cor do badge de nível. Iniciante é cinza de propósito: nível é informação
/// neutra, não mérito.
Color _corNivel(Nivel n) => switch (n) {
      Nivel.iniciante => SCColors.grey,
      Nivel.intermediario => SCColors.blue,
      Nivel.avancado => SCColors.green,
    };

class JogadoresScreen extends StatelessWidget {
  const JogadoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // O gradiente e a largura de conteúdo vêm do shell (MainScreen). A tela só
    // entrega o corpo.
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: SCSpace.x8,
                right: SCSpace.x8,
                top: SCSpace.x10,
              ),
              child: _buildHeader(context),
            ),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
      floatingActionButton: Padding(
        // Sobe o FAB acima da barra de navegação de vidro — antes ele cobria o
        // último card da lista.
        padding: const EdgeInsets.only(bottom: SCSpace.x4),
        child: FloatingActionButton.extended(
          onPressed: () => _mostrarDialogJogador(context, null),
          backgroundColor: SCColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.person_add),
          label: const Text('Novo Jogador'),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Watch((ctx) {
      final lista = jogadoresSignal.value.value ?? [];
      final levs = lista.where((j) => j.isLevantador).length;
      return SCScreenHeader(
        title: 'Jogadores',
        // Números, não adjetivos — e plural batendo com a contagem real.
        status: '${lista.length} ${lista.length == 1 ? 'jogador' : 'jogadores'}'
            ' • $levs ${levs == 1 ? 'levantador' : 'levantadores'}',
        trailing: _buildMenu(context),
      );
    });
  }

  Widget _buildMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: SCColors.textTertiary),
      color: SCColors.bgNavy,
      shape: RoundedRectangleBorder(
        borderRadius: SCRadius.all(SCRadius.lg),
        side: BorderSide(color: SCColors.line2),
      ),
      onSelected: (v) async {
        if (v == 'seed') {
          await _confirmarSeed(context);
        } else if (v == 'limpar') {
          await _confirmarLimparTodos(context);
        } else if (v == 'importar') {
          _mostrarDialogImportar(context);
        }
      },
      itemBuilder: (_) => [
        _itemMenu(
          valor: 'importar',
          icone: Icons.upload_file_outlined,
          texto: 'Importar lista de nomes',
        ),
        _itemMenu(
          valor: 'seed',
          icone: Icons.science_outlined,
          texto: 'Popular dados de teste',
        ),
        _itemMenu(
          valor: 'limpar',
          icone: Icons.delete_sweep_outlined,
          texto: 'Limpar todos os jogadores',
          cor: SCColors.danger,
        ),
      ],
    );
  }

  PopupMenuItem<String> _itemMenu({
    required String valor,
    required IconData icone,
    required String texto,
    Color? cor,
  }) {
    final c = cor ?? SCColors.textSecondary;
    return PopupMenuItem(
      value: valor,
      child: Row(children: [
        Icon(icone, color: c, size: 18),
        const SizedBox(width: SCSpace.x5),
        Text(texto, style: TextStyle(color: c, fontSize: SCType.fsBody)),
      ]),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Watch((ctx) {
      final estado = jogadoresSignal.value;
      if (estado.isLoading) return const Center(child: CircularProgressIndicator());
      final jogadores = estado.value ?? [];
      if (jogadores.isEmpty) return _buildVazio(context);
      return ListView.builder(
        padding: const EdgeInsets.only(
          left: SCSpace.x8,
          right: SCSpace.x8,
          top: SCSpace.x4,
          // Espaço para a nav de vidro e o FAB não cobrirem o último card.
          bottom: SCLayout.bottomNavClearance + SCSpace.x11,
        ),
        itemCount: jogadores.length,
        itemBuilder: (ctx, i) => _buildCard(context, jogadores[i]),
      );
    });
  }

  Widget _buildCard(BuildContext context, Jogador jogador) {
    return SCPlayerRow(
      name: jogador.nome,
      genderColor: jogador.genero == Genero.feminino
          ? SCColors.female
          : SCColors.male,
      selectable: true,
      onTap: () => _mostrarDialogJogador(context, jogador),
      badges: [
        // LEV primeiro: é a informação que o organizador procura ao montar time.
        if (jogador.isLevantador)
          const SCRowBadge('LEV', color: SCColors.setter),
        SCRowBadge(jogador.nivel.label, color: _corNivel(jogador.nivel)),
        for (final p in jogador.papeis)
          SCRowBadge(p.label, color: SCColors.primary),
      ],
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Antes o número e a lixeira ficavam empilhados, o que esticava o card
          // e desperdiçava largura. Lado a lado o card encurta bastante.
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${jogador.partidasJogadas}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: SCColors.textPrimary,
                ),
              ),
              Text(
                jogador.partidasJogadas == 1 ? 'partida' : 'partidas',
                style: TextStyle(
                  fontSize: SCType.fsNano,
                  color: SCColors.textFaint,
                ),
              ),
            ],
          ),
          const SizedBox(width: SCSpace.x3),
          SCIconActionButton(
            icon: Icons.delete_outline,
            color: SCColors.danger,
            size: SCButtonSize.sm,
            tinted: false,
            tooltip: 'Excluir jogador',
            onPressed: () => _confirmarDelete(context, jogador),
          ),
        ],
      ),
    );
  }

  Widget _buildVazio(BuildContext context) {
    return SCEmptyState(
      icon: Icons.sports_volleyball,
      title: 'Nenhum jogador cadastrado',
      subtitle: 'Cadastre os jogadores do rachão para poder fazer check-in e sortear os times.',
      actionLabel: 'Popular dados de teste',
      onAction: () => _confirmarSeed(context),
    );
  }

  // ── DIALOG — criar / editar jogador ─────────────────────────────────────────

  void _mostrarDialogJogador(BuildContext context, Jogador? existente) {
    final nomeCtrl = TextEditingController(text: existente?.nome ?? '');
    var genero = existente?.genero ?? Genero.masculino;
    var nivel = existente?.nivel ?? Nivel.intermediario;
    var papeis = List<Papel>.from(existente?.papeis ?? []);
    final editando = existente != null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: const Color(0xFF0D1F3C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          title: Text(editando ? 'Editar Jogador' : 'Novo Jogador',
              style: const TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome
                TextField(
                  controller: nomeCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    labelStyle: const TextStyle(color: Colors.white54),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.24)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF6B35)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Gênero
                const Text('Gênero', style: TextStyle(color: Colors.white54, fontSize: 13)),
                const SizedBox(height: 8),
                SegmentedButton<Genero>(
                  segments: const [
                    ButtonSegment(value: Genero.masculino, label: Text('Masculino'), icon: Icon(Icons.male)),
                    ButtonSegment(value: Genero.feminino, label: Text('Feminino'), icon: Icon(Icons.female)),
                  ],
                  selected: {genero},
                  onSelectionChanged: (v) => setState(() => genero = v.first),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return const Color(0xFFFF6B35).withValues(alpha: 0.3);
                      }
                      return Colors.transparent;
                    }),
                  ),
                ),
                const SizedBox(height: 20),

                // Nível
                const Text('Nível técnico',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text(
                  'Determina o peso no sorteio equilibrado',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
                const SizedBox(height: 10),
                Row(
                  children: Nivel.values.map((n) {
                    final selecionado = nivel == n;
                    final cor = switch (n) {
                      Nivel.iniciante => const Color(0xFF9E9E9E),
                      Nivel.intermediario => const Color(0xFF2196F3),
                      Nivel.avancado => const Color(0xFF4CAF50),
                    };
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: GestureDetector(
                          onTap: () => setState(() => nivel = n),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selecionado
                                  ? cor.withValues(alpha: 0.2)
                                  : Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selecionado ? cor : Colors.white.withValues(alpha: 0.12),
                                width: selecionado ? 1.5 : 1,
                              ),
                            ),
                            child: Text(n.label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: selecionado ? cor : Colors.white38,
                                    fontSize: 12,
                                    fontWeight: selecionado
                                        ? FontWeight.bold
                                        : FontWeight.normal)),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Papéis
                const Text('Papéis / Posições',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text(
                  'Selecione um ou mais (opcional)',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: Papel.values.map((p) {
                    final selecionado = papeis.contains(p);
                    final cor = p == Papel.levantador
                        ? const Color(0xFFFFD700)
                        : const Color(0xFFFF6B35);
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (selecionado) {
                          papeis.remove(p);
                        } else {
                          papeis.add(p);
                        }
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: selecionado
                              ? cor.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selecionado ? cor : Colors.white.withValues(alpha: 0.15),
                            width: selecionado ? 1.5 : 1,
                          ),
                        ),
                        child: Text(p.label,
                            style: TextStyle(
                                color: selecionado ? cor : Colors.white38,
                                fontSize: 13,
                                fontWeight: selecionado
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white38)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF6B35)),
              onPressed: () async {
                final nome = nomeCtrl.text.trim();
                if (nome.isEmpty) return;
                if (editando) {
                  await db.updateJogador(existente.id,
                      nome: nome,
                      genero: genero,
                      nivel: nivel,
                      papeis: papeis);
                } else {
                  await db.insertJogador(
                      nome: nome,
                      genero: genero,
                      nivel: nivel,
                      papeis: papeis);
                }
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: Text(editando ? 'Salvar' : 'Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  // ── CONFIRMAÇÕES ────────────────────────────────────────────────────────────

  Future<void> _confirmarSeed(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1F3C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text('Popular dados de teste?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Serão adicionados 22 jogadores genéricos (11 homens, 11 mulheres, 2 levantadores). Os jogadores existentes não serão removidos.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white38)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF6B35)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Popular'),
          ),
        ],
      ),
    );
    if (ok == true) await seedJogadores();
  }

  // ── IMPORTAR LISTA DE NOMES ─────────────────────────────────────────────────

  static List<_ImportEntry> _parsearNomes(String texto) {
    final resultado = <_ImportEntry>[];
    for (var linha in texto.split('\n')) {
      if (linha.contains('~')) {
        linha = linha.substring(linha.indexOf('~') + 1);
      }
      linha = linha.replaceAll(RegExp(r'^\s*[\+\d][\d\s\-\(\)\.]{5,}\s*'), '');
      linha = linha.replaceAll(RegExp(r'^\s*\d+\s*[\.\):\-]\s*'), '');
      linha = linha
          .replaceAll(RegExp(r"[^a-zA-ZÀ-ÿ\s'\-]"), '')
          .trim()
          .replaceAll(RegExp(r'\s+'), ' ');
      if (linha.length >= 2) resultado.add(_ImportEntry(linha));
    }
    return resultado;
  }

  void _mostrarDialogImportar(BuildContext context) {
    final ctrl = TextEditingController();
    var entradas = <_ImportEntry>[];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: const Color(0xFF0D1F3C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          title: const Text('Importar lista de nomes',
              style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cole a lista (WhatsApp, numerada ou um nome por linha):',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: ctrl,
                  maxLines: 6,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText:
                        '+55 11 99999-9999 ~ João Silva\n1. Maria Santos\nPedro Costa...',
                    hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.2), fontSize: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF6B35)),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.04),
                  ),
                  onChanged: (v) => setState(() => entradas = _parsearNomes(v)),
                ),
                if (entradas.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    '${entradas.length} nome${entradas.length != 1 ? 's' : ''} — toque em ♂/♀ para ajustar:',
                    style: const TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: entradas.length,
                      itemBuilder: (_, i) {
                        final e = entradas[i];
                        final isFem = e.genero == Genero.feminino;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => setState(() {
                                  e.genero =
                                      isFem ? Genero.masculino : Genero.feminino;
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (isFem
                                            ? const Color(0xFFE91E8C)
                                            : const Color(0xFF2196F3))
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: (isFem
                                              ? const Color(0xFFE91E8C)
                                              : const Color(0xFF2196F3))
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: Icon(
                                    isFem
                                        ? Icons.female_rounded
                                        : Icons.male_rounded,
                                    color: isFem
                                        ? const Color(0xFFE91E8C)
                                        : const Color(0xFF2196F3),
                                    size: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(e.nome,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 13)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Nível padrão: Intermediário. Edite individualmente depois.',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3), fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white38)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: entradas.isNotEmpty
                      ? const Color(0xFFFF6B35)
                      : Colors.white.withValues(alpha: 0.1)),
              onPressed: entradas.isEmpty
                  ? null
                  : () async {
                      final existentes =
                          (jogadoresSignal.value.value ?? [])
                              .map((j) => j.nome.toLowerCase())
                              .toSet();
                      var importados = 0;
                      for (final e in entradas) {
                        if (existentes.contains(e.nome.toLowerCase())) continue;
                        await db.insertJogador(
                          nome: e.nome,
                          genero: e.genero,
                          nivel: Nivel.intermediario,
                          papeis: [],
                        );
                        importados++;
                      }
                      if (ctx.mounted) {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                          content: Text(importados == 0
                              ? 'Todos os nomes já existem'
                              : '$importados jogador${importados != 1 ? 'es' : ''} importado${importados != 1 ? 's' : ''}'),
                          duration: const Duration(seconds: 3),
                        ));
                      }
                    },
              child: Text(entradas.isEmpty ? 'Importar' : 'Importar ${entradas.length}'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmarLimparTodos(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1F3C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
        ),
        title: const Text('Limpar todos os jogadores?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Todos os jogadores, check-ins e times sorteados serão removidos permanentemente.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white38)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Limpar tudo'),
          ),
        ],
      ),
    );
    if (ok == true) await db.deleteAllJogadores();
  }

  void _confirmarDelete(BuildContext context, Jogador jogador) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1F3C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
        ),
        title: const Text('Remover jogador?', style: TextStyle(color: Colors.white)),
        content: Text('${jogador.nome} será removido permanentemente.',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white38)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () async {
              await db.deleteJogador(jogador.id);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}

class _ImportEntry {
  String nome;
  Genero genero = Genero.masculino;
  _ImportEntry(this.nome);
}

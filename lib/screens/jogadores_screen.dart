import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../db.dart';
import '../models/jogador.dart';
import '../signals.dart';
import '../utils/seed.dart';

const _atributos = [
  _Atrib('ATQ', Icons.flash_on_rounded),
  _Atrib('DEF', Icons.shield_rounded),
  _Atrib('BLQ', Icons.back_hand_rounded),
  _Atrib('SAQ', Icons.sports_volleyball_rounded),
  _Atrib('PAS', Icons.swap_horiz_rounded),
];

class JogadoresScreen extends StatelessWidget {
  const JogadoresScreen({super.key});

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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              Expanded(child: _buildBody(context)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarDialogJogador(context, null),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Novo Jogador'),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Jogadores',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2)),
                Watch((ctx) {
                  final lista = jogadoresSignal.value.value ?? [];
                  final levs = lista.where((j) => j.isLevantador).length;
                  return Text(
                    '${lista.length} jogadores • $levs levantador${levs != 1 ? 'es' : ''}',
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  );
                }),
              ],
            ),
          ),
          // Menu de opções da tela
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white54),
            color: const Color(0xFF0D1F3C),
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
              const PopupMenuItem(
                value: 'importar',
                child: Row(
                  children: [
                    Icon(Icons.upload_file_outlined,
                        color: Colors.white70, size: 18),
                    SizedBox(width: 10),
                    Text('Importar lista de nomes',
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'seed',
                child: Row(
                  children: [
                    Icon(Icons.science_outlined, color: Colors.white70, size: 18),
                    SizedBox(width: 10),
                    Text('Popular dados de teste',
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'limpar',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep_outlined,
                        color: Colors.red.shade300, size: 18),
                    const SizedBox(width: 10),
                    Text('Limpar todos os jogadores',
                        style: TextStyle(color: Colors.red.shade300)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Watch((ctx) {
      final estado = jogadoresSignal.value;
      if (estado.isLoading) return const Center(child: CircularProgressIndicator());
      final jogadores = estado.value ?? [];
      if (jogadores.isEmpty) return _buildVazio(context);
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: jogadores.length,
        itemBuilder: (ctx, i) => _buildCard(context, jogadores[i]),
      );
    });
  }

  Widget _buildCard(BuildContext context, Jogador jogador) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: jogador.isLevantador
                    ? const Color(0xFFFFD700).withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.12),
                width: jogador.isLevantador ? 1.5 : 1,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _mostrarDialogJogador(context, jogador),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _buildAvatar(jogador),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(jogador.nome,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16)),
                              if (jogador.isLevantador) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD700)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFFFFD700)
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: const Text('LEV',
                                      style: TextStyle(
                                          color: Color(0xFFFFD700),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          _buildAtributosMini(jogador),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildTrailing(context, jogador),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Jogador jogador) {
    final cor = jogador.genero == Genero.feminino
        ? const Color(0xFFE91E8C)
        : const Color(0xFF2196F3);
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cor.withValues(alpha: 0.15),
        border: Border.all(color: cor, width: 2),
      ),
      child: Center(
        child: Text(jogador.nome[0].toUpperCase(),
            style: TextStyle(
                color: cor, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    );
  }

  Widget _buildAtributosMini(Jogador jogador) {
    final vals = [
      jogador.ataque, jogador.defesa, jogador.bloqueio,
      jogador.saque, jogador.passe,
    ];
    return Row(
      children: List.generate(5, (i) {
        final v = vals[i];
        final cor = v >= 4
            ? const Color(0xFF4CAF50)
            : v >= 3
                ? const Color(0xFFFF9800)
                : const Color(0xFFE53935);
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Column(
            children: [
              Text('$v',
                  style: TextStyle(
                      color: cor, fontSize: 13, fontWeight: FontWeight.bold)),
              Text(_atributos[i].abrev,
                  style: const TextStyle(color: Colors.white30, fontSize: 9)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTrailing(BuildContext context, Jogador jogador) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('${jogador.partidasJogadas}',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const Text('partidas',
            style: TextStyle(color: Colors.white38, fontSize: 10)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => _confirmarDelete(context, jogador),
          child:
              Icon(Icons.delete_outline, color: Colors.red.shade300, size: 18),
        ),
      ],
    );
  }

  Widget _buildVazio(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sports_volleyball,
              size: 64, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          Text('Nenhum jogador cadastrado',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4), fontSize: 16)),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white54,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            ),
            icon: const Icon(Icons.science_outlined, size: 18),
            label: const Text('Popular dados de teste'),
            onPressed: () => _confirmarSeed(context),
          ),
        ],
      ),
    );
  }

  // ── DIALOG — criar / editar jogador ─────────────────────────────────────────

  void _mostrarDialogJogador(BuildContext context, Jogador? existente) {
    final nomeCtrl = TextEditingController(text: existente?.nome ?? '');
    var genero = existente?.genero ?? Genero.masculino;
    var isLevantador = existente?.isLevantador ?? false;
    var ataque = existente?.ataque ?? 3;
    var defesa = existente?.defesa ?? 3;
    var bloqueio = existente?.bloqueio ?? 3;
    var saque = existente?.saque ?? 3;
    var passe = existente?.passe ?? 3;
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
                      borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.24)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFFF6B35)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Gênero
                const Text('Gênero',
                    style: TextStyle(color: Colors.white54, fontSize: 13)),
                const SizedBox(height: 8),
                SegmentedButton<Genero>(
                  segments: const [
                    ButtonSegment(
                        value: Genero.masculino,
                        label: Text('Masculino'),
                        icon: Icon(Icons.male)),
                    ButtonSegment(
                        value: Genero.feminino,
                        label: Text('Feminino'),
                        icon: Icon(Icons.female)),
                  ],
                  selected: {genero},
                  onSelectionChanged: (v) =>
                      setState(() => genero = v.first),
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return const Color(0xFFFF6B35).withValues(alpha: 0.3);
                      }
                      return Colors.transparent;
                    }),
                  ),
                ),
                const SizedBox(height: 16),

                // Toggle Levantador
                Container(
                  decoration: BoxDecoration(
                    color: isLevantador
                        ? const Color(0xFFFFD700).withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isLevantador
                          ? const Color(0xFFFFD700).withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: SwitchListTile(
                    dense: true,
                    title: const Text('Levantador fixo (6x0)',
                        style:
                            TextStyle(color: Colors.white, fontSize: 14)),
                    subtitle: Text(
                      'Jogador que levanta em todas as rotações',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 11),
                    ),
                    value: isLevantador,
                    activeThumbColor: const Color(0xFFFFD700),
                    onChanged: (v) =>
                        setState(() => isLevantador = v),
                    secondary: Icon(
                      Icons.star_rounded,
                      color: isLevantador
                          ? const Color(0xFFFFD700)
                          : Colors.white24,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Atributos
                const Text('Atributos',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text(
                  'Avalie cada habilidade de 1 (fraco) a 5 (excelente)',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
                const SizedBox(height: 12),
                _buildStarRow('⚡ Ataque', ataque,
                    (v) => setState(() => ataque = v)),
                _buildStarRow('🛡️ Defesa', defesa,
                    (v) => setState(() => defesa = v)),
                _buildStarRow('✋ Bloqueio', bloqueio,
                    (v) => setState(() => bloqueio = v)),
                _buildStarRow('🏐 Saque', saque,
                    (v) => setState(() => saque = v)),
                _buildStarRow('🤝 Passe', passe,
                    (v) => setState(() => passe = v)),
                const SizedBox(height: 12),
                _buildPesoPreview(ataque, defesa, bloqueio, saque, passe),
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
                  backgroundColor: const Color(0xFFFF6B35)),
              onPressed: () async {
                final nome = nomeCtrl.text.trim();
                if (nome.isEmpty) return;
                if (editando) {
                  await db.updateJogadorAtributos(existente.id,
                      nome: nome,
                      isLevantador: isLevantador,
                      ataque: ataque,
                      defesa: defesa,
                      bloqueio: bloqueio,
                      saque: saque,
                      passe: passe);
                } else {
                  await db.insertJogador(
                      nome: nome,
                      genero: genero,
                      isLevantador: isLevantador,
                      ataque: ataque,
                      defesa: defesa,
                      bloqueio: bloqueio,
                      saque: saque,
                      passe: passe);
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

  Widget _buildStarRow(
      String label, int valor, void Function(int) onChange) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ),
          ...List.generate(
            5,
            (i) => GestureDetector(
              onTap: () => onChange(i + 1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Icon(
                  i < valor ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: i < valor
                      ? const Color(0xFFFF6B35)
                      : Colors.white24,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPesoPreview(
      int ataque, int defesa, int bloqueio, int saque, int passe) {
    final pct = ((ataque + defesa + bloqueio + saque + passe) / 25.0 * 100)
        .round();
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.balance, color: Colors.white38, size: 16),
          const SizedBox(width: 8),
          const Text('Peso para sorteio: ',
              style: TextStyle(color: Colors.white38, fontSize: 12)),
          Text('$pct%',
              style: const TextStyle(
                  color: Color(0xFFFF6B35),
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ],
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
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white38)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Popular'),
          ),
        ],
      ),
    );
    if (ok == true) await seedJogadores();
  }

  // ── IMPORTAR LISTA DE NOMES ─────────────────────────────────────────────────

  /// Extrai nomes de texto colado (WhatsApp, numerada, um por linha).
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
                        color: Colors.white.withValues(alpha: 0.2),
                        fontSize: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFFF6B35)),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.04),
                  ),
                  onChanged: (v) =>
                      setState(() => entradas = _parsearNomes(v)),
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
                                  e.genero = isFem
                                      ? Genero.masculino
                                      : Genero.feminino;
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
                                        color: Colors.white70,
                                        fontSize: 13)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Atributos padrão (3/5). Edite individualmente depois.',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 11),
                  ),
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
                        if (existentes.contains(e.nome.toLowerCase())) {
                          continue;
                        }
                        await db.insertJogador(
                          nome: e.nome,
                          genero: e.genero,
                          isLevantador: false,
                          ataque: 3,
                          defesa: 3,
                          bloqueio: 3,
                          saque: 3,
                          passe: 3,
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
              child: Text(entradas.isEmpty
                  ? 'Importar'
                  : 'Importar ${entradas.length}'),
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
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white38)),
          ),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
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
        title: const Text('Remover jogador?',
            style: TextStyle(color: Colors.white)),
        content: Text('${jogador.nome} será removido permanentemente.',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white38)),
          ),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
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

class _Atrib {
  final String abrev;
  final IconData icon;
  const _Atrib(this.abrev, this.icon);
}

class _ImportEntry {
  String nome;
  Genero genero = Genero.masculino;
  _ImportEntry(this.nome);
}

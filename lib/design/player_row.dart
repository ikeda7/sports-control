import 'package:flutter/material.dart';

import 'avatar.dart';
import 'badge.dart';
import 'glass_card.dart';
import 'tokens.dart';

/// Descrição de uma tag ao lado do nome do jogador (nível, papel, LEV).
class SCRowBadge {
  const SCRowBadge(this.label, {this.color = SCColors.orange});
  final String label;
  final Color color;
}

/// Linha de jogador — usada na lista de Jogadores e no Check-in.
///
/// Quando [selectable], a linha inteira é tocável e o estado marcado troca o
/// tint para verde, engrossa a borda e coloca o selo de check no avatar. É o
/// mesmo componente nas duas telas: no Check-in ele é selecionável, na lista de
/// Jogadores ele mostra estatística à direita.
class SCPlayerRow extends StatelessWidget {
  const SCPlayerRow({
    super.key,
    required this.name,
    this.genderColor = SCColors.male,
    this.checked = false,
    this.badges = const [],
    this.statValue,
    this.statLabel,
    this.selectable = false,
    this.onTap,
    this.trailing,
  });

  final String name;
  final Color genderColor;
  final bool checked;
  final List<SCRowBadge> badges;

  /// Número à direita (ex: partidas jogadas). Ignorado se [trailing] for dado.
  final String? statValue;
  final String? statLabel;

  final bool selectable;
  final VoidCallback? onTap;

  /// Substitui a área de estatística por um widget próprio (ex: botão de menu).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final inicial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return GlassCard(
      onTap: selectable ? onTap : null,
      emphasized: checked,
      tint: checked
          ? SCColors.green.withValues(alpha: 0.08)
          : Colors.white.withValues(alpha: 0.06),
      borderColor: checked ? SCColors.green : SCColors.line2,
      padding: const EdgeInsets.symmetric(
        horizontal: SCSpace.x8,
        vertical: SCSpace.x5,
      ),
      margin: const EdgeInsets.only(bottom: SCSpace.x5),
      child: Row(
        children: [
          SCAvatar(
            initial: inicial,
            color: genderColor,
            checked: selectable && checked,
            size: 44,
          ),
          const SizedBox(width: SCSpace.x7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: SCType.fsBodyLg,
                    fontWeight: FontWeight.w600,
                    // Não marcado numa lista selecionável fica levemente
                    // apagado — reforça que a ação pendente é marcar.
                    color: checked || !selectable
                        ? SCColors.textPrimary
                        : SCColors.textSecondary,
                  ),
                ),
                if (badges.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: SCSpace.x3,
                    runSpacing: SCSpace.x2,
                    children: [
                      for (final b in badges)
                        SCBadge(label: b.label, color: b.color),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (statValue != null) ...[
            const SizedBox(width: SCSpace.x4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  statValue!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: SCColors.textPrimary,
                  ),
                ),
                if (statLabel != null)
                  Text(
                    statLabel!,
                    style: TextStyle(
                      fontSize: SCType.fsNano,
                      color: SCColors.textFaint,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'tokens.dart';

/// Tag compacta e não interativa: `LEV`, `EMP`, `2/2`, nível, modalidade.
///
/// Sempre bold e minúscula em tamanho (10px). Para algo clicável use [SCChip].
class SCBadge extends StatelessWidget {
  const SCBadge({
    super.key,
    required this.label,
    this.color = SCColors.orange,
    this.solid = false,
    this.icon,
  });

  final String label;
  final Color color;

  /// `true` preenche com a cor cheia e texto branco. Use com parcimônia — o
  /// padrão suave (tint + borda) é o que aparece em quase todo lugar.
  final bool solid;

  /// Emoji ou ícone opcional. O design system restringe emoji a exatamente
  /// dois casos: 🏐 quadra e 🏖️ areia.
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SCSpace.x3,
        vertical: SCSpace.x1,
      ),
      decoration: BoxDecoration(
        color: solid ? color : color.withValues(alpha: 0.12),
        borderRadius: SCRadius.all(SCRadius.xs),
        border: Border.all(
          color: solid ? Colors.transparent : SCColors.border(color),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: SCSpace.x2),
          ],
          Text(
            label,
            style: SCType.badge.copyWith(
              color: solid ? Colors.white : color,
            ),
          ),
        ],
      ),
    );
  }
}

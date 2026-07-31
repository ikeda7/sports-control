import 'package:flutter/material.dart';

import 'tokens.dart';

/// Pill selecionável — nível, papel, filtro.
///
/// Este é o componente onde a convenção de seleção do app fica mais visível:
/// não selecionado é discreto (fundo quase invisível, texto apagado, borda 1px);
/// selecionado ganha tint da cor, texto bold na cor e borda 1.5px cheia.
/// A troca é animada em 150ms.
class SCChip extends StatelessWidget {
  const SCChip({
    super.key,
    required this.label,
    this.selected = false,
    this.color = SCColors.orange,
    this.icon,
    this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = SCRadius.all(SCRadius.pill);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: SCFx.durFast,
        curve: SCFx.ease,
        padding: const EdgeInsets.symmetric(
          horizontal: SCSpace.x6,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.20)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: radius,
          border: Border.all(
            color: selected ? color : SCColors.line3,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected ? color : SCColors.textDisabled,
              ),
              const SizedBox(width: SCSpace.x3),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: SCType.fsBodySm,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? color : SCColors.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

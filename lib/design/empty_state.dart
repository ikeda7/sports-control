import 'package:flutter/material.dart';

import 'buttons.dart';
import 'tokens.dart';

/// Estado vazio: ícone grande e apagado, uma linha nomeando o que falta,
/// opcionalmente um subtítulo e uma ação secundária.
///
/// O tom segue o design system: nomeia o estado em vez de pedir desculpa, e a
/// ação quando existe é secundária ("Popular dados de teste"), nunca primária.
class SCEmptyState extends StatelessWidget {
  const SCEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconSize = 64,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    // Center é essencial: dentro de um Expanded ele ocupa a altura disponível e
    // centraliza; dentro de um scroll ele encolhe para o tamanho do conteúdo.
    // Sem isso o estado vazio cola no topo e deixa a tela com um vão enorme
    // embaixo — foi exatamente o que aconteceu na primeira versão.
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SCSpace.x10,
          vertical: SCSpace.x12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          Icon(
            icon,
            size: iconSize,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          const SizedBox(height: SCSpace.x10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: SCType.subtitle,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: SCSpace.x3),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: SCType.fsBody,
                  color: SCColors.textDisabled,
                  height: 1.4,
                ),
              ),
            ),
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: SCSpace.x8),
            SCButton(
              label: actionLabel!,
              variant: SCButtonVariant.outlined,
              size: SCButtonSize.sm,
              onPressed: onAction,
            ),
          ],
          ],
        ),
      ),
    );
  }
}

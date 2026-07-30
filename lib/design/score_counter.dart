import 'package:flutter/material.dart';

import 'buttons.dart';
import 'tokens.dart';

/// Contador de pontos de um time no placar.
///
/// O número em 72px bold é o maior elemento tipográfico do app — o placar
/// precisa ser legível de dentro da quadra, não da mão. O botão de somar é
/// maior que o de subtrair porque somar é a ação de 99% dos toques.
class SCScoreCounter extends StatelessWidget {
  const SCScoreCounter({
    super.key,
    required this.score,
    this.color = SCColors.orange,
    this.onIncrement,
    this.onDecrement,
  });

  final int score;
  final Color color;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // FittedBox evita que placar de 3 dígitos estoure a coluna em tela
        // estreita — vôlei passa de 100 em tie-break longo.
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '$score',
            style: SCType.score.copyWith(color: color),
          ),
        ),
        const SizedBox(height: SCSpace.x6),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SCIconActionButton(
              icon: Icons.remove,
              color: Colors.white,
              size: SCButtonSize.md,
              onPressed: score > 0 ? onDecrement : null,
              tooltip: 'Menos 1',
            ),
            const SizedBox(width: SCSpace.x8),
            SCIconActionButton(
              icon: Icons.add,
              color: color,
              size: SCButtonSize.lg,
              onPressed: onIncrement,
              tooltip: 'Mais 1',
            ),
          ],
        ),
      ],
    );
  }
}

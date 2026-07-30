import 'package:flutter/material.dart';

import 'tokens.dart';

/// Controle +/- para "jogadores por time".
///
/// Os botões desabilitam nos limites em vez de só ignorar o toque — o usuário
/// vê que chegou no fim do intervalo.
class SCStepper extends StatelessWidget {
  const SCStepper({
    super.key,
    required this.value,
    this.onChanged,
    this.min = 2,
    this.max = 99,
    this.label,
  });

  final int value;
  final ValueChanged<int>? onChanged;
  final int min;
  final int max;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final podeMenos = onChanged != null && value > min;
    final podeMais = onChanged != null && value < max;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: SCType.fsBodySm,
              color: SCColors.textTertiary,
            ),
          ),
          const SizedBox(height: SCSpace.x4),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Passo(
              icon: Icons.remove,
              enabled: podeMenos,
              onTap: podeMenos ? () => onChanged!(value - 1) : null,
            ),
            SizedBox(
              width: 60,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: SCColors.textPrimary,
                ),
              ),
            ),
            _Passo(
              icon: Icons.add,
              enabled: podeMais,
              onTap: podeMais ? () => onChanged!(value + 1) : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _Passo extends StatelessWidget {
  const _Passo({required this.icon, required this.enabled, this.onTap});

  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = SCRadius.all(SCRadius.sm);

    return Opacity(
      opacity: enabled ? 1.0 : 0.35,
      child: Material(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: SCColors.line3),
            ),
            child: Icon(icon, size: 18, color: SCColors.textTertiary),
          ),
        ),
      ),
    );
  }
}

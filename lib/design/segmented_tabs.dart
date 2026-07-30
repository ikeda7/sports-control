import 'package:flutter/material.dart';

import 'tokens.dart';

class SCSegment<T> {
  const SCSegment({required this.value, required this.label, this.icon});
  final T value;
  final String label;
  final IconData? icon;
}

/// Seletor segmentado — modalidade (quadra/areia), escopo do histórico
/// (sessão/global), nível.
///
/// Generaliza o `SegmentedButton` e as fileiras de pill customizadas que
/// existiam em cada tela com estilo próprio.
class SCSegmentedTabs<T> extends StatelessWidget {
  const SCSegmentedTabs({
    super.key,
    required this.segments,
    required this.value,
    this.onChanged,
    this.color = SCColors.orange,
  });

  final List<SCSegment<T>> segments;
  final T value;
  final ValueChanged<T>? onChanged;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SCSpace.x2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: SCRadius.all(SCRadius.lg),
        border: Border.all(color: SCColors.line2),
      ),
      child: Row(
        children: [
          for (final (i, seg) in segments.indexed) ...[
            if (i > 0) const SizedBox(width: SCSpace.x2),
            Expanded(child: _Aba(seg: seg, selected: seg.value == value, color: color, onChanged: onChanged)),
          ],
        ],
      ),
    );
  }
}

class _Aba<T> extends StatelessWidget {
  const _Aba({
    required this.seg,
    required this.selected,
    required this.color,
    required this.onChanged,
  });

  final SCSegment<T> seg;
  final bool selected;
  final Color color;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    final radius = SCRadius.all(SCRadius.md);

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged!(seg.value),
        borderRadius: radius,
        child: AnimatedContainer(
          duration: SCFx.durFast,
          curve: SCFx.ease,
          padding: const EdgeInsets.symmetric(
            horizontal: SCSpace.x5,
            vertical: SCSpace.x4,
          ),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: radius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (seg.icon != null) ...[
                Icon(
                  seg.icon,
                  size: 16,
                  color: selected ? color : SCColors.textSecondary,
                ),
                const SizedBox(width: SCSpace.x3),
              ],
              Flexible(
                child: Text(
                  seg.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: SCType.fsBodySm,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    color: selected ? color : SCColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

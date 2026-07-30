import 'dart:ui';

import 'package:flutter/material.dart';

import 'tokens.dart';

class SCNavItem {
  const SCNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;

  /// Ícone inativo: sempre a variante *outlined*.
  final IconData icon;

  /// Ícone ativo: sempre a variante *filled*, recolorida no laranja.
  final IconData activeIcon;
}

/// Barra de navegação inferior de vidro.
///
/// Segue a convenção do design system: outlined quando inativo, filled e laranja
/// quando ativo. O fundo é `bgVoid` a 85% com blur forte e uma hairline no topo
/// — é o que separa a barra do conteúdo sem usar sombra.
class SCBottomNav extends StatelessWidget {
  const SCBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    this.onChanged,
  });

  final List<SCNavItem> items;
  final int currentIndex;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: SCFx.blurXl, sigmaY: SCFx.blurXl),
        child: Container(
          decoration: BoxDecoration(
            color: SCColors.bgVoid.withValues(alpha: 0.85),
            border: Border(top: BorderSide(color: SCColors.line1)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SCSpace.x2,
                vertical: SCSpace.x4,
              ),
              child: Row(
                children: [
                  for (final (i, item) in items.indexed)
                    Expanded(
                      child: _NavBotao(
                        item: item,
                        active: i == currentIndex,
                        onTap: onChanged == null ? null : () => onChanged!(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBotao extends StatelessWidget {
  const _NavBotao({required this.item, required this.active, this.onTap});

  final SCNavItem item;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cor = active ? SCColors.orange : SCColors.textTertiary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: SCRadius.all(SCRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SCSpace.x2,
            vertical: SCSpace.x3,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(active ? item.activeIcon : item.icon, size: 24, color: cor),
              const SizedBox(height: SCSpace.x1),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: SCType.fsNano,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  color: cor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

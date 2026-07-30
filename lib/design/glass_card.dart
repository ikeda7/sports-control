import 'dart:ui';

import 'package:flutter/material.dart';

import 'tokens.dart';

/// Card de vidro — a superfície base de todo o app.
///
/// Generaliza o padrão `ClipRRect` + `BackdropFilter` + `Container` tintado que
/// estava repetido inline em todas as telas. Não existe card opaco no
/// SportsControl: blur + borda hairline fazem o trabalho que normalmente seria
/// de sombra.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.tint,
    this.borderColor,
    this.radius = SCRadius.xl,
    this.padding = const EdgeInsets.all(SCSpace.x8),
    this.blur = SCFx.blurMd,
    this.emphasized = false,
    this.margin,
    this.onTap,
  });

  final Widget child;

  /// Preenchimento. Padrão: branco a 7%. Para card semântico, use
  /// `SCColors.tint(cor)`.
  final Color? tint;

  /// Borda hairline. Padrão: branco a 12%. Para card semântico, use
  /// `SCColors.border(cor)`.
  final Color? borderColor;

  final double radius;
  final EdgeInsetsGeometry padding;
  final double blur;

  /// Estado selecionado/ativo: engrossa a borda de 1px para 1.5px.
  final bool emphasized;

  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = SCRadius.all(radius);

    Widget surface = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tint ?? SCColors.surface2,
            borderRadius: borderRadius,
            border: Border.all(
              color: borderColor ?? SCColors.line2,
              width: emphasized ? 1.5 : 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      surface = Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          // Toque é a interação primária; o splash discreto é a única
          // concessão a affordance de hover/press.
          splashColor: Colors.white.withValues(alpha: 0.04),
          highlightColor: Colors.white.withValues(alpha: 0.02),
          child: surface,
        ),
      );
    }

    if (margin != null) {
      surface = Padding(padding: margin!, child: surface);
    }

    return surface;
  }
}

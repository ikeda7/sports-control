import 'package:flutter/material.dart';

import 'tokens.dart';

enum SCButtonVariant { filled, outlined, text }

enum SCButtonSize { sm, md, lg }

/// Botão do app. Generaliza os `FilledButton`/`OutlinedButton` inline espalhados
/// pelas telas.
///
/// `filled` é a ação primária (laranja). `outlined` é secundária e — seguindo o
/// design system — usa borda **branca a 20%** mesmo quando colorida, para não
/// competir com o botão primário; só o texto e o ícone recebem a cor.
class SCButton extends StatelessWidget {
  const SCButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = SCButtonVariant.filled,
    this.color = SCColors.primary,
    this.size = SCButtonSize.md,
    this.icon,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final SCButtonVariant variant;
  final Color color;
  final SCButtonSize size;
  final IconData? icon;
  final bool fullWidth;

  bool get _disabled => onPressed == null;

  EdgeInsets get _padding => switch (size) {
        SCButtonSize.sm =>
          const EdgeInsets.symmetric(horizontal: SCSpace.x7, vertical: SCSpace.x4),
        SCButtonSize.md =>
          const EdgeInsets.symmetric(horizontal: SCSpace.x9, vertical: SCSpace.x6),
        SCButtonSize.lg =>
          const EdgeInsets.symmetric(horizontal: 28, vertical: SCSpace.x8),
      };

  double get _fontSize => switch (size) {
        SCButtonSize.sm => SCType.fsBodySm,
        SCButtonSize.md => SCType.fsBody,
        SCButtonSize.lg => SCType.fsBodyLg,
      };

  double get _iconSize => size == SCButtonSize.lg ? 26 : 20;

  @override
  Widget build(BuildContext context) {
    final radius = SCRadius.all(SCRadius.lg);

    final (Color bg, Color fg, Color borda) = switch (variant) {
      SCButtonVariant.filled => (color, Colors.white, Colors.transparent),
      SCButtonVariant.outlined => (Colors.transparent, color, SCColors.line3),
      SCButtonVariant.text => (Colors.transparent, SCColors.textTertiary, Colors.transparent),
    };

    final conteudo = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: _iconSize, color: fg),
          const SizedBox(width: SCSpace.x4),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: _fontSize,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ],
    );

    return Opacity(
      opacity: _disabled ? 0.4 : 1.0,
      child: Material(
        color: bg,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: Container(
            padding: _padding,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: borda),
            ),
            child: conteudo,
          ),
        ),
      ),
    );
  }
}

/// Botão circular só de ícone — substituição de jogador, +/- do placar.
class SCIconActionButton extends StatelessWidget {
  const SCIconActionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color = SCColors.orange,
    this.size = SCButtonSize.md,
    this.tinted = true,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final SCButtonSize size;

  /// `true` desenha o círculo tintado com borda. `false` deixa só o ícone.
  final bool tinted;

  final String? tooltip;

  double get _dim => switch (size) {
        SCButtonSize.sm => 28,
        SCButtonSize.md => 32,
        SCButtonSize.lg => 44,
      };

  double get _iconSize => switch (size) {
        SCButtonSize.sm => 15,
        SCButtonSize.md => 18,
        SCButtonSize.lg => 24,
      };

  @override
  Widget build(BuildContext context) {
    Widget botao = Opacity(
      opacity: onPressed == null ? 0.4 : 1.0,
      child: Material(
        color: tinted ? SCColors.tintStrong(color) : Colors.transparent,
        shape: CircleBorder(
          side: tinted
              ? BorderSide(color: SCColors.border(color))
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: _dim,
            height: _dim,
            child: Icon(icon, size: _iconSize, color: color),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      botao = Tooltip(message: tooltip!, child: botao);
    }
    return botao;
  }
}

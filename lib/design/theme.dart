import 'package:flutter/material.dart';

import 'tokens.dart';

/// Tema Material do app, alinhado aos tokens.
///
/// O objetivo aqui não é estilizar tudo pelo tema — o design system é feito de
/// componentes explícitos em `lib/design/`. O tema serve para os widgets que a
/// gente não controla (diálogos, snackbars, campos de texto, seleção de texto)
/// não aparecerem com o azul padrão do Material no meio de uma UI laranja.
abstract final class SCTheme {
  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: SCColors.primary,
        brightness: Brightness.dark,
        primary: SCColors.primary,
        surface: SCColors.bgNavy,
      ),
      // O gradiente do shell é o fundo. Transparente aqui evita uma faixa opaca
      // aparecendo atrás dele.
      scaffoldBackgroundColor: Colors.transparent,
    );

    return base.copyWith(
      splashFactory: InkSparkle.splashFactory,

      textTheme: base.textTheme.apply(
        bodyColor: SCColors.textPrimary,
        displayColor: SCColors.textPrimary,
      ),

      // ── Diálogos ──
      // O design system pede pergunta direta como título ("Encerrar rachão?")
      // sobre superfície escura com raio 20.
      dialogTheme: DialogThemeData(
        backgroundColor: SCColors.bgNavy,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: SCRadius.all(SCRadius.xxl),
          side: BorderSide(color: SCColors.line2),
        ),
        titleTextStyle: SCType.subtitle,
        contentTextStyle: TextStyle(
          fontSize: SCType.fsBody,
          color: SCColors.textSecondary,
          height: 1.4,
        ),
      ),

      // ── Snackbar ──
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: SCColors.bgViolet,
        contentTextStyle: const TextStyle(
          fontSize: SCType.fsBody,
          color: SCColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: SCRadius.all(SCRadius.lg),
          side: BorderSide(color: SCColors.line2),
        ),
      ),

      // ── Campos de texto ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        hintStyle: TextStyle(color: SCColors.textFaint),
        labelStyle: TextStyle(color: SCColors.textTertiary),
        border: OutlineInputBorder(
          borderRadius: SCRadius.all(SCRadius.lg),
          borderSide: BorderSide(color: SCColors.line2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: SCRadius.all(SCRadius.lg),
          borderSide: BorderSide(color: SCColors.line2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: SCRadius.all(SCRadius.lg),
          borderSide: const BorderSide(color: SCColors.primary, width: 1.5),
        ),
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: SCColors.primary,
        selectionColor: SCColors.primary.withValues(alpha: 0.30),
        selectionHandleColor: SCColors.primary,
      ),

      // ── Diálogos e ações padrão ──
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: SCColors.primary),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: SCColors.primary,
      ),

      dividerTheme: DividerThemeData(color: SCColors.line1, thickness: 1),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: SCColors.bgVoid.withValues(alpha: 0.95),
          borderRadius: SCRadius.all(SCRadius.sm),
          border: Border.all(color: SCColors.line2),
        ),
        textStyle: TextStyle(
          fontSize: SCType.fsMicro,
          color: SCColors.textSecondary,
        ),
      ),
    );
  }
}

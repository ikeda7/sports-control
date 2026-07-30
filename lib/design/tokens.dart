/// Tokens do design system do SportsControl.
///
/// Tradução direta de `.claude/skills/design/tokens/*.css`. Os valores de alpha
/// vêm dos sufixos hex usados no CSS do design system:
/// `14`→0.08, `1f`→0.12, `26`→0.15, `2e`→0.18, `33`→0.20, `66`→0.40, `99`→0.60.
///
/// Nunca use cor ou medida literal nas telas — sempre passe por aqui, senão o
/// sistema deixa de ser sistema.
library;

import 'package:flutter/material.dart';

// ─── Cores ───────────────────────────────────────────────────────────────────

abstract final class SCColors {
  // Fundo
  static const bgVoid = Color(0xFF070B18);
  static const bgNavy = Color(0xFF0D1F3C);
  static const bgViolet = Color(0xFF1A0A2E);

  /// O único tratamento de fundo do app: diagonal void → navy → violeta.
  static const bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgVoid, bgNavy, bgViolet],
    stops: [0.0, 0.55, 1.0],
  );

  // Paleta
  static const orange = Color(0xFFFF6B35);
  static const gold = Color(0xFFFFD700);
  static const cyan = Color(0xFF00BCD4);
  static const green = Color(0xFF4CAF50);
  static const purple = Color(0xFF9C27B0);
  static const amber = Color(0xFFFF9800);
  static const blue = Color(0xFF2196F3);
  static const pink = Color(0xFFE91E8C);
  static const grey = Color(0xFF9E9E9E);
  static const redSoft = Color(0xFFE57373);
  static const redStrong = Color(0xFFD32F2F);

  // Semânticas
  static const primary = orange;
  static const success = green;
  static const warning = amber;
  static const danger = redSoft;
  static const dangerStrong = redStrong;
  static const info = blue;

  /// Levantador (badge "LEV") e sequência de vitórias.
  static const setter = gold;
  static const female = pink;
  static const male = blue;

  /// Cores de time, até 6. Índices acima disso dão a volta.
  static const teams = [orange, cyan, green, purple, amber, blue];
  static Color team(int ordem) => teams[ordem % teams.length];

  // Superfícies de vidro
  static final surface1 = Colors.white.withValues(alpha: 0.05);
  static final surface2 = Colors.white.withValues(alpha: 0.07);
  static final surface3 = Colors.white.withValues(alpha: 0.10);
  static final surface4 = Colors.white.withValues(alpha: 0.15);

  // Linhas / bordas
  static final line1 = Colors.white.withValues(alpha: 0.08);
  static final line2 = Colors.white.withValues(alpha: 0.12);
  static final line3 = Colors.white.withValues(alpha: 0.20);

  // Texto
  static const textPrimary = Colors.white;
  static final textSecondary = Colors.white.withValues(alpha: 0.70);
  static final textTertiary = Colors.white.withValues(alpha: 0.54);
  static final textDisabled = Colors.white.withValues(alpha: 0.38);
  static final textFaint = Colors.white.withValues(alpha: 0.30);

  /// Tint de preenchimento de um card colorido (equivale ao `+'14'` do CSS).
  static Color tint(Color c) => c.withValues(alpha: 0.08);

  /// Tint mais forte, para cabeçalho de card e botão de ícone (`+'26'`).
  static Color tintStrong(Color c) => c.withValues(alpha: 0.15);

  /// Borda de superfície colorida (`+'66'`).
  static Color border(Color c) => c.withValues(alpha: 0.40);

  /// Texto secundário sobre superfície colorida (`+'99'`).
  static Color onTint(Color c) => c.withValues(alpha: 0.60);
}

// ─── Tipografia ──────────────────────────────────────────────────────────────

abstract final class SCType {
  // Escala
  static const fsDisplay = 28.0;
  static const fsScore = 72.0;
  static const fsTitle = 22.0;
  static const fsSubtitle = 18.0;
  static const fsBodyLg = 16.0;
  static const fsBody = 14.0;
  static const fsBodySm = 13.0;
  static const fsCaption = 12.0;
  static const fsMicro = 11.0;
  static const fsNano = 10.0;
  static const fsPico = 9.0;

  /// Cabeçalho de tela. O bold-28 com +1.2 de letter-spacing é o elemento mais
  /// próximo de uma assinatura visual que o app tem — não altere sem motivo.
  static const display = TextStyle(
    fontSize: fsDisplay,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    height: 1.2,
    color: SCColors.textPrimary,
  );

  static const score = TextStyle(
    fontSize: fsScore,
    fontWeight: FontWeight.w700,
    height: 1.0,
  );

  static const title = TextStyle(
    fontSize: fsTitle,
    fontWeight: FontWeight.w700,
    color: SCColors.textPrimary,
  );

  static const subtitle = TextStyle(
    fontSize: fsSubtitle,
    fontWeight: FontWeight.w600,
    color: SCColors.textPrimary,
  );

  static const bodyLg = TextStyle(fontSize: fsBodyLg, color: SCColors.textPrimary);
  static const body = TextStyle(fontSize: fsBody, color: SCColors.textPrimary);

  /// Rótulo de badge: pequeno, bold, nunca quebra linha.
  static const badge = TextStyle(
    fontSize: fsNano,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );
}

// ─── Espaçamento e raios ─────────────────────────────────────────────────────

abstract final class SCSpace {
  static const x1 = 2.0;
  static const x2 = 4.0;
  static const x3 = 6.0;
  static const x4 = 8.0;
  static const x5 = 10.0;
  static const x6 = 12.0;
  static const x7 = 14.0;
  static const x8 = 16.0;
  static const x9 = 20.0;
  static const x10 = 24.0;
  static const x11 = 32.0;
  static const x12 = 40.0;
  static const x13 = 48.0;
}

abstract final class SCRadius {
  static const xs = 6.0; // badge
  static const sm = 8.0;
  static const md = 10.0;
  static const lg = 12.0; // botão, input
  static const xl = 16.0; // card
  static const xxl = 20.0; // diálogo
  static const pill = 999.0;

  static BorderRadius all(double r) => BorderRadius.circular(r);
}

// ─── Efeitos e movimento ─────────────────────────────────────────────────────

abstract final class SCFx {
  static const blurSm = 8.0;
  static const blurMd = 10.0;
  static const blurLg = 15.0;
  static const blurXl = 20.0;

  /// Movimento utilitário: rápido e sem graça de propósito. Sem bounce, sem
  /// spring — o design system é explícito sobre isso.
  static const durFast = Duration(milliseconds: 150);
  static const durMed = Duration(milliseconds: 200);
  static const durSlow = Duration(milliseconds: 300);
  static const ease = Curves.easeInOut;

  /// Sombras são praticamente não usadas: borda + blur fazem a elevação.
  /// Reservado para o FAB, que é o único elemento que flutua de verdade.
  static const shadowFab = [
    BoxShadow(
      color: Color(0x59FF6B35),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];
}

// ─── Layout ──────────────────────────────────────────────────────────────────

abstract final class SCLayout {
  /// O conteúdo fica com forma de celular mesmo no desktop, centralizado, com
  /// o gradiente preenchendo o resto da viewport. É o que mantém a UI legível
  /// no Windows sem esticar cards por 2000px.
  static const maxContentWidth = 480.0;

  /// Espaço reservado embaixo para a barra de navegação de vidro não cobrir
  /// o último card da lista.
  static const bottomNavClearance = 90.0;
}

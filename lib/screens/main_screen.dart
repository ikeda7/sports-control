import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../design/design.dart';
import '../signals.dart';
import 'checkin_screen.dart';
import 'jogadores_screen.dart';
import 'placar_screen.dart';
import 'sorteio_screen.dart';

/// Shell do app: gradiente, largura de conteúdo e navegação.
///
/// Estrutura, de fora para dentro:
/// 1. gradiente preenchendo a viewport inteira (o único fundo do app)
/// 2. coluna de conteúdo com no máximo 480px, centralizada
/// 3. `IndexedStack` mantendo as 4 telas vivas na memória
/// 4. barra de navegação de vidro
///
/// Antes existiam dois `Scaffold` aninhados e o fora-do-480 no desktop era
/// preto chapado em vez do gradiente. Agora o gradiente é da viewport e o
/// `Scaffold` é um só.
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const _telas = [
    JogadoresScreen(),
    CheckInScreen(),
    SorteioScreen(),
    PlacarScreen(),
  ];

  static const _navItems = [
    SCNavItem(
      label: 'Jogadores',
      icon: Icons.people_outline,
      activeIcon: Icons.people,
    ),
    SCNavItem(
      label: 'Check-in',
      icon: Icons.how_to_reg_outlined,
      activeIcon: Icons.how_to_reg,
    ),
    SCNavItem(
      label: 'Sorteio',
      icon: Icons.shuffle_outlined,
      activeIcon: Icons.shuffle,
    ),
    SCNavItem(
      label: 'Placar',
      icon: Icons.scoreboard_outlined,
      activeIcon: Icons.scoreboard,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // O gradiente fica fora do Watch: ele nunca muda, não precisa reconstruir
    // a cada troca de aba.
    return SCGradientBackground(
      child: Watch((context) {
        final idx = tabIndexSignal.value;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SCContentWidth(
            // O IndexedStack precisa de altura definida; sem isso o
            // SCContentWidth (que alinha no topo) o encolheria.
            child: SizedBox.expand(
              child: IndexedStack(index: idx, children: _telas),
            ),
          ),
          bottomNavigationBar: SCContentWidth(
            child: SCBottomNav(
              items: _navItems,
              currentIndex: idx,
              onChanged: (i) => tabIndexSignal.value = i,
            ),
          ),
        );
      }),
    );
  }
}

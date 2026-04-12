import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../signals.dart';
import 'checkin_screen.dart';
import 'jogadores_screen.dart';
import 'placar_screen.dart';
import 'sorteio_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const _telas = [
    JogadoresScreen(),
    CheckInScreen(),
    SorteioScreen(),
    PlacarScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Watch observa tabIndexSignal e reconstrói apenas o Scaffold quando muda.
    return Watch((context) {
      final idx = tabIndexSignal.value;
      // Em telas largas (desktop/web), centraliza e limita a 480px
      return LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        Widget scaffold = Scaffold(
          // IndexedStack mantém todas as telas na memória (estado preservado ao trocar aba).
          // Equivalente ao RouterOutlet com keepAlive no Angular.
          body: IndexedStack(index: idx, children: _telas),
          bottomNavigationBar: _buildNavBar(idx),
        );
        if (!isWide) return scaffold;
        return Scaffold(
          backgroundColor: const Color(0xFF070B18),
          body: Center(
            child: SizedBox(
              width: 480,
              child: scaffold,
            ),
          ),
        );
      });
    });
  }

  Widget _buildNavBar(int selectedIndex) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF070B18).withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
          ),
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (i) => tabIndexSignal.value = i,
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: const Color(0xFFFF6B35).withValues(alpha: 0.25),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people, color: Color(0xFFFF6B35)),
                label: 'Jogadores',
              ),
              NavigationDestination(
                icon: Icon(Icons.how_to_reg_outlined),
                selectedIcon: Icon(Icons.how_to_reg, color: Color(0xFFFF6B35)),
                label: 'Check-in',
              ),
              NavigationDestination(
                icon: Icon(Icons.shuffle_outlined),
                selectedIcon: Icon(Icons.shuffle, color: Color(0xFFFF6B35)),
                label: 'Sorteio',
              ),
              NavigationDestination(
                icon: Icon(Icons.scoreboard_outlined),
                selectedIcon: Icon(Icons.scoreboard, color: Color(0xFFFF6B35)),
                label: 'Placar',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

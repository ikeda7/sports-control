import 'package:flutter/material.dart';

import 'tokens.dart';

/// Fundo gradiente do app. É o único tratamento de fundo que existe — sem
/// imagem, sem padrão, sem cor por tela.
///
/// Fica no shell, uma vez, atrás do `IndexedStack`. Nenhuma tela deve pintar
/// fundo próprio.
class SCGradientBackground extends StatelessWidget {
  const SCGradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: SCColors.bgGradient),
      child: child,
    );
  }
}

/// Centraliza o conteúdo com largura máxima de 480px.
///
/// É o que faz o app ficar utilizável no Windows: sem isso, um card de jogador
/// se esticaria por 2000px e o avatar ficaria a meio metro do nome. No celular
/// não tem efeito nenhum, porque a tela já é mais estreita que o limite.
class SCContentWidth extends StatelessWidget {
  const SCContentWidth({
    super.key,
    required this.child,
    this.maxWidth = SCLayout.maxContentWidth,
    this.wrapHeight = false,
  });

  final Widget child;
  final double maxWidth;

  /// `true` faz a altura acompanhar o filho em vez de esticar.
  ///
  /// Obrigatório ao usar isto como `bottomNavigationBar`: sem `heightFactor`, o
  /// `Align` expande na vertical, a barra ocupa a tela inteira e o corpo do
  /// `Scaffold` fica sem espaço. Já aconteceu — a nav apareceu no topo com o
  /// resto em branco.
  final bool wrapHeight;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: wrapHeight ? Alignment.bottomCenter : Alignment.topCenter,
      heightFactor: wrapHeight ? 1.0 : null,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Cabeçalho de tela: título em bold-28 com +1.2 de letter-spacing, mais uma
/// linha de status opcional.
///
/// A linha de status é onde o design system pede **números, não adjetivos**:
/// "22 jogadores • 2 levantadores", "6 presentes", "12 no check-in".
class SCScreenHeader extends StatelessWidget {
  const SCScreenHeader({
    super.key,
    required this.title,
    this.status,
    this.statusColor,
    this.trailing,
  });

  final String title;
  final String? status;
  final Color? statusColor;

  /// Ação no canto direito, alinhada ao título.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: SCSpace.x2,
        right: SCSpace.x2,
        bottom: SCSpace.x8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: SCType.display),
                if (status != null) ...[
                  const SizedBox(height: SCSpace.x1),
                  Text(
                    status!,
                    style: TextStyle(
                      fontSize: SCType.fsBody,
                      color: statusColor ?? SCColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Corpo padrão de uma tela: largura limitada, padding do design system e
/// espaço embaixo para a barra de navegação não cobrir o último card.
///
/// Use com [SCScreenHeader] como primeiro filho.
class SCScreenBody extends StatelessWidget {
  const SCScreenBody({
    super.key,
    required this.children,
    this.scrollable = true,
    this.controller,
  });

  final List<Widget> children;
  final bool scrollable;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.only(
      left: SCSpace.x8,
      right: SCSpace.x8,
      top: SCSpace.x9,
      bottom: SCLayout.bottomNavClearance,
    );

    final coluna = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );

    return SCContentWidth(
      child: scrollable
          ? SingleChildScrollView(
              controller: controller,
              padding: padding,
              child: coluna,
            )
          : Padding(padding: padding, child: coluna),
    );
  }
}

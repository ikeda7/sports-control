import 'package:flutter/material.dart';

import 'tokens.dart';

/// Avatar circular com a inicial do jogador.
///
/// A cor vem do gênero (rosa/azul) na lista de jogadores, ou da cor do time
/// dentro de um [TeamCard]. Quando [checked], vira verde e ganha um selo de
/// check — é o feedback de presença no check-in.
class SCAvatar extends StatelessWidget {
  const SCAvatar({
    super.key,
    required this.initial,
    this.color = SCColors.male,
    this.size = 46,
    this.checked = false,
  });

  /// Primeira letra do nome. Já deve vir em maiúscula.
  final String initial;

  final Color color;
  final double size;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    final efetiva = checked ? SCColors.green : color;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: SCFx.durFast,
            curve: SCFx.ease,
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: SCColors.tintStrong(color),
              shape: BoxShape.circle,
              border: Border.all(color: efetiva, width: 2),
            ),
            child: Text(
              initial,
              style: TextStyle(
                fontSize: size * 0.4,
                fontWeight: FontWeight.w700,
                color: efetiva,
              ),
            ),
          ),
          if (checked)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: size * 0.34,
                height: size * 0.34,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: SCColors.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: size * 0.22,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

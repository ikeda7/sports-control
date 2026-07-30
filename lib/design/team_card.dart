import 'package:flutter/material.dart';

import 'avatar.dart';
import 'badge.dart';
import 'buttons.dart';
import 'glass_card.dart';
import 'tokens.dart';

/// Um jogador dentro de um [SCTeamCard].
class SCTeamPlayer {
  const SCTeamPlayer({
    required this.name,
    this.level,
    this.isSetter = false,
    this.borrowed = false,
    this.isFemale = false,
  });

  final String name;

  /// Nível, exibido apagado à direita.
  final String? level;

  /// Levantador — recebe o badge dourado "LEV".
  final bool isSetter;

  /// Emprestado de outro time (a "Regra de Ocupação Total"). Fica em itálico,
  /// com avatar acinzentado e badge "EMP", para o organizador não confundir com
  /// a composição base do time.
  final bool borrowed;

  /// Marca jogadora com o ícone rosa. Existe porque o sorteio garante ao menos
  /// uma mulher por time na quadra — o organizador precisa conferir isso de
  /// relance ao revisar os times sorteados.
  final bool isFemale;
}

/// Card de um time sorteado.
///
/// A cor do time tinge tudo: preenchimento a 8%, borda a 40% e cabeçalho a 15%.
/// O card é sempre `emphasized` — time é entidade de destaque na tela.
class SCTeamCard extends StatelessWidget {
  const SCTeamCard({
    super.key,
    required this.name,
    required this.color,
    this.players = const [],
    this.wins = 0,
    this.summary,
    this.onSubstitute,
    this.footer,
  });

  final String name;
  final Color color;
  final List<SCTeamPlayer> players;

  /// Vitórias consecutivas. Exibe "n/2" em dourado por causa da regra
  /// "ganhou 2 sai".
  final int wins;

  /// Resumo curto à direita do cabeçalho (ex: "2 Avançado · 3 Intermediário").
  final String? summary;

  final VoidCallback? onSubstitute;

  /// Slot opcional no pé do card (ex: botão de iniciar partida).
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      emphasized: true,
      padding: EdgeInsets.zero,
      tint: SCColors.tint(color),
      borderColor: SCColors.border(color),
      margin: const EdgeInsets.only(bottom: SCSpace.x6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Cabeçalho ──
          Container(
            color: SCColors.tintStrong(color),
            padding: const EdgeInsets.only(
              left: SCSpace.x8,
              right: SCSpace.x6,
              top: SCSpace.x6,
              bottom: SCSpace.x6,
            ),
            child: Row(
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: SCType.fsBodyLg,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                if (wins > 0) ...[
                  const SizedBox(width: SCSpace.x4),
                  SCBadge(label: '$wins/2', color: SCColors.setter),
                ],
                const Spacer(),
                if (summary != null)
                  Flexible(
                    child: Text(
                      summary!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: SCType.fsMicro,
                        color: SCColors.onTint(color),
                      ),
                    ),
                  ),
                if (onSubstitute != null) ...[
                  const SizedBox(width: SCSpace.x4),
                  SCIconActionButton(
                    icon: Icons.swap_horiz_rounded,
                    color: SCColors.warning,
                    size: SCButtonSize.sm,
                    onPressed: onSubstitute,
                    tooltip: 'Substituir jogador',
                  ),
                ],
              ],
            ),
          ),

          // ── Jogadores ──
          Padding(
            padding: const EdgeInsets.only(
              left: SCSpace.x8,
              right: SCSpace.x8,
              top: SCSpace.x4,
              bottom: SCSpace.x6,
            ),
            child: Column(
              children: [
                for (final p in players)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: SCSpace.x3),
                    child: Row(
                      children: [
                        SCAvatar(
                          initial: p.name.trim().isEmpty
                              ? '?'
                              : p.name.trim()[0].toUpperCase(),
                          color: p.borrowed
                              ? Colors.white.withValues(alpha: 0.15)
                              : color,
                          size: 28,
                        ),
                        const SizedBox(width: SCSpace.x5),
                        Expanded(
                          child: Text(
                            p.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: SCType.fsBody,
                              fontStyle: p.borrowed
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                              fontWeight: p.borrowed
                                  ? FontWeight.w400
                                  : FontWeight.w500,
                              color: p.borrowed
                                  ? SCColors.textSecondary
                                  : SCColors.textPrimary,
                            ),
                          ),
                        ),
                        if (p.borrowed) ...[
                          const SizedBox(width: SCSpace.x3),
                          const SCBadge(label: 'EMP', color: Colors.white),
                        ],
                        if (p.isSetter) ...[
                          const SizedBox(width: SCSpace.x3),
                          const SCBadge(label: 'LEV', color: SCColors.setter),
                        ],
                        if (p.isFemale) ...[
                          const SizedBox(width: SCSpace.x3),
                          Icon(
                            Icons.female_rounded,
                            size: 14,
                            color: SCColors.female.withValues(alpha: 0.8),
                          ),
                        ],
                        if (p.level != null) ...[
                          const SizedBox(width: SCSpace.x3),
                          Text(
                            p.level!,
                            style: TextStyle(
                              fontSize: SCType.fsMicro,
                              color: SCColors.onTint(color),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                if (footer != null) ...[
                  const SizedBox(height: SCSpace.x4),
                  footer!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

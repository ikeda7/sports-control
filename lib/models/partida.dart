/// Representa uma partida dentro de uma sessão de rachão.
/// [timeAIds] e [timeBIds] são listas de IDs dos jogadores de cada time.
/// [timeANome] e [timeBNome] são os nomes dos times (ex: "Time 1", "Time 2").
/// O placar é atualizado em tempo real pelo organizador.
class Partida {
  final int id;
  final int sessaoId;
  final List<int> timeAIds;
  final List<int> timeBIds;
  final int placarA;
  final int placarB;
  final bool emAndamento;
  final DateTime iniciadaEm;
  final String timeANome;
  final String timeBNome;

  const Partida({
    required this.id,
    required this.sessaoId,
    required this.timeAIds,
    required this.timeBIds,
    required this.placarA,
    required this.placarB,
    required this.emAndamento,
    required this.iniciadaEm,
    this.timeANome = 'Time A',
    this.timeBNome = 'Time B',
  });

  Partida copyWith({
    int? placarA,
    int? placarB,
    bool? emAndamento,
  }) {
    return Partida(
      id: id,
      sessaoId: sessaoId,
      timeAIds: timeAIds,
      timeBIds: timeBIds,
      placarA: placarA ?? this.placarA,
      placarB: placarB ?? this.placarB,
      emAndamento: emAndamento ?? this.emAndamento,
      iniciadaEm: iniciadaEm,
      timeANome: timeANome,
      timeBNome: timeBNome,
    );
  }
}

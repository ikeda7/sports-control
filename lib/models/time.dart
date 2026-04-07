/// Representa um time fixo dentro de uma sessão de rachão.
/// Os times são criados pelo sorteio e persistem na sessão.
/// A composição base é mantida entre partidas; substituições são exceções.
class Time {
  final int id;
  final int sessaoId;
  final String nome; // "Time 1", "Time 2", etc.
  final List<int> jogadorIds;
  final int ordem; // índice base 0, usado para cor e ordenação

  const Time({
    required this.id,
    required this.sessaoId,
    required this.nome,
    required this.jogadorIds,
    required this.ordem,
  });

  Time copyWith({List<int>? jogadorIds}) => Time(
        id: id,
        sessaoId: sessaoId,
        nome: nome,
        jogadorIds: jogadorIds ?? this.jogadorIds,
        ordem: ordem,
      );
}

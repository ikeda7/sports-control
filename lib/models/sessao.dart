/// Representa uma sessão de rachão (normalmente uma por dia).
/// O organizador "inicia" o rachão, faz check-ins, sorteios e placar.
/// Ao final, "encerra" a sessão.
class Sessao {
  final int id;
  final DateTime criadaEm;
  final bool ativa;

  /// IDs do time A do último sorteio salvo (persiste entre reinicializações).
  final List<int> rascunhoAIds;

  /// IDs do time B do último sorteio salvo (persiste entre reinicializações).
  final List<int> rascunhoBIds;

  const Sessao({
    required this.id,
    required this.criadaEm,
    required this.ativa,
    this.rascunhoAIds = const [],
    this.rascunhoBIds = const [],
  });
}

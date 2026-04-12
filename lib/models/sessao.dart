/// Modalidade do rachão.
enum Modalidade {
  quadra,
  areia;

  String get label => switch (this) {
        Modalidade.quadra => 'Quadra',
        Modalidade.areia => 'Areia',
      };

  String get emoji => switch (this) {
        Modalidade.quadra => '🏐',
        Modalidade.areia => '🏖️',
      };

  static Modalidade fromString(String value) =>
      Modalidade.values.firstWhere((e) => e.name == value,
          orElse: () => Modalidade.quadra);
}

/// Representa uma sessão de rachão (normalmente uma por dia).
/// O organizador "inicia" o rachão, faz check-ins, sorteios e placar.
/// Ao final, "encerra" a sessão.
class Sessao {
  final int id;
  final DateTime criadaEm;
  final bool ativa;
  final Modalidade modalidade;

  /// Número de jogadores por time nesta sessão.
  /// Quadra: tipicamente 6. Areia: 2 (duplas) ou 3 (trios).
  final int porTime;

  /// IDs do time A do último sorteio salvo (persiste entre reinicializações).
  final List<int> rascunhoAIds;

  /// IDs do time B do último sorteio salvo (persiste entre reinicializações).
  final List<int> rascunhoBIds;

  const Sessao({
    required this.id,
    required this.criadaEm,
    required this.ativa,
    this.modalidade = Modalidade.quadra,
    this.porTime = 6,
    this.rascunhoAIds = const [],
    this.rascunhoBIds = const [],
  });

  /// Prefixo do nome dos times conforme modalidade e tamanho.
  String get prefixoTime => switch (modalidade) {
        Modalidade.areia when porTime == 2 => 'Dupla',
        Modalidade.areia => 'Trio',
        Modalidade.quadra => 'Time',
      };
}

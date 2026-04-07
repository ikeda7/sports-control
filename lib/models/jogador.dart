/// Gênero do jogador. Usado para contextualização visual (cor do avatar).
enum Genero {
  masculino,
  feminino;

  static Genero fromString(String value) =>
      Genero.values.firstWhere((e) => e.name == value);
}

/// Modelo de domínio do jogador — sem dependência de banco de dados.
///
/// Em um rachão 6x0 (levantador fixo), os jogadores são avaliados por
/// atributos individuais. O [pesoTecnico] é calculado automaticamente
/// como a média normalizada dos 5 atributos (0.2 a 1.0), usado pelo
/// algoritmo de sorteio para equilibrar os times.
class Jogador {
  final int id;
  final String nome;
  final Genero genero;

  /// Se true, este jogador é o levantador fixo (sistema 6x0).
  /// Sinalizados visualmente nos times sorteados.
  final bool isLevantador;

  /// Potência e precisão de ataque (cortada, manchete de ataque). 1–5.
  final int ataque;

  /// Qualidade da defesa de chão (manchete, mergulho, cobertura). 1–5.
  final int defesa;

  /// Eficiência no bloqueio na rede. 1–5.
  final int bloqueio;

  /// Qualidade do saque (float, viagem, potência). 1–5.
  final int saque;

  /// Qualidade do passe/recepção para o levantador. 1–5.
  final int passe;

  /// Total de partidas disputadas — usado para garantir rodízio justo.
  final int partidasJogadas;

  const Jogador({
    required this.id,
    required this.nome,
    required this.genero,
    required this.isLevantador,
    required this.ataque,
    required this.defesa,
    required this.bloqueio,
    required this.saque,
    required this.passe,
    required this.partidasJogadas,
  });

  /// Peso técnico derivado automaticamente dos atributos.
  /// Range: 0.2 (tudo 1★) → 1.0 (tudo 5★).
  double get pesoTecnico => (ataque + defesa + bloqueio + saque + passe) / 25.0;

  double get mediaAtributos => (ataque + defesa + bloqueio + saque + passe) / 5.0;

  Jogador copyWith({
    int? id,
    String? nome,
    Genero? genero,
    bool? isLevantador,
    int? ataque,
    int? defesa,
    int? bloqueio,
    int? saque,
    int? passe,
    int? partidasJogadas,
  }) {
    return Jogador(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      genero: genero ?? this.genero,
      isLevantador: isLevantador ?? this.isLevantador,
      ataque: ataque ?? this.ataque,
      defesa: defesa ?? this.defesa,
      bloqueio: bloqueio ?? this.bloqueio,
      saque: saque ?? this.saque,
      passe: passe ?? this.passe,
      partidasJogadas: partidasJogadas ?? this.partidasJogadas,
    );
  }
}

/// Jogador + status de check-in para a sessão atual.
class JogadorComStatus {
  final Jogador jogador;
  final bool checkedIn;
  const JogadorComStatus(this.jogador, this.checkedIn);
}

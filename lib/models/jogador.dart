/// Gênero do jogador. Usado para contextualização visual (cor do avatar).
enum Genero {
  masculino,
  feminino;

  static Genero fromString(String value) =>
      Genero.values.firstWhere((e) => e.name == value);
}

/// Nível técnico geral do jogador. Determina o peso no sorteio.
enum Nivel {
  iniciante,
  intermediario,
  avancado;

  double get peso => switch (this) {
        Nivel.iniciante => 0.33,
        Nivel.intermediario => 0.66,
        Nivel.avancado => 1.0,
      };

  String get label => switch (this) {
        Nivel.iniciante => 'Iniciante',
        Nivel.intermediario => 'Intermediário',
        Nivel.avancado => 'Avançado',
      };

  static Nivel fromString(String value) =>
      Nivel.values.firstWhere((e) => e.name == value,
          orElse: () => Nivel.intermediario);
}

/// Papel/posição preferencial do jogador no vôlei.
enum Papel {
  levantador,
  atacante,
  libero,
  defensor,
  bloqueador,
  sacador,
  polivalente;

  String get label => switch (this) {
        Papel.levantador => 'Levantador',
        Papel.atacante => 'Atacante',
        Papel.libero => 'Líbero',
        Papel.defensor => 'Defensor',
        Papel.bloqueador => 'Bloqueador',
        Papel.sacador => 'Sacador',
        Papel.polivalente => 'Polivalente',
      };

  static Papel fromString(String value) =>
      Papel.values.firstWhere((e) => e.name == value,
          orElse: () => Papel.polivalente);
}

/// Modelo de domínio do jogador — sem dependência de banco de dados.
///
/// O [pesoTecnico] é derivado do [nivel] e usado pelo algoritmo de sorteio
/// para equilibrar os times (snake-draft).
///
/// [isLevantador] é derivado automaticamente de [papeis] (contém [Papel.levantador]),
/// mas pode ser sobreposto pelo campo explícito para o sistema 6x0.
class Jogador {
  final int id;
  final String nome;
  final Genero genero;
  final Nivel nivel;

  /// Papéis/posições que o jogador desempenha.
  final List<Papel> papeis;

  /// Total de partidas disputadas — usado para garantir rodízio justo.
  final int partidasJogadas;

  const Jogador({
    required this.id,
    required this.nome,
    required this.genero,
    required this.nivel,
    required this.papeis,
    required this.partidasJogadas,
  });

  /// Peso técnico derivado do nível. Usado pelo snake-draft.
  /// Iniciante=0.33, Intermediário=0.66, Avançado=1.0.
  double get pesoTecnico => nivel.peso;

  /// True se o jogador tem o papel de levantador.
  bool get isLevantador => papeis.contains(Papel.levantador);

  Jogador copyWith({
    int? id,
    String? nome,
    Genero? genero,
    Nivel? nivel,
    List<Papel>? papeis,
    int? partidasJogadas,
  }) {
    return Jogador(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      genero: genero ?? this.genero,
      nivel: nivel ?? this.nivel,
      papeis: papeis ?? this.papeis,
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

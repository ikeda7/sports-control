import '../db.dart';
import '../models/jogador.dart';

/// Popula o banco com 22 jogadores genéricos para testes (11 homens, 11 mulheres).
/// Chamado pelo botão "Popular dados de teste" na tela de Jogadores.
Future<void> seedJogadores() async {
  // (nome, genero, nivel, papeis)
  const jogadores = [
    // ── Levantadores ──────────────────────────────────────────────────────────
    ('Rafael Torres',   Genero.masculino, Nivel.avancado,      [Papel.levantador]),
    ('Ana Souza',       Genero.feminino,  Nivel.avancado,      [Papel.levantador]),

    // ── Masculinos ────────────────────────────────────────────────────────────
    ('Lucas Mendes',    Genero.masculino, Nivel.avancado,      [Papel.atacante, Papel.bloqueador]),
    ('Gabriel Costa',   Genero.masculino, Nivel.avancado,      [Papel.polivalente]),
    ('Pedro Alves',     Genero.masculino, Nivel.intermediario, [Papel.libero, Papel.defensor]),
    ('Marcos Santos',   Genero.masculino, Nivel.avancado,      [Papel.bloqueador]),
    ('Thiago Ferreira', Genero.masculino, Nivel.avancado,      [Papel.atacante]),
    ('Diego Oliveira',  Genero.masculino, Nivel.intermediario, [Papel.sacador]),
    ('Bruno Lima',      Genero.masculino, Nivel.intermediario, [Papel.polivalente]),
    ('Felipe Castro',   Genero.masculino, Nivel.avancado,      [Papel.atacante]),
    ('André Moreira',   Genero.masculino, Nivel.intermediario, [Papel.libero]),
    ('Rodrigo Nunes',   Genero.masculino, Nivel.intermediario, [Papel.sacador, Papel.atacante]),

    // ── Femininas ─────────────────────────────────────────────────────────────
    ('Maria Pereira',   Genero.feminino,  Nivel.avancado,      [Papel.atacante]),
    ('Carla Rodrigues', Genero.feminino,  Nivel.intermediario, [Papel.libero, Papel.defensor]),
    ('Paula Santos',    Genero.feminino,  Nivel.intermediario, [Papel.bloqueador]),
    ('Fernanda Lima',   Genero.feminino,  Nivel.intermediario, [Papel.sacador]),
    ('Amanda Costa',    Genero.feminino,  Nivel.avancado,      [Papel.polivalente]),
    ('Juliana Mendes',  Genero.feminino,  Nivel.intermediario, [Papel.defensor]),
    ('Beatriz Ramos',   Genero.feminino,  Nivel.avancado,      [Papel.atacante, Papel.bloqueador]),
    ('Larissa Vieira',  Genero.feminino,  Nivel.intermediario, [Papel.polivalente]),
    ('Camila Faria',    Genero.feminino,  Nivel.iniciante,     [Papel.defensor, Papel.libero]),
    ('Isabela Rocha',   Genero.feminino,  Nivel.intermediario, [Papel.atacante, Papel.bloqueador]),
  ];

  final existentes = await db.getNomesJogadores();
  for (final (nome, genero, nivel, papeis) in jogadores) {
    if (existentes.contains(nome.toLowerCase())) continue;
    await db.insertJogador(
      nome: nome,
      genero: genero,
      nivel: nivel,
      papeis: papeis,
    );
  }
}

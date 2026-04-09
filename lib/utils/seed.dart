import '../db.dart';
import '../models/jogador.dart';

/// Popula o banco com 22 jogadores genéricos para testes (11 homens, 11 mulheres, 2 levantadores).
/// Chamado pelo botão "Popular dados de teste" na tela de Jogadores.
Future<void> seedJogadores() async {
  // (nome, genero, isLevantador, ataque, defesa, bloqueio, saque, passe)
  const jogadores = [
    // ── Levantadores ──────────────────────────────────────────────────────────
    ('Rafael Torres',   Genero.masculino, true,  3, 3, 3, 3, 5), // levantador M
    ('Ana Souza',       Genero.feminino,  true,  3, 3, 3, 3, 5), // levantadora F

    // ── Masculinos ────────────────────────────────────────────────────────────
    ('Lucas Mendes',    Genero.masculino, false, 5, 3, 4, 4, 3), // atacante forte
    ('Gabriel Costa',   Genero.masculino, false, 4, 4, 3, 3, 4), // completo
    ('Pedro Alves',     Genero.masculino, false, 2, 5, 3, 3, 5), // líbero
    ('Marcos Santos',   Genero.masculino, false, 4, 3, 5, 4, 3), // bloqueador
    ('Thiago Ferreira', Genero.masculino, false, 5, 3, 4, 3, 4), // atacante
    ('Diego Oliveira',  Genero.masculino, false, 3, 4, 3, 5, 3), // sacador
    ('Bruno Lima',      Genero.masculino, false, 4, 4, 4, 4, 4), // all-round
    ('Felipe Castro',   Genero.masculino, false, 5, 2, 5, 3, 2), // ponteiro potente
    ('André Moreira',   Genero.masculino, false, 2, 5, 2, 3, 5), // líbero especialista
    ('Rodrigo Nunes',   Genero.masculino, false, 3, 3, 4, 5, 3), // sacador/oposto

    // ── Femininas ─────────────────────────────────────────────────────────────
    ('Maria Pereira',   Genero.feminino,  false, 5, 3, 4, 4, 3), // atacante
    ('Carla Rodrigues', Genero.feminino,  false, 3, 5, 3, 3, 5), // líbero
    ('Paula Santos',    Genero.feminino,  false, 3, 4, 5, 3, 4), // bloqueadora
    ('Fernanda Lima',   Genero.feminino,  false, 4, 3, 3, 5, 3), // sacadora
    ('Amanda Costa',    Genero.feminino,  false, 5, 4, 4, 4, 4), // all-round
    ('Juliana Mendes',  Genero.feminino,  false, 3, 5, 3, 4, 5), // defensora
    ('Beatriz Ramos',   Genero.feminino,  false, 5, 2, 5, 3, 2), // ponteira
    ('Larissa Vieira',  Genero.feminino,  false, 4, 4, 4, 3, 4), // completa
    ('Camila Faria',    Genero.feminino,  false, 2, 5, 2, 4, 5), // recepção elite
    ('Isabela Rocha',   Genero.feminino,  false, 4, 3, 5, 5, 3), // oposta/bloqueadora
  ];

  final existentes = await db.getNomesJogadores();
  for (final (nome, genero, isLev, atq, def, blq, saq, pas) in jogadores) {
    if (existentes.contains(nome.toLowerCase())) continue;
    await db.insertJogador(
      nome: nome,
      genero: genero,
      isLevantador: isLev,
      ataque: atq,
      defesa: def,
      bloqueio: blq,
      saque: saq,
      passe: pas,
    );
  }
}

// Todos os signals compartilhados entre telas.
// Importar db.dart (não main.dart) para evitar dependência circular.
import 'package:signals_flutter/signals_flutter.dart';

import 'db.dart';
import 'models/jogador.dart';
import 'models/sessao.dart';
import 'models/partida.dart';
import 'models/time.dart';

// ---------------------------------------------------------------------------
// HELPER: cria stream que depende da sessão ativa
// ---------------------------------------------------------------------------
// `asyncExpand` é o equivalente ao `switchMap` do RxJS sem cancelamento.
// Para sessões (que mudam no máximo 1x/dia), é perfeitamente adequado.
Stream<T> _comSessao<T>(T padrao, Stream<T> Function(int id) builder) =>
    db.watchSessaoAtual().asyncExpand(
      (sessao) => sessao == null ? Stream.value(padrao) : builder(sessao.id),
    );

// ---------------------------------------------------------------------------
// NAVEGAÇÃO
// ---------------------------------------------------------------------------
/// Índice da aba ativa no NavigationBar. Qualquer tela pode mudar isso.
final tabIndexSignal = signal<int>(0);

// ---------------------------------------------------------------------------
// JOGADORES
// ---------------------------------------------------------------------------
/// Lista completa de jogadores (para JogadoresScreen e lookup por ID).
final jogadoresSignal = streamSignal<List<Jogador>>(
  () => db.watchAllJogadores(),
  initialValue: const [],
);

/// Mapa id→Jogador derivado de [jogadoresSignal]. Usado no PlacarScreen
/// para resolver nomes a partir de IDs armazenados nas partidas.
final jogadoresMapSignal = computed(() {
  final estado = jogadoresSignal.value;
  final lista = estado.hasValue ? estado.value! : <Jogador>[];
  return <int, Jogador>{for (final j in lista) j.id: j};
});

// ---------------------------------------------------------------------------
// SESSÃO ATUAL
// ---------------------------------------------------------------------------
final sessaoAtualSignal = streamSignal<Sessao?>(
  () => db.watchSessaoAtual(),
  initialValue: null,
);

// ---------------------------------------------------------------------------
// CHECK-INS (dependem da sessão ativa)
// ---------------------------------------------------------------------------
/// Todos os jogadores + flag de presença — para a CheckInScreen.
final todosComStatusSignal = streamSignal<List<JogadorComStatus>>(
  () => _comSessao(
    <JogadorComStatus>[],
    (id) => db.watchTodosComStatus(id),
  ),
  initialValue: const [],
);

/// Apenas os jogadores com check-in — para o SorteioScreen.
final checkinsSignal = streamSignal<List<Jogador>>(
  () => _comSessao(<Jogador>[], (id) => db.watchCheckInsDaSessao(id)),
  initialValue: const [],
);

// ---------------------------------------------------------------------------
// TIMES (dependem da sessão ativa)
// ---------------------------------------------------------------------------
/// Times sorteados e persistidos na sessão atual.
final timesSignal = streamSignal<List<Time>>(
  () => _comSessao(<Time>[], (id) => db.watchTimesDaSessao(id)),
  initialValue: const [],
);

// ---------------------------------------------------------------------------
// PARTIDAS (dependem da sessão ativa)
// ---------------------------------------------------------------------------
/// Partida em andamento no momento (null se nenhuma).
final partidaAtualSignal = streamSignal<Partida?>(
  () => _comSessao(null, (id) => db.watchPartidaAtual(id)),
  initialValue: null,
);

/// Histórico de partidas encerradas na sessão atual.
final historicoSignal = streamSignal<List<Partida>>(
  () => _comSessao(<Partida>[], (id) => db.watchHistorico(id)),
  initialValue: const [],
);

/// Histórico global de todas as partidas (independente da sessão atual).
final historicoGlobalSignal = streamSignal<List<Partida>>(
  () => db.watchHistoricoGlobal(),
  initialValue: const [],
);

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Rodar no Windows Desktop (plataforma primária de desenvolvimento)
flutter run -d windows

# Rodar no Android
flutter run -d android

# Build de produção Windows
flutter build windows

# Analisar erros e warnings
flutter analyze

# Rodar testes
flutter test

# Rodar um único teste
flutter test test/widget_test.dart

# Gerar código do Drift após alterar app_database.dart  ← OBRIGATÓRIO após mudanças de schema
dart run build_runner build --delete-conflicting-outputs

# Watcher contínuo (mantém o código gerado atualizado durante desenvolvimento)
dart run build_runner watch --delete-conflicting-outputs
```

> **Windows**: requer Developer Mode ativado (`start ms-settings:developers`) para que Flutter crie symlinks de plugins nativos.

## Arquitetura

### Stack técnica

| Camada | Pacote | Papel |
|---|---|---|
| UI | Flutter + Material 3 | Widgets com tema escuro + glassmorphism |
| Reatividade | `signals_flutter` | `signal<T>` e `Watch()` — idêntico ao Angular Signals |
| Banco | `drift` (SQLite) | ORM reativo; streams emitem automaticamente quando dados mudam |
| Geração de código | `drift_dev` + `build_runner` | Gera `*.g.dart` a partir das anotações `@DriftDatabase` |

### Fluxo de dados

```
AppDatabase (drift)
  └── watch*() → Stream<T>
        └── streamSignal(...)  → signals globais em lib/signals.dart
              └── Watch((ctx) { ... })  → reconstrói apenas o widget observador
```

Toda mutação no `AppDatabase` dispara automaticamente o Stream → atualiza os Signals → reconstrói os `Watch()` relevantes. Não há `setState()` manual na camada de UI.

### Separação de camadas

- **`lib/db.dart`** — singleton global `late AppDatabase db`, inicializado em `main()`. Separado de `main.dart` para quebrar dependência circular: `signals.dart` precisa de `db`, mas `main.dart` importa `main_screen.dart` que importa `signals.dart`.
- **`lib/signals.dart`** — todos os signals compartilhados entre telas. O helper `_comSessao<T>()` cria um stream que depende da sessão ativa (equivalente ao `switchMap` do RxJS): quando a sessão muda, ele troca o stream automaticamente. Signals de escopo de tela ficam no topo do arquivo de tela (fora da classe), como singletons de arquivo.
- **`lib/models/`** — modelos de domínio puros sem dependência de banco. `Jogador` tem `pesoTecnico` calculado como `(ataque + defesa + bloqueio + saque + passe) / 25.0` (range 0.2–1.0), usado pelo algoritmo de sorteio.
- **`lib/database/app_database.dart`** — tudo de Drift: tabelas, queries, conversores Row↔Domain. **Nunca edite `app_database.g.dart`** — é gerado.
- **`lib/screens/`** — 4 telas: `JogadoresScreen` (0), `CheckInScreen` (1), `SorteioScreen` (2), `PlacarScreen` (3).

### Navegação

`MainScreen` usa `IndexedStack` + `tabIndexSignal` (signal global em `signals.dart`). O `IndexedStack` mantém todas as telas vivas na memória (estado preservado ao trocar aba). Qualquer tela pode navegar programaticamente com `tabIndexSignal.value = index`.

### Fluxo de um rachão

1. **Check-in**: `criarSessaoComCheckIns()` cria a sessão e já faz check-in de todos os jogadores. O organizador remove quem não está presente (ou usa os botões "Todos"/"Nenhum").
2. **Sorteio**: `_sortearTimes()` distribui os jogadores em N times via snake-draft por `pesoTecnico`. Os times são persistidos na `TimesTable` via `db.salvarTimes()`. O `timesSignal` reage e exibe os times + a escala round-robin.
3. **Substituição**: cada card de time tem um botão que abre o diálogo de substituição. Ao confirmar, `db.atualizarTimeJogadores()` atualiza o time no banco; o signal auto-atualiza.
4. **Partida**: qualquer par da escala pode ser iniciado com "Iniciar" → `db.criarPartida()` com `timeANome`/`timeBNome` → navega para PlacarScreen (tab 3).
5. **Placar**: mostra o nome dos times (ex: "Time 1 vs Time 2"). Encerrar a partida incrementa `partidasJogadas` de todos os participantes.

### Algoritmo de sorteio (SorteioScreen)

Snake-draft por `pesoTecnico`: embaralha aleatoriamente, ordena por peso desc, distribui os `N × porTime` melhores em padrão ABBA por rodada para equalizar as somas. Gera N times (N = `checkins.length ~/ porTime`).

A escala round-robin é gerada pela função `_gerarEscala(n)`: todos os pares únicos reordenados para minimizar partidas consecutivas do mesmo time.

### Schema do banco (v5)

| Tabela | Propósito |
|---|---|
| `jogadores` | Cadastro permanente de jogadores com atributos 1–5 |
| `sessoes` | Uma sessão por rachão (`ativa` / `encerrada`) |
| `checkins` | Presença por sessão (`UNIQUE sessaoId + jogadorId`) |
| `times` | Times nomeados sorteados por sessão (Time 1, Time 2...) |
| `partidas` | Partidas com placar, nomes dos times e IDs dos jogadores |

### Padrão de adição de tabelas

1. Criar classe `XxxTable extends Table` em `app_database.dart`
2. Adicionar a tabela em `@DriftDatabase(tables: [...])`
3. Adicionar método `watchAllXxx()` que retorna `Stream<List<DomainModel>>`
4. Incrementar `schemaVersion` e adicionar `MigrationStrategy`
5. Rodar `dart run build_runner build --delete-conflicting-outputs`

### Enums persistidos

Enums são serializados pelo **nome** (string), não pelo índice. A reordenação de valores no enum não corrompe dados existentes. A serialização é manual via `.name` / `fromString()` — não use `EnumType.index`.

### IDs de jogadores em listas

Listas de IDs (`timeAIds`, `timeBIds`, `jogadorIds`) são serializadas como string separada por vírgula: `"1,3,7,12"`. Serialização/desserialização via `_serializeIds()` / `_deserializeIds()` em `app_database.dart`.

### Glassmorphism

Cards usam `ClipRRect` + `BackdropFilter(filter: ImageFilter.blur(...))` + `Container` com `Colors.white.withValues(alpha: 0.08)`. Use `.withValues(alpha: x)` (não `.withOpacity()`, que está depreciado no Dart 3.11+).

### Paleta de cores

| Uso | Hex |
|---|---|
| Fundo primário | `0xFF070B18` |
| Gradiente azul | `0xFF0D1F3C` |
| Gradiente roxo | `0xFF1A0A2E` |
| Acento laranja (primário) | `0xFFFF6B35` |
| Time 1 | `0xFFFF6B35` |
| Time 2 | `0xFF00BCD4` |
| Time 3 | `0xFF4CAF50` |
| Time 4 | `0xFF9C27B0` |
| Feminino (avatar) | `0xFFE91E8C` |
| Masculino (avatar) | `0xFF2196F3` |

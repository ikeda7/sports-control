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

# Verificar formatação (hoje 12 de 19 arquivos em lib/ estão fora do padrão — ver issue #14)
dart format --output=none --set-exit-if-changed lib test

# ── Web ──────────────────────────────────────────────────────────────────────
# Compilar o worker do Drift  ← OBRIGATÓRIO antes de qualquer build web
dart compile js -O2 -o web/drift_worker.dart.js lib/database/drift_worker.dart

# Build web (CanvasKit servido localmente em vez de www.gstatic.com)
flutter build web --release --dart-define=FLUTTER_WEB_CANVASKIT_URL=/canvaskit/
```

> **Windows**: requer Developer Mode ativado (`start ms-settings:developers`) para que Flutter crie symlinks de plugins nativos. Sem isso o `flutter pub get` resolve as dependências mas falha no final com `Building with plugins requires symlink support`.

> **Se o `flutter analyze` explodir com centenas de erros `Target of URI doesn't exist`**, não é o código — é o `flutter pub get` que não rodou nesta máquina. Rode e analise de novo.

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
- **`lib/models/`** — modelos de domínio puros sem dependência de banco. `Jogador.pesoTecnico` deriva de `nivel.peso` (iniciante `0.33`, intermediário `0.66`, avançado `1.0`), usado pelo algoritmo de sorteio. `Jogador.isLevantador` deriva de `papeis.contains(Papel.levantador)`.
- **`lib/database/app_database.dart`** — tudo de Drift: tabelas, queries, conversores Row↔Domain. **Nunca edite `app_database.g.dart`** — é gerado.
- **`lib/database/connection_native.dart` / `connection_web.dart`** — abrem o banco por plataforma. O nativo usa `NativeDatabase` sobre o diretório de documentos; o web usa `WasmDatabase` com `sqlite3.wasm` + um worker dedicado. `lib/database/drift_worker.dart` é o entrypoint desse worker e precisa ser compilado à parte (ver Commands).
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

Snake-draft por `pesoTecnico`, em `_sortearTimes(presentes, porTime, modalidade)`. Três detalhes que não são óbvios:

1. **`n = (presentes.length / porTime).ceil()`** — arredonda para **cima**, não para baixo. Com 13 presentes e `porTime = 6` saem 3 times, não 2. Retorna lista vazia se `n < 2`.
2. **Regra de Ocupação Total: ninguém fica no banco.** Times incompletos são preenchidos com jogadores *emprestados* de outros times, marcados com `isEmprestado: true` (uma cópia via `copyWith`, o jogador continua no time original). A prioridade de empréstimo é quem tem menos `partidasJogadas`.
3. **As regras de levantador e de mulher só valem na quadra.** Todo o bloco está sob `if (modalidade == Modalidade.quadra)` — na areia (duplas/trios) não há garantia de levantador nem de mulher por time, o que é intencional.

Ordem de alocação na quadra: levantadores primeiro (menos jogos têm prioridade) → ao menos 1 mulher por time (melhores por `pesoTecnico`) → restantes em snake-draft. Ao completar times, um time sem levantador recebe um levantador emprestado antes de qualquer outro candidato.

> Ainda **não** existe teto de mulheres por time (só piso de 1) nem tratamento de "levantadores fixos contínuos" na escassez — ver issue #10.

A escala round-robin é gerada pela função `_gerarEscala(n)`: todos os pares únicos reordenados para minimizar partidas consecutivas do mesmo time.

### Schema do banco (v8)

| Tabela | Propósito |
|---|---|
| `jogadores` | Cadastro permanente: `nivel` (enum) + `papeis` (lista de enums) |
| `sessoes` | Uma sessão por rachão (`ativa` / `encerrada`), com `modalidade` e `porTime` |
| `checkins` | Presença por sessão (`UNIQUE sessaoId + jogadorId`) |
| `times` | Times nomeados sorteados por sessão, com `ordem` e `vitorias` consecutivas |
| `partidas` | Partidas com placar, nomes dos times e IDs dos jogadores |

Histórico de migrações relevante (`onUpgrade` em `app_database.dart`):

| Versão | Mudança |
|---|---|
| v5 | Tabela de times nomeados + nomes dos times nas partidas |
| v6 | Coluna de vitórias consecutivas por time (regra "ganhou 2 sai") |
| v7 | **Substitui os 5 atributos numéricos por `nivel` + `papeis`** |
| v8 | `modalidade` (quadra/areia) e `porTime` na sessão |

> A v7 é a razão pela qual `pesoTecnico` não é mais uma média de atributos. Se você encontrar código ou documentação falando de ataque/defesa/bloqueio/saque/passe, está desatualizado.

### Modalidade e tamanho de time

`Sessao.modalidade` (`quadra` / `areia`) combinada com `porTime` define o prefixo dos times via `Sessao.prefixoTime`: areia com `porTime == 2` → "Dupla", areia com outro valor → "Trio", quadra → "Time". Quadra usa tipicamente `porTime == 6`.

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

### Plataforma web e deploy

O app roda em três plataformas: Windows (primária), Android e web. A web é publicada em <https://sportscontrol.vercel.app>.

Dois detalhes que quebram o build web se ignorados:

1. **`web/drift_worker.dart.js` é um artefato compilado**, não escrito à mão. Precisa ser regerado com `dart compile js` sempre que `lib/database/drift_worker.dart` mudar. O workflow de deploy faz isso automaticamente.
2. **`web/vercel.json`** é copiado para `build/web/` pelo `flutter build web` e é de lá que a Vercel o lê. Ele define o rewrite de SPA (toda rota → `/index.html`) e os headers `COOP: same-origin` + `COEP: require-corp`, necessários para `SharedArrayBuffer` — que é o que permite ao `sqlite3.wasm` usar OPFS no navegador. **Não remova esses headers** sem entender que isso derruba a persistência no web.

### Fluxo de branches e CI

```
master   ← produção (deploy --prod + smoke test). Só recebe merge de develop, via PR.
develop  ← integração (deploy de preview). Tire suas branches daqui.
  └── feat/… fix/… ci/… docs/… chore/…
```

Detalhes em [CONTRIBUTING.md](CONTRIBUTING.md). Dois workflows em `.github/workflows/`:

- **`ci.yml`** — em PRs e pushes: verifica se o codegen do Drift está em sincronia (regera e compara), `flutter analyze`, `flutter test`, e formatação como informativo.
- **`deploy-web.yml`** — build web + deploy na Vercel via CLI oficial. Preview em `develop` e PRs; produção só em `master`, com smoke test dos assets principais.

> O deploy usa `npm install --global vercel@latest` em vez de `npx vercel@…` de propósito: o `npx` pode parar para pedir confirmação de instalação e travar o job até o timeout. Há `timeout-minutes` no job por causa disso.

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

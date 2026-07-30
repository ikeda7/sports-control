# Como contribuir no Sports Control

Somos duas pessoas mexendo no mesmo código. Este documento existe para a gente
não pisar no pé do outro — e principalmente para o `master` nunca quebrar, já
que é ele que vai para produção em <https://sportscontrol.vercel.app>.

## Branches

```
master   ← produção. Só recebe merge de develop, via PR. Nunca commite direto.
develop  ← integração. É daqui que você tira branch e é para cá que o PR volta.
  ├── feat/nome-da-funcionalidade
  ├── fix/o-que-conserta
  ├── ci/mudanca-de-pipeline
  ├── docs/o-que-documenta
  └── chore/manutencao
```

Regra curta: **feature sai de `develop` e volta para `develop`**. Quando
`develop` está estável e testado, abre-se um PR `develop → master` e aquilo vai
para produção.

### Por que dois branches

Antes, todo push no `master` disparava deploy em produção direto. Se o build
quebrasse, o site quebrava. Agora:

| Branch | O que acontece no push |
|---|---|
| `feat/*` (em PR) | CI roda + deploy de **preview** com URL própria |
| `develop` | CI roda + deploy de **preview** |
| `master` | CI roda + deploy de **produção** + smoke test |

Você consegue abrir a URL de preview e testar no celular antes de qualquer
coisa chegar em produção.

## Fluxo do dia a dia

```bash
# 1. Sempre comece atualizado a partir de develop
git checkout develop
git pull origin develop

# 2. Crie sua branch
git checkout -b feat/chegada-atrasada

# 3. Trabalhe. Se mexer no schema do banco, é OBRIGATÓRIO regerar:
dart run build_runner build --delete-conflicting-outputs

# 4. Antes de subir, rode o que o CI vai rodar
flutter analyze
flutter test

# 5. Suba e abra o PR contra develop
git push -u origin feat/chegada-atrasada
gh pr create --base develop
```

## Regras de PR

- **Alvo `develop`**, não `master` (exceto o PR de release `develop → master`).
- **Um assunto por PR.** PR pequeno é revisado em 5 minutos; PR gigante fica
  parado uma semana e acumula conflito.
- **CI verde** antes de pedir review.
- Se o PR resolve uma issue, escreva `Closes #12` na descrição. O GitHub fecha
  a issue automaticamente quando o PR é mergeado.
- Prefira **squash merge** para manter o histórico de `develop` legível.

## Evitando conflitos entre nós dois

O que mais gera conflito neste projeto:

1. **`lib/database/app_database.g.dart`** — arquivo gerado, enorme. Se nós dois
   mexermos no schema ao mesmo tempo, o conflito é impossível de resolver na
   mão. **Solução:** não resolva o conflito. Pegue a versão de `develop`, e
   regere:
   ```bash
   git checkout --theirs lib/database/app_database.g.dart
   dart run build_runner build --delete-conflicting-outputs
   ```
2. **`schemaVersion` + `MigrationStrategy`** — se cada um subir uma migração
   com o mesmo número de versão, o banco de quem já tem dados quebra. Avise no
   grupo antes de incrementar o `schemaVersion`.
3. **`lib/signals.dart`** — todo mundo adiciona signal no mesmo arquivo.
   Adicione no fim, não no meio.
4. **`dart format` no repo todo** — 12 dos 19 arquivos em `lib/` não estão
   formatados. Reformatar tudo é um diff que toca quase todo arquivo. Só faça
   isso em PR dedicado, combinado antes, com ninguém com branch aberta.

## Issues: para que servem

Se você nunca usou, a ideia é simples: **uma issue é uma tarefa ou um bug com
endereço fixo**. Em vez de "aquele problema do sorteio que você me falou no
WhatsApp", passa a ser a issue #14, que tem título, descrição, responsável,
histórico de discussão e um link que o PR referencia.

O ganho real para nós:

- **Não se perde.** O `to-do.txt` era uma lista que ninguém sabia quem estava
  fazendo. A issue tem `Assignees`.
- **Dá para dividir trabalho sem conversar.** Você se atribui a #14, eu me
  atribuo a #15, e ninguém escreve o mesmo código duas vezes.
- **O PR fecha a issue.** `Closes #14` no corpo do PR e ela fecha sozinha no
  merge.
- **Vira roadmap.** As issues alimentam o board em *Projects*, com colunas
  `Backlog → Em andamento → Em review → Concluído`.

### Labels

| Label | Quando usar |
|---|---|
| `bug` | Está errado ou quebrado |
| `feature` | Funcionalidade nova |
| `sorteio` | Algoritmo de times, levantadores, rotação |
| `placar` | Partida, pontuação, histórico |
| `banco` | Schema, migração, Drift |
| `ci/deploy` | Pipeline, Vercel, Actions |
| `boa-primeira-tarefa` | Pequena e isolada, boa para pegar embalo |

### Escrevendo uma issue de bug que serve pra algo

O que faltar aqui vira ida e volta no comentário:

1. O que você fez (passos)
2. O que esperava
3. O que aconteceu
4. Onde (Windows desktop, Android, web) e, se for web, a URL

Os templates em `.github/ISSUE_TEMPLATE/` já perguntam isso.

## Ambiente de desenvolvimento

```bash
flutter pub get
flutter run -d windows     # plataforma primária
```

**Windows exige Developer Mode ativado** (`start ms-settings:developers`) —
sem isso o `flutter pub get` falha no fim com "Building with plugins requires
symlink support", porque o Flutter não consegue criar os symlinks dos plugins
nativos.

Depois de qualquer alteração em `lib/database/app_database.dart`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Ou deixe o watcher rodando durante o desenvolvimento:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

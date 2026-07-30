# Rodando o Sports Control localmente

Guia escrito depois de rodar o diagnóstico na máquina do @ikeda7 recém-formatada.
Se você está vendo "um monte de erro" no editor, **o código está bom** — pula
direto para [O ritual de 2 comandos](#o-ritual-de-2-comandos).

---

## TL;DR — o que funciona hoje

```bash
flutter pub get                                    # 1x, ou quando mexer no pubspec
dart run build_runner build --delete-conflicting-outputs   # após mexer no schema
flutter run -d edge                                # ← seu único alvo funcional agora
```

`flutter run -d windows` **não funciona** na máquina do Lucas ainda — falta o
Visual Studio. Detalhes abaixo.

---

## O ritual de 2 comandos

Esta é a causa de 99% dos "mil erros" no editor depois de clonar ou formatar.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

**Por que.** Rodei `flutter analyze` numa cópia limpa e saíram **1555 erros**.
Todos falsos. Sem o `pub get`, o Dart não sabe onde estão os pacotes, então cada
`import` vira `Target of URI doesn't exist` e cascateia para todo símbolo que
veio dele — `Watch`, `signal`, `Value`, `QueryExecutor`, tudo "undefined".

Depois do `pub get`: **1 apontamento**. Depois do PR #7: **zero**.

```
antes:   1555 issues found
depois:  No issues found!
```

Então se o VS Code está vermelho do topo ao rodapé, não é o projeto. É o
`package_config.json` que não existe ainda.

> **Reinicie o analisador do Dart depois do `pub get`.** O VS Code costuma
> segurar o estado antigo. `Ctrl+Shift+P` → *Dart: Restart Analysis Server*.

---

## Diagnóstico da máquina atual (30/07/2026)

Saída real do `flutter doctor -v`:

| Item | Status | O que isso bloqueia |
|---|---|---|
| Flutter 3.41.6 / Dart 3.11.4 | ✅ | — |
| Windows 11 25H2 | ✅ | — |
| **Visual Studio** | ❌ não instalado | **`flutter run -d windows`** |
| **Android SDK** | ❌ não localizado | `flutter run -d android` |
| Chrome | ❌ não encontrado | nada — use Edge |
| Edge 150 | ✅ | **web funciona** |
| Developer Mode | ❌ desligado | final do `flutter pub get` |

Ou seja: dos três alvos do projeto, **só o web está utilizável agora**. E o web
foi testado de ponta a ponta nesta máquina:

```
dart compile js -O2 -o web/drift_worker.dart.js lib/database/drift_worker.dart
→ Compiled 14,780,110 input bytes to 378,435 characters JavaScript in 4.96s

flutter build web --release --dart-define=FLUTTER_WEB_CANVASKIT_URL=/canvaskit/
→ √ Built build\web
```

Funciona. Você consegue trabalhar hoje, sem instalar nada, usando `-d edge`.

---

## Consertando o ambiente, em ordem de retorno

### 1. Developer Mode — 30 segundos, faça agora

```powershell
start ms-settings:developers
```

Ligue **Modo do desenvolvedor**. Sem isso o `flutter pub get` resolve as
dependências e depois falha no fim:

```
Building with plugins requires symlink support.
Please enable Developer Mode in your system settings.
```

O Flutter precisa criar symlinks para os plugins nativos. É chato porque o erro
vem *depois* do sucesso da resolução, então parece que funcionou.

### 2. Visual Studio — para voltar a rodar no Windows desktop

O `CLAUDE.md` chama o Windows de plataforma primária, então vale recuperar.

Baixe o **Visual Studio 2022 Community** (não é o VS Code — é outro produto):
<https://visualstudio.microsoft.com/downloads/>

No instalador, marque a workload **"Desenvolvimento para desktop com C++"** com
os componentes padrão. É o compilador MSVC que o Flutter usa para o alvo
Windows. São uns 7 GB.

Confira depois com:

```bash
flutter doctor
```

### 3. Android SDK — só se você for testar no celular

O caminho mais simples é o **Android Studio**, que instala SDK, platform-tools e
aceita as licenças por você: <https://developer.android.com/studio>

Depois:

```bash
flutter doctor --android-licenses
```

Se já tiver o SDK em outro lugar:

```bash
flutter config --android-sdk "C:\caminho\para\Android\Sdk"
```

### 4. Chrome — opcional

O Edge atende. Se preferir o Chrome, instale e ele é detectado sozinho. Para
apontar manualmente:

```powershell
$env:CHROME_EXECUTABLE = "C:\Program Files\Google\Chrome\Application\chrome.exe"
```

---

## O dia a dia

### Rodar com hot reload

```bash
flutter run -d edge         # web (funciona hoje)
flutter run -d windows      # depois de instalar o Visual Studio
flutter devices             # ver o que está disponível
```

Com o app rodando: `r` faz hot reload, `R` reinicia, `q` sai.

### Antes de abrir PR

Rode o que o CI vai rodar, para não descobrir no GitHub:

```bash
flutter analyze
flutter test
```

### Mexeu no banco?

Qualquer alteração em `lib/database/app_database.dart` **exige** regerar:

```bash
dart run build_runner build --delete-conflicting-outputs
```

E **commite o `.g.dart` gerado** — ele é versionado, e o CI falha se estiver
dessincronizado. Se for mexer bastante no schema, deixe o watcher rodando em
outro terminal:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Build web completo (o que o deploy faz)

O worker do Drift é um artefato compilado à parte. O deploy faz isso
automaticamente, mas localmente você precisa rodar antes:

```bash
dart compile js -O2 -o web/drift_worker.dart.js lib/database/drift_worker.dart
flutter build web --release --dart-define=FLUTTER_WEB_CANVASKIT_URL=/canvaskit/
```

---

## Erros que você vai ver e o que significam

| Mensagem | Tradução |
|---|---|
| `Target of URI doesn't exist` (centenas) | Falta `flutter pub get` |
| `undefined_identifier: Value` em `*.g.dart` | Mesma coisa — é cascata, não bug do codegen |
| `Building with plugins requires symlink support` | Developer Mode desligado |
| `Visual Studio not installed` | Só afeta `-d windows`; web e Android seguem |
| `Unexpected wasm dry run failure (252)` | **Aviso, não erro.** O build JS conclui normal. Silencie com `--no-wasm-dry-run` |
| `Unable to locate Android SDK` | Só afeta `-d android` |
| CI reclamando de codegen desatualizado | Rode o `build_runner` e commite o `.g.dart` |

O `wasm dry run failure` merece destaque: ele aparece **junto de um build que
deu certo**. É o Flutter checando compatibilidade com WebAssembly, que não
usamos. Ignorar.

---

## Estado do projeto

Verificado em 30/07/2026:

- `flutter analyze` → 1 apontamento (corrigido no PR #7, depois fica limpo)
- `flutter test` → passa (só existe um teste placeholder — ver issue #15)
- Codegen do Drift → em sincronia (rodei o `build_runner`, diff vazio)
- Schema → **v8** (`app_database.dart:121`)
- Build web → funciona nesta máquina
- Formatação → 12 de 19 arquivos fora do padrão (ver issue #14)

O projeto está saudável. O que estava quebrado era o deploy e a documentação,
não o código.

---

## Se ainda estiver estranho

Reset limpo:

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

Se o `analyze` voltar limpo depois disso, era cache. Ainda com erro, aí sim vale
abrir issue com a saída colada — tem template pronto em
`.github/ISSUE_TEMPLATE/`.

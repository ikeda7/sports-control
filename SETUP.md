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

Para abrir no **Opera** em vez do Edge, veja
[Navegador](#4-navegador--usando-opera-em-vez-do-edge) — resumo:

```powershell
$env:CHROME_EXECUTABLE = "C:\Users\Lucas\AppData\Local\Programs\Opera GX\opera.exe"
flutter run -d chrome
```

`flutter run -d windows` **não funciona** na máquina do Lucas ainda — falta o
Visual Studio. Detalhes abaixo.

> **Scripts `.sh` no Windows:** use o **Git Bash**, não o `bash` do PATH — este
> aponta para o WSL. Ver [Rodando scripts .sh](#rodando-scripts-sh-no-windows).

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

### 1. Developer Mode — 30 segundos

**O que é esse `start ms-settings:developers`?** É só um atalho para abrir uma
tela das Configurações do Windows. Não instala nada, não roda script. O
`ms-settings:` é um esquema de URL do Windows, igual `https:` mas para abrir
telas de configuração.

**Como usar:** aperte `Win + R`, cole `ms-settings:developers` e dê Enter.
(No PowerShell ou no cmd, o comando é `start ms-settings:developers`.)

Vai abrir **Configurações → Sistema → Para desenvolvedores**. Ligue a chave
**"Modo do desenvolvedor"** e confirme no aviso que aparece.

Se preferir clicar: *Configurações → Sistema → Para desenvolvedores*.

**Por quê.** Sem isso o `flutter pub get` resolve as dependências e depois falha
no final:

```
Building with plugins requires symlink support.
Please enable Developer Mode in your system settings.
```

O Flutter cria *symlinks* (atalhos de sistema) para os plugins nativos, e o
Windows só permite isso sem privilégio de administrador com o Modo do
desenvolvedor ligado. É confuso porque o erro vem **depois** de tudo parecer ter
dado certo.

> **Não é bloqueante para trabalhar no web.** Verificado nesta máquina: mesmo com
> esse erro no fim do `pub get`, o `flutter analyze` e o `flutter build web`
> funcionaram. Ligar o Modo do desenvolvedor só elimina o erro e é pré-requisito
> para o alvo Windows depois que você instalar o Visual Studio.

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

### 4. Navegador — usando Opera em vez do Edge

O Flutter não tem um device `opera`. Os alvos web são `chrome`, `edge` e
`web-server`. Mas o Opera é Chromium por baixo, então dá para usá-lo de duas
formas.

#### Opção A — apontar o device `chrome` para o Opera (hot reload funciona)

O device `chrome` do Flutter usa a variável `CHROME_EXECUTABLE`. Aponte para o
Opera e rode com `-d chrome`:

```powershell
$env:CHROME_EXECUTABLE = "C:\Users\Lucas\AppData\Local\Programs\Opera GX\opera.exe"
flutter run -d chrome
```

Verificado nesta máquina — com a variável definida, o `flutter devices` passa a
listar:

```
Chrome (web)  • chrome  • web-javascript • unknown
```

O `unknown` na versão é normal: o Flutter não sabe ler a versão do Opera, mas
lança o navegador normalmente.

**Para não repetir isso a cada terminal**, defina de forma permanente (uma vez
só, depois reabra o terminal):

```powershell
[Environment]::SetEnvironmentVariable(
  "CHROME_EXECUTABLE",
  "C:\Users\Lucas\AppData\Local\Programs\Opera GX\opera.exe",
  "User")
```

> Se você usa o Opera normal (não GX), o caminho costuma ser
> `%LOCALAPPDATA%\Programs\Opera\opera.exe`. Confirme com:
> `Get-ChildItem "$env:LOCALAPPDATA\Programs" -Filter opera.exe -Recurse -Depth 2`

**Ressalva honesta:** o hot reload e o debug do Flutter conversam com o navegador
pelo protocolo DevTools do Chromium. No Opera isso geralmente funciona, mas não
é combinação testada pelo time do Flutter — se o hot reload começar a engasgar,
use a opção B ou volte para o Edge (`-d edge`), que é suportado oficialmente.

#### Opção B — `web-server` e abrir no navegador que quiser

O caminho mais robusto. O Flutter não abre navegador nenhum, só serve e te dá a
URL:

```bash
flutter run -d web-server
```

Ele imprime algo como `http://localhost:PORTA`. Cole no Opera. Funciona em
qualquer navegador, sem variável de ambiente.

O custo é que o hot reload por atalho de teclado não é automático — você aperta
`r` no terminal e dá F5 na aba. Para trabalhar em UI o dia todo, a opção A é mais
confortável; para só conferir algo, a B resolve.

#### Se quiser o Chrome de verdade

Instale e o Flutter detecta sozinho — mas aí **remova** o `CHROME_EXECUTABLE`,
senão ele continua abrindo o Opera:

```powershell
[Environment]::SetEnvironmentVariable("CHROME_EXECUTABLE", $null, "User")
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

## Rodando scripts `.sh` no Windows

Se você rodar um script do repo e ver isto:

```
C:\...\sportscontrol>bash scripts/setup-roadmap.sh
<3>WSL (9 - Relay) ERROR: CreateProcessCommon:818: execvpe(/bin/bash) failed: No such file or directory
```

O problema não é o script. É que `bash` no PATH do Windows resolve para
`C:\WINDOWS\system32\bash.exe`, que é o **atalho do WSL** — e o WSL não tem
distro/bash instalado nesta máquina. Ele tenta executar `/bin/bash` dentro de um
Linux que não existe.

**Solução:** use o Git Bash, que está instalado:

```powershell
& "C:\Program Files\Git\bin\bash.exe" scripts/setup-roadmap.sh
```

Ou abra o **Git Bash** pelo menu Iniciar, navegue até o projeto e rode
`bash scripts/setup-roadmap.sh` normalmente — lá o `bash` é o do Git.

> **No caso específico do `setup-roadmap.sh`, você não precisa rodar.** O board
> já foi criado e as issues já estão nele:
> <https://github.com/users/ikeda7/projects/3>. O script é idempotente e serve
> para, mais tarde, jogar issues novas no board de uma vez.

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
| `WSL ... execvpe(/bin/bash) failed` | `bash` está caindo no WSL. Use o Git Bash — ver seção acima |
| `flutter run -d opera` → device não encontrado | Não existe device `opera`. Use `-d chrome` com `CHROME_EXECUTABLE`, ou `-d web-server` |

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

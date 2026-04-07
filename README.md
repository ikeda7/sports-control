# SportsControl

Gerenciador de rachões esportivos para vôlei. Controla jogadores, check-in de presença, sorteio equilibrado de times e placar em tempo real.

## Plataformas

- **Windows** (primária) — desktop
- **Android** — mobile

## Funcionalidades

- Cadastro de jogadores com atributos individuais (ataque, defesa, bloqueio, saque, passe — 1 a 5 estrelas)
- Check-in de presença por sessão de rachão
- Sorteio automático equilibrado por peso técnico (snake-draft ABBA)
- Substituição de jogadores ausentes com sugestão por rodízio
- Placar em tempo real com histórico de partidas
- Persistência local com SQLite (dados sobrevivem a reinicializações)

## Stack

| Camada | Tecnologia |
|---|---|
| UI | Flutter + Material 3 (dark theme + glassmorphism) |
| Reatividade | `signals_flutter` |
| Banco de dados | `drift` (SQLite) |

## Desenvolvimento

```bash
# Windows
flutter run -d windows

# Android
flutter run -d android

# Gerar código do Drift após alterar o schema
dart run build_runner build --delete-conflicting-outputs
```

> **Windows**: requer Developer Mode ativado (`start ms-settings:developers`).

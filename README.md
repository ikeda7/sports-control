# SportsControl

Gerenciador de rachões de vôlei. Controla jogadores, check-in, sorteio equilibrado de times com regras de rotação e placar em tempo real.

## Plataformas

- **Windows** (primária) — desktop
- **Android** — mobile

## Funcionalidades

### Jogadores
- Cadastro com atributos individuais (ataque, defesa, bloqueio, saque, passe — 1 a 5 estrelas)
- Flag de **levantador fixo** (sistema 6x0)
- Importar lista de nomes colada (formato WhatsApp, numerada ou um nome por linha)
- Dados de teste com 22 jogadores genéricos (sem duplicatas)

### Check-in
- Sessão por rachão — todos os jogadores entram pré-selecionados
- Marcar/desmarcar presença individualmente ou com "Todos / Nenhum"
- Encerrar rachão manualmente; sessões de dias anteriores são encerradas automaticamente ao abrir o app

### Sorteio
- Snake-draft equilibrado por peso técnico
- **Garante 1 levantador por time** — rotaciona pelos que jogaram menos
- **Garante 1 mulher por time** — avisa se jogadoras forem insuficientes
- Substituição com sugestão por atributos + menos partidas jogadas; se banco vazio, usa empréstimo de qualquer jogador cadastrado
- Re-sortear com confirmação

### Rotação ("ganhou 2 sai")
- Time vencedor acumula vitórias consecutivas (badge 🏅 1/2 no card)
- Ao ganhar 2 seguidas: ambos os times saem da quadra (vitórias resetam)
- Card **"Próxima Partida Recomendada"** sempre visível: defensor (1 vitória) vs time com menos jogos totais

### Placar
- Incrementar/decrementar pontos em tempo real
- Encerrar partida: incrementa `partidasJogadas` de todos os participantes e atualiza vitórias dos times
- Aviso quando placar estiver empatado (vitórias não são atualizadas)
- Histórico de partidas encerradas na mesma sessão

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

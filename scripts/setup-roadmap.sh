#!/usr/bin/env bash
#
# Cria o board de roadmap em GitHub Projects e adiciona as issues abertas.
#
# Por que isso é um script e não já está feito: criar Projects pela API exige o
# escopo `project` no token do gh, que precisa de um fluxo OAuth interativo no
# navegador. Rode você mesmo:
#
#   gh auth refresh -s project,read:project
#   bash scripts/setup-roadmap.sh
#
# Idempotente: se o projeto com o mesmo título já existir, reaproveita.

set -euo pipefail

OWNER="ikeda7"
REPO="ikeda7/sports-control"
TITULO="Sports Control — Roadmap"

if ! gh project list --owner "$OWNER" >/dev/null 2>&1; then
  echo "ERRO: o token do gh não tem o escopo necessário." >&2
  echo "Rode primeiro:  gh auth refresh -s project,read:project" >&2
  exit 1
fi

echo "==> Procurando projeto \"$TITULO\""
# --jq é o jq embutido no próprio gh, então não depende de jq instalado.
NUM=$(gh project list --owner "$OWNER" --format json \
        --jq ".projects[] | select(.title == \"$TITULO\") | .number" 2>/dev/null | head -1)

if [ -z "${NUM:-}" ]; then
  echo "==> Criando projeto"
  NUM=$(gh project create --owner "$OWNER" --title "$TITULO" --format json \
          --jq '.number')
  echo "    projeto #$NUM criado"
else
  echo "    projeto #$NUM já existe, reaproveitando"
fi

echo "==> Adicionando issues abertas ao board"
ADICIONADAS=0
while read -r URL; do
  [ -z "$URL" ] && continue
  if gh project item-add "$NUM" --owner "$OWNER" --url "$URL" >/dev/null 2>&1; then
    echo "    + $URL"
    ADICIONADAS=$((ADICIONADAS + 1))
  else
    echo "    = $URL (já estava no board)"
  fi
done < <(gh issue list --repo "$REPO" --state open --limit 100 \
           --json url --jq '.[].url')

echo
echo "Pronto. $ADICIONADAS issue(s) adicionada(s)."
echo "Board: https://github.com/users/$OWNER/projects/$NUM"
echo
echo "Ajustes que valem fazer na interface (uma vez só):"
echo "  1. Trocar a view para 'Board' e usar o campo Status como colunas"
echo "  2. Renomear as colunas para: Backlog / Em andamento / Em review / Concluído"
echo "  3. Settings > Workflows: ativar 'Item closed -> Concluído' e"
echo "     'Pull request merged -> Concluído' para o board se mover sozinho"
echo "  4. Adicionar um campo 'Prioridade' (single select: Alta/Média/Baixa)"

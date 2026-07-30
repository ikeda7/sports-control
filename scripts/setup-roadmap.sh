#!/usr/bin/env bash
#
# Cria o board de roadmap em GitHub Projects e adiciona as issues abertas.
#
# O board já foi criado: https://github.com/users/ikeda7/projects/3
# Este script serve para, mais tarde, jogar issues novas no board de uma vez.
#
# Requer o escopo `project` no token do gh (fluxo OAuth no navegador):
#
#   gh auth refresh -s project,read:project
#
# NO WINDOWS, use o Git Bash. O `bash` do PATH aponta para o WSL e falha com
# "execvpe(/bin/bash) failed: No such file or directory" se não houver distro:
#
#   & "C:\Program Files\Git\bin\bash.exe" scripts/setup-roadmap.sh
#
# No Git Bash ou no Linux/macOS:
#
#   bash scripts/setup-roadmap.sh
#
# Idempotente: se o projeto com o mesmo título já existir, reaproveita, e issues
# que já estão no board não são duplicadas.

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

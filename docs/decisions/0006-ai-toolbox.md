# ADR-0006 — Integração do AI Toolbox (governance-core)

Status: **aceito**

## Contexto

O dono mantém `thijulio/thijulio-ai-toolbox` (repo de assets reutilizáveis: agents,
skills, references, plugins). O único plugin publicado hoje é `@thijulio/governance-core`
(revisão de governança read-only).

## Decisão

- Instalar o plugin no projeto via `governance-core install --project .` → escreve em
  `.agent-toolbox/` (`.agent-toolbox/installed/` é gitignored; `install-lock.json` é commitado).
- Registrar o plugin local no host (Claude Code / Codex) separadamente, conforme docs do toolbox.
- Roteamento em `AGENTS.md` → toolbox. Não copiar assets do toolbox para o projeto.

## Consequências

- Painter Studio ganha revisão de governança read-only.
- Novos agents/skills/references entram um a um (mesmo fluxo), não em lote.

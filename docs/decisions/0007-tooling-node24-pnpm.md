# ADR-0007 — Baseline de tooling: Node 24 + pnpm 10 + @thijulio

Status: **aceito**

## Contexto

Padrão da casa (`thijulio/dev-tooling`): Node 24 + pnpm para repositórios novos.
Configs de lint/tsconfig/prettier vivem em `@thijulio/*` (GitHub Packages).

## Decisão

- `.nvmrc` = 24; `packageManager` = pnpm@10.25.0; `engines.node` = >=24.
- Consumir `@thijulio/eslint-config`, `@thijulio/tsconfig`, `@thijulio/prettier-config`
  quando publicadas (mesmo escopo/registro do `.npmrc`).

## Consequências

- Consistência com design-systems e website.
- Pendência: configs do dev-tooling ainda não publicadas → scaffold local temporário,
  sem bloquear a Fase 0.

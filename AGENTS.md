# Painter Studio — Agentes & Guia

> Leia isto primeiro. Fonte de verdade de como o projeto é construído e das
> decisões que o regem. Estado vivo: `memory.md`. Plano: `docs/plan.md`.

## O que é

Assistente de pintura multi-plataforma (Android/iOS/Web+Desktop via Expo) com
análise de cor, tamanho de tela, grelha, impressão A4, roda de cores, inventário
de tintas e misturas.

## Stack (travada — não reabrir sem ADR)

- **App:** Expo + Expo Router (TypeScript), uma base p/ mobile + web/desktop (PWA).
- **Design system:** **Biome Modernism** (marca pessoal) — consumimos `@thijulio/biome-tokens`
  via GitHub Packages. Nunca copiar hex/tokens para o código; importar do pacote.
  `biome-react` é CSS Modules (web-only) e **não** é usado no Expo.
- **AI Toolbox:** consumimos o plugin `@thijulio/governance-core` (instala em `.agent-toolbox/`).
- **Auth/Imagens/Banco:** Netlify Identity (Google) · AWS S3 · Supabase.
- **Tooling:** Node 24 + pnpm 10 + **Nx 23**. Configs (`@thijulio/eslint-config`, `@thijulio/tsconfig`,
  `@thijulio/prettier-config`) vêm do repo `thijulio/dev-tooling` (ainda não publicadas, v0.0.1).

## Layout (resumo)

```
apps/mobile/        Expo SDK 57 (rotas em src/app/, domínios em src/features/, tema em src/theme/)
apps/desktop/       shell Electron/Tauri (opcional, Fase 6)
functions/          Netlify Functions (API)
libs/               shared/ (color-engine, grid-engine, types, api-client) · frontend/ui
infra/              s3 · netlify · database
docs/               plano, arquitetura, benchmark, spec, ADRs
.agent-toolbox/     instalado pelo AI Toolbox (gerado; ver README interno)
```

## Regras de ouro

- **Tokens vêm do design system**, nunca hardcode de cor no app. Adapter em
  `apps/mobile/src/theme/tokens.ts`.
- **Lógica de domínio** (cor, grelha, mistura) vive em `libs/shared/*` puros e testáveis —
  nunca dentro de componentes.
- **Uma feature por pasta** em `apps/mobile/src/features/*`.
- **Conventional Commits.** Node 24 + pnpm 10 (não usar npm/yarn).

## Roteamento (subsistemas)

- Design system: repo `thijulio/design-systems` (local `~/development/design-systems`).
- AI Toolbox: repo `thijulio/thijulio-ai-toolbox` (local `~/development/thijulio-ai-toolbox`).
- ADRs: `docs/decisions/`.

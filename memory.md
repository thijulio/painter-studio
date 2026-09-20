# Painter Studio — Memória / Handover

> Para retomar: leia isto + `AGENTS.md` + `docs/plan.md`.

## 🚀 Handover — onde paramos

- **Repo:** https://github.com/thijulio/painter-studio (privado, `main`, tudo commitado/pushado).
- **Base pronta (Fase 0):** Nx 23 + Expo SDK 57 + design system Biome + AI Toolbox + tema (cores) conectado.
- **Roda:** typecheck ✅ · build web ✅ · dev server ✅ (http://localhost:8081).
- **PARADO em:** deploy no Netlify — **ação manual do dono** (sem acesso à conta Netlify).

## ⏭️ Próximo passo imediato (ação do dono)

1. Netlify → "Add new site → Import an existing project" → GitHub → `thijulio/painter-studio`.
2. *Site settings → Environment variables* → adicionar `NODE_AUTH_TOKEN` = saída de `gh auth token`.
3. Deploy. Guia completo: `docs/deploy-netlify.md`.

Depois: domínio custom `*.thijulio.com` (CNAME no Route53) → só então complexificar (Fase 1: auth Google + S3).

## Estado atual

- **Fase 0 concluída:** `git init` (branch main) + scaffold Expo SDK 57 em `apps/mobile`
  (React 19, RN 0.86, TS 6) + monorepo validado (`pnpm-lock.yaml` gerado, 581 pacotes).
- Netlify: `netlify.toml` (build web + functions) + `functions/hello.js` (smoke-test).
- Plano, arquitetura, benchmark e spec em `docs/`.
- Decidido: design system **Biome Modernism** (tokens) + AI Toolbox (**governance-core**).
- Tooling: Node 24 + pnpm 10 + **Nx 23** (padrão PMP/design-systems); monorepo com `apps/` + `libs/` + `functions/`.
- **Repo GitHub:** https://github.com/thijulio/painter-studio (privado) — commit inicial `5741282` pushado.
- **Roda:** `expo export --platform web` (build) passa → gera `apps/mobile/dist/`.

## Status dos pacotes @thijulio (verificado)

- **Design system (`@thijulio/biome-tokens` etc.): PUBLICADO em 0.0.2** (git tags
  `biome-tokens@0.0.2`, commit "mark packages published at 0.0.2"). Consumir via
  `@thijulio:registry=https://npm.pkg.github.com`. Auth local vem do `~/.npmrc` global
  (`_authToken=${NODE_AUTH_TOKEN}`, setado no `~/.zshrc` via `gh` keyring).
- **dev-tooling (`@thijulio/eslint-config`, `@thijulio/tsconfig`, `@thijulio/prettier-config`):
  ainda NÃO publicadas** (v0.0.1, sem release tags).

## Pendências / bloqueios

- **Cores já conectadas** aos tokens Biome (`src/theme/tokens.ts` → `src/constants/theme.ts`), typecheck ok.
  **Fontes e espaçamento** ainda usam o padrão do template (follow-up: expo-google-fonts + escala Biome).
- `@thijulio/governance-core` v0.1.0 é o único plugin do AI Toolbox (`agents/`, `skills/`,
  `references/` no repo ainda vazios).

## Próximos passos (prioridade: rodar → depois complexificar)

1. ✅ Commit inicial + repo no GitHub (thijulio/painter-studio).
2. ✅ Build web passa (`expo export --platform web`).
3. ✅ Dev server roda (http://localhost:8081) e tema Biome aplicado.
4. ⏭️ **Deploy no Netlify** — ação do dono (ver Handover acima + `docs/deploy-netlify.md`).
5. ⏭️ Domínio custom `*.thijulio.com` (CNAME no Route53).
6. ⏭️ Instalar `@thijulio/governance-core` (`.agent-toolbox/`).
7. ⏳ DEPOIS (complexificar): Fase 1 — auth Google + upload S3.

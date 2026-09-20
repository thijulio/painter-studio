# Painter Studio — Memória (estado vivo)

## Estado atual

- **Fase 0 concluída:** `git init` (branch main) + scaffold Expo SDK 57 em `apps/mobile`
  (React 19, RN 0.86, TS 6) + monorepo validado (`pnpm-lock.yaml` gerado, 581 pacotes).
- Netlify: `netlify.toml` (build web + functions) + `functions/hello.js` (smoke-test).
- Plano, arquitetura, benchmark e spec em `docs/`.
- Decidido: design system **Biome Modernism** (tokens) + AI Toolbox (**governance-core**).
- Tooling: Node 24 + pnpm 10 + **Nx 23** (padrão PMP/design-systems); monorepo com `apps/` + `libs/` + `functions/`.

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

## Próximos passos

1. Validar stack + nome com o dono.
2. ✅ `pnpm install` feito; rodar `pnpm dev:web` para ver o app com as cores Biome.
3. ✅ Conectar o tema aos tokens Biome (adapter `src/theme/tokens.ts` + `src/constants/theme.ts`).
4. Instalar `@thijulio/governance-core` no projeto (`.agent-toolbox/`).
5. Começar Fase 1 (auth Google + upload S3).

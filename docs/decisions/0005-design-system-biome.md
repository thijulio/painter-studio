# ADR-0005 — Design system: Biome Modernism (tokens)

Status: **aceito**

## Contexto

O dono mantém um design system próprio (repo `thijulio/design-systems`, Nx monorepo)
com duas marcas: **Biome Modernism** (pessoal) e **Exodus** (trabalho). Painter Studio
é um projeto pessoal.

## Decisão

- Usar **Biome Modernism** como fonte de verdade visual.
- Consumir **apenas** `@thijulio/biome-tokens` (objetos JS/TS — o caminho "drop-in"
  para React Native), mapeado em `apps/mobile/src/theme/tokens.ts`.
- **Não** consumir `@thijulio/biome-react` no Expo (é CSS Modules, web-only).
- Nunca copiar hex/tokens; importar do pacote (`.npmrc` aponta `@thijulio` → GitHub Packages).

## Consequências

- Visual consistente com o site pessoal (Biome).
- Consumo via `@thijulio/biome-tokens@^0.0.2` (publicado; auth via `NODE_AUTH_TOKEN` no zsh).
- Dark mode no RN exige exportar os valores dark como JS no DS (follow-up lá).

# apps/mobile — Expo (React Native)

App **Painter Studio** — Expo SDK 57 + Expo Router (TypeScript). Uma base para
**Android**, **iOS** e **Web** (PWA/desktop via Netlify).

## Estrutura

```
src/app/          rotas (Expo Router) — _layout.tsx, index.tsx, explore.tsx
src/features/     um módulo por domínio (auth, analyze, grid, color-wheel, inventory, palette, mixing)
src/components/   UI compartilhada (template: themed-text, app-tabs, etc.)
src/constants/    theme.ts (cores/tipografia/spacing do template)
src/hooks/        use-color-scheme, use-theme
src/theme/        adapter do design system (tokens.ts → Biome Modernism)
src/stores/       estado global (a definir)
src/lib/          utilitários
assets/           ícones/imagens
```

## Design system

O tema do app vem do **Biome Modernism** (`@thijulio/biome-tokens`), mapeado em
`src/theme/tokens.ts` (ADR-0005). As **cores** (light/dark) de `src/constants/theme.ts`
já vêm dos tokens do design system — **não hardcodar cor nova.**

- ✅ Cores → tokens Biome (light/dark).
- ⏳ Fontes e espaçamento → migrar para a escala/fontes do Biome (follow-up; fontes
  precisam ser carregadas via expo-google-fonts).

## Rodar

```bash
# da raiz do monorepo:
pnpm install
pnpm dev:mobile   # Expo (mobile)
pnpm dev:web      # Expo web
# build web (export estático p/ Netlify):
pnpm --filter @painter-studio/mobile build
```

## Nota (template)

Scaffold gerado com o template "default" do Expo (SDK 57, React 19, RN 0.86, TS 6).
`AGENTS.md`/`CLAUDE.md` locais apontam para a doc versionada
(https://docs.expo.dev/versions/v57.0.0/). As rotas de demonstração (`index`, `explore`)
serão substituídas pelas telas do produto nas fases 1–5.

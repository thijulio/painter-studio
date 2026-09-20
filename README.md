# Painter Studio 🎨

Aplicativo de apoio ao pintor: análise de cor da imagem, sugestão de tamanho de tela, 
grelha (quadrícula) de referência, divisão para impressão em A4 (papel carbono), roda de 
cores, inventário de tintas e sugestão de misturas.

> **Status:** fase de planejamento — estrutura de pastas + plano + benchmark. Nenhum código de app ainda.

## Plataformas

- 📱 **Android e iOS** — React Native (Expo)
- 🖥️ **Desktop e Web** — mesma base via *react-native-web* (PWA no Netlify); shell Electron opcional em `apps/desktop`

## Stack

| Camada | Escolha |
| --- | --- |
| App (mobile/web) | Expo + Expo Router (TypeScript) |
| Desktop | PWA (Netlify) + Electron opcional |
| Backend / API | Netlify Functions (serverless) |
| Auth | Netlify Identity + Google OAuth |
| Imagens | AWS S3 (upload pré-assinado) |
| Banco (inventário) | Supabase (Postgres) |
| Monorepo | pnpm workspaces + Turborepo |

## Estrutura

```
painter-studio/
├── apps/
│   ├── mobile/        # Expo: iOS + Android + Web (PWA/desktop)
│   └── desktop/       # shell Electron (opcional)
├── functions/         # Netlify Functions (API serverless)
├── libs/              # código compartilhado (shared/* + frontend/ui)
├── infra/             # S3, Netlify, banco (IaC)
└── docs/              # plano, arquitetura, benchmark
```

## Documentação

- [`docs/plan.md`](docs/plan.md) — plano e fases de entrega
- [`docs/architecture.md`](docs/architecture.md) — arquitetura e fluxos
- [`docs/benchmark.md`](docs/benchmark.md) — benchmark de mercado
- [`docs/product-spec.md`](docs/product-spec.md) — especificação funcional

## Design System (Biome Modernism)

O visual vem do design system pessoal do dono ([`thijulio/design-systems`](https://github.com/thijulio/design-systems)), marca **Biome Modernism**:

- Consumimos `@thijulio/biome-tokens` (objetos JS/TS) e mapeamos para o tema RN em `apps/mobile/src/theme/tokens.ts`.
- `.npmrc` já aponta o escopo `@thijulio` para GitHub Packages.
- `@thijulio/biome-react` (CSS Modules, web-only) **não** é usado no Expo.

## AI Toolbox

O projeto consome o [thijulio-ai-toolbox](https://github.com/thijulio/thijulio-ai-toolbox) — hoje o plugin `@thijulio/governance-core` (revisão de governança read-only), instalado em `.agent-toolbox/`. Ver `.agent-toolbox/README.md`.

## Começando

O app (Expo) já está scaffoldado em `apps/mobile`. Requisitos: Node 24 + pnpm 10.

```bash
pnpm install          # instala as dependências (gera node_modules; lockfile já existe)
pnpm dev:mobile       # roda o Expo (mobile)
pnpm dev:web          # roda a versão web
pnpm --filter @painter-studio/mobile build   # build web (export estático p/ Netlify)
```

Netlify: `netlify.toml` na raiz (build web + functions em `functions/`).

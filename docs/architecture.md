# Arquitetura — Painter Studio

## 1. Visão geral

```
                     ┌────────────────────────────┐
  Android / iOS ───► │  apps/mobile (Expo/RN)     │
  Web / Desktop ───► │  Expo Router + react-native-web │
                     └─────────────┬──────────────┘
                                   │ api-client (tipado)
                                   ▼
                     ┌────────────────────────────┐
                     │  functions/ (Netlify Fns)  │
                     │  auth · storage · color-   │
                     │  analysis · grid ·         │
                     │  inventory · mixing        │
                     └───┬──────────┬──────────┬──┘
                         │          │          │
                   Netlify      AWS S3    Supabase
                   Identity    (imagens)  (Postgres)

   libs/  ──► shared/color-engine · shared/grid-engine · shared/types · shared/api-client · frontend/ui
```

## 2. Componentes

### apps/mobile (Expo)
- **Expo Router** para navegação por arquivos (`app/`).
- `src/features/*` — uma pasta por domínio (auth, analyze, grid, color-wheel, inventory, palette, mixing).
- `src/stores` — estado global (Zustand) para sessão, inventário e imagem atual.
- `src/theme` — tokens de cor/espaço/tipografia.
- Build web via `expo export --platform web` → deploy Netlify (PWA).

### apps/desktop (opcional)
- Shell Electron que carrega o build web. Só se precisarmos de FS local/impressão nativa.

### functions/ (Netlify Functions)
| Pasta | Responsabilidade |
| --- | --- |
| `auth` | valida sessão Netlify Identity; token de acesso |
| `storage` | gera URL pré-assinada de upload/download no S3 |
| `color-analysis` | extração de paleta (sharp) quando cliente não basta |
| `grid` | gera PDF A4 (tiling) com a grelha em escala |
| `inventory` | CRUD de tintas (Supabase) |
| `mixing` | receitas de mistura (delta-E + optimização) |

### libs/
| Pacote | Conteúdo |
| --- | --- |
| `shared/color-engine` | conversões (RGB/HSL/Lab), delta-E (CIEDE2000), extração/quantização, harmonias, mistura |
| `shared/grid-engine` | proporção → tamanhos de tela padrão, cálculo da grelha, tiling A4 (mm) |
| `shared/types` | tipos compartilhados: `Paint`, `Palette`, `MixRecipe`, `Image`, `User` |
| `shared/api-client` | cliente tipado para as functions |
| `frontend/ui` | componentes visuais compartilhados (ColorSwatch, Wheel, GridOverlay) |
### infra/
- `s3/` — bucket (privado, com lifecycle), política de CORS.
- `netlify/` — `netlify.toml`, redirects, variáveis de ambiente.
- `database/` — schema Supabase + migrations.

## 3. Fluxos principais

### 3.1 Auth (Google via Netlify Identity)
1. App abre sessão via `netlify-identity-widget`/`gotrue-js` (web) ou OAuth (mobile).
2. Netlify Identity faz o fluxo Google OAuth e devolve `user` + `token`.
3. O app anexa o token em toda chamada a `functions/*`; `auth` valida no servidor.

### 3.2 Upload de imagem (S3)
1. Cliente chama `functions/storage` → recebe **URL pré-assinada** (PUT).
2. Cliente faz upload direto para o S3 (sem passar pelo servidor).
3. Metadados (key, dono, dimensões) ficam no Supabase.
4. Download/leitura usa URL pré-assinada (GET) ou CloudFront se precisar de cache.

### 3.3 Análise de cor
- **MVP (cliente):** decodifica a imagem, reduz (quantização) e extrai as N cores dominantes via `color-engine`.
- **Servidor (opcional):** `functions/color-analysis` usa `sharp` para downscale + `extract`/quantização, retornando hex + nome + proporção.

### 3.4 Grelha + tiling A4
1. Usuário escolhe tamanho de tela (ou aceita sugestão do `grid-engine`).
2. `grid-engine` calcula a grelha (linhas x colunas) sobre a imagem.
3. `functions/grid` gera um **PDF em folhas A4**, cada folha com a parte correspondente da imagem **na escala real** da tela + marcas de corte/registro.
4. Usuário imprime, alinha com papel carbono e transfere para a tela.

### 3.5 Mistura de tintas
1. Usuário seleciona uma cor-alvo (na roda ou na paleta da imagem).
2. `mixing` lê o inventário (Supabase) e resolve a combinação que minimiza o delta-E contra o alvo.
3. Retorna receita: tintas + proporções aproximadas.

## 4. Modelo de dados (esboço)

```
User(id, email, name)
Image(id, userId, s3Key, width, height, createdAt)
Paint(id, userId, name, brand, colorHex, family, medium, opacity)
Palette(id, userId, name, sourceImageId?)
PaletteItem(paletteId, paintId, colorHex)
MixRecipe(id, userId, targetHex, recipeJson)
CanvasSize(id, label, widthMm, heightMm, ratio)
```

## 5. Decisões registradas (ver `docs/decisions/`)

- ADR-001: Monorepo pnpm + Turborepo.
- ADR-002: Expo como base única (mobile + web), PWA p/ desktop.
- ADR-003: Netlify Identity (Google) + S3 + Supabase.
- ADR-004: Lógica de cor/grelha em packages puros (testáveis).
- ADR-005: Design system = Biome Modernism (tokens).
- ADR-006: AI Toolbox = plugin governance-core.
- ADR-007: Tooling Node 24 + pnpm 10 + @thijulio.

## 6. Design System (Biome Modernism)

- **Fonte de verdade visual:** `@thijulio/biome-tokens` (repo `thijulio/design-systems`).
- **Pipeline:** Style Dictionary (JSON) → `tokens.js`/`tokens.d.ts` + `tokens.css`. O `.js` é o caminho RN.
- **No app:** `apps/mobile/src/theme/tokens.ts` reexporta/mapa tokens (cor, spacing, tipografia, motion) para o tema RN.
- **`biome-react` não usado** (CSS Modules web-only; o Expo usa react-native-web).
- **Dark mode:** base (light) vem no `.js`; dark é overlay CSS no DS → exportar JS do dark é follow-up no DS.

## 7. AI Toolbox

- Consumimos `@thijulio/governance-core` (plugin read-only de governança) do repo `thijulio/thijulio-ai-toolbox`.
- Instala em `.agent-toolbox/installed/governance-core/` + `install-lock.json` (commitado).
- Plugin registrado no host (Claude Code / Codex) separadamente.
- Novos agents/skills/references entram um a um (não em lote).

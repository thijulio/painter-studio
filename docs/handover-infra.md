# Handover — Provisionamento de Infraestrutura (para agente de IA)

> **Brief agnóstico de agente.** Pode ser entregue a qualquer agente (Codex,
> Claude Code, Cursor, etc.) — sem dependência do agente anterior.
> **Objetivo:** sair do estado "Fase 0 local" para **deploy + auth + storage +
> banco**, provisionando as contas e configurações de nuvem do Painter Studio.

---

## 1. Missão

Criar e configurar os serviços abaixo e deixar o projeto pronto para:

1. **Deploy no Netlify** (web + functions).
2. **Fase 1** do plano (`docs/plan.md`): login Google + upload de imagem no S3.
3. **Base de dados** pronta para inventário de tintas / paletas / misturas (fases 5–6).

---

## 2. Contexto do projeto

- **O que é:** app multi-plataforma (Expo) de apoio ao pintor — análise de cor da
  imagem, tamanho de tela, grelha, impressão A4 (papel carbono), roda de cores,
  inventário de tintas e misturas.
- **Repo:** `https://github.com/thijulio/painter-studio` (privado, branch `main`).
- **Stack (travada, não reabrir sem ADR):** Expo SDK 57 (React 19, RN 0.86, TS 6) +
  Expo Router · Nx 23 · pnpm 10 · Node 24 · Netlify (host + functions + Identity) ·
  **Neon Postgres** · **AWS S3** (imagens).
- **Design system:** `@thijulio/biome-tokens` (GitHub Packages, repo
  `thijulio/design-systems`). **AI Toolbox:** `@thijulio/governance-core`
  (repo `thijulio/thijulio-ai-toolbox`).
- **Estado atual:** Fase 0 concluída — scaffold, `pnpm typecheck` ✅, build web ✅
  (`apps/mobile/dist`), dev server ✅ (http://localhost:8081), tema Biome conectado.
- **Infra provisionada em 2026-09-26:** Netlify, Neon e S3 estão configurados;
  Netlify Identity usa o provider Google padrão. O wiring no app Expo continua
  sendo trabalho da Fase 1.

---

## 3. Onde as coisas vivem (cite estas pastas)

| Caminho | Conteúdo |
| --- | --- |
| `apps/mobile/` | App Expo (rotas `src/app/`, features `src/features/`, tema `src/theme/`) |
| `functions/` | Netlify Functions (auth · storage · color-analysis · grid · inventory · mixing) |
| `libs/shared/` | Lógica pura: `color-engine`, `grid-engine`, `types`, `api-client` |
| `infra/` | IaC: `s3/`, `netlify/`, `database/` (schema + migrations) |
| `docs/` | `plan.md` (7 fases) · `architecture.md` · `decisions/` (ADRs) |
| `netlify.toml` | Build command, publish dir, functions, Node 24 |
| `.env.example` | Lista canónica de variáveis de ambiente |
| `.npmrc` | Auth GitHub Packages do escopo `@thijulio` |

---

## 4. Serviços a provisionar

> **Resumo conta a conta** (o que já existe vs o que criar):

| Serviço | Estado | Ação principal |
| --- | --- | --- |
| GitHub (repo `thijulio/painter-studio`) | ✅ já existe (privado, `main`, pushado) | validar PAT `read:packages` (§4.5) |
| Netlify (host + functions + Identity) | ✅ configurado | deploy + Identity Google padrão (§4.1) |
| Banco Postgres (Neon) | ✅ configurado | schema inicial aplicado (§4.2) |
| AWS S3 (imagens) | ✅ configurado | bucket privado + IAM + CORS/lifecycle (§4.3) |
| Google Cloud (OAuth) | ✅ projeto/consentimento | provider padrão do Netlify dispensa client próprio (§4.4) |
| AWS Route53 (DNS) | ✅ configurado | `painter-studio.thijulio.com` → Netlify + HTTPS (§4.6) |

---

### 4.1 Netlify — host + functions + Identity (Google login)
- **Papel:** hospedar o build web, rodar `functions/`, e autenticar via
  Netlify Identity (Google OAuth).
- **Já pronto:** `netlify.toml` configurado (`pnpm install --frozen-lockfile &&
  pnpm --filter @painter-studio/mobile build` → publish `apps/mobile/dist`;
  functions em `functions/` com esbuild; `NODE_VERSION=24`).
- **A fazer:**
  1. Criar conta/site Netlify e conectar o repo GitHub (auto-deploy no push p/ `main`).
  2. Setar env var `NODE_AUTH_TOKEN` (GitHub PAT com `read:packages`) — **já
     verificado** que lê `@thijulio/biome-tokens` (HTTP 200).
  3. Deploy inicial + smoke-test em `/.netlify/functions/hello` (deve retornar
     `{ ok: true, app: "painter-studio", phase: 0 }`).
  4. Habilitar **Netlify Identity** e adicionar o **provider Google** (item 4.4).

### 4.2 Base de dados — provider decidido pelo Codex; estrutura do smart-library
- **Provider: Neon.** A decisão e sua justificativa estão em
  `docs/decisions/0009-neon-postgres.md`.
- **Estrutura: reutilizar o padrão do Thiago Smart Library** (§4.2.1) — Postgres +
  pgvector, IDs surrogate + `stable_id`, junções N:M, event log append-only, cache
  derivado, audit de importação, proveniência por campo e colunas de ciclo de vida.
  Adaptar as *tabelas* ao domínio do Painter Studio (tintas, paletas, misturas,
  imagens, tamanhos de tela) — **não** copiar as tabelas de livros do smart-library.
- **Concluído:** o projeto Neon tem a migration inicial aplicada. A conexão pooled
  está guardada somente como `DATABASE_URL` secreto no Netlify; schema e ADR estão
  versionados em `infra/database/` e `docs/decisions/0009-neon-postgres.md`.

### 4.2.1 Estrutura de referência — Thiago Smart Library
Projeto de referência (mesmo dono, mesmas convenções):
- Código: `~/development/thiago-smart-library` (monorepo Nx, `apps/api` + `libs/data-access`).
- Docs/schema: `~/.../projects/personal-life/smart-library/docs/2026-09-19-database-structure.md`
  (contrato autoritativo) e `docs/schema/schema.sql` (protótipo SQL).

Convenções a reutilizar (resumo do contrato):
- **Postgres + pgvector + pg_trgm**; embeddings `vector(1536)` com índice HNSW +
  busca híbrida via coluna `tsvector` gerada + índice GIN. Schema **provider-agnostic**
  (roda em Supabase ou Neon).
- IDs **surrogate** `bigint GENERATED ALWAYS AS IDENTITY` + `stable_id` externo
  (text, UNIQUE, imutável) — desacopla joins internos de referências externas.
- **Lookups + junções N:M** (ex.: `authors`/`book_authors`) em vez de `text[]`.
- **Event log append-only** com `client_request_id` (idempotência) e CHECKs
  distinguindo decisão vs void.
- **Cache derivado** reconstruído em transação (nunca editado à mão).
- **Audit de importação** (`import_runs`/`import_rows`/`import_issues`) +
  **proveniência por campo** (`origin`, `actor`, `model`, `prompt_version`).
- **Ciclo de vida/audit**: `created_at`, `updated_at`, `updated_by`,
  `row_version` (concorrência otimista), `archived_at` (soft delete).
- **Privacidade**: separar colunas públicas vs privadas (controle no acesso).
- **Convenções**: snake_case, constraints nomeadas, `!` = NOT NULL, texto obrigatório nonblank.

### 4.3 AWS S3 — armazenamento de imagens
- **Papel:** guardar fotos do usuário; upload via **URL pré-assinada** gerada por
  `functions/storage` (o cliente faz PUT direto no S3, sem passar pelo servidor).
- **Concluído:** bucket privado em Paris (`eu-west-3`) com bloqueio público,
  ACLs desativadas, SSE-S3, CORS para produção/local e aborto de multipart uploads
  incompletos após 7 dias. O usuário IAM só tem `s3:PutObject`/`s3:GetObject`
  no bucket. A configuração versionada sem segredos está em `infra/s3/`.
- **Nota Netlify:** a plataforma reserva nomes `AWS_*`; os segredos são
  `S3_ACCESS_KEY_ID` e `S3_SECRET_ACCESS_KEY` e a função de storage deverá
  mapeá-los explicitamente para o cliente AWS SDK.

### 4.4 Google Cloud — OAuth para login Google
- **Concluído:** o projeto GCP `painter-studio-509817` e a tela de consentimento
  foram criados. O Netlify Identity está habilitado com o provider Google padrão.
  Isto permite login Google sem segredo no projeto, mas exibe **Netlify Identity**
  como app de consentimento.
- **Limite de plano:** credenciais OAuth próprias (branding “Painter Studio”)
  exigem Identity Pro. Não criar um client OAuth nem variáveis de segredo enquanto
  esse upgrade não for uma decisão explícita.

### 4.5 GitHub — repo já criado (não criar outro)
- **Repo já existe:** `https://github.com/thijulio/painter-studio` (privado,
  branch `main`, tudo commitado/pushado). **Não criar repo novo** — só validar acesso.
- Conta `thijulio` já autenticada; `gh auth token` tem scope `read:packages`
  (**verificado** HTTP 200 em `npm.pkg.github.com/@thijulio/biome-tokens`).
- **A fazer:** garantir um PAT (`ghp_`/fine-grained) com `read:packages` para a
  `NODE_AUTH_TOKEN`, ou reusar `gh auth token` (token `gho_`).

### 4.6 AWS Route53 — domínio custom `*.thijulio.com` (pós-deploy)
- **Papel:** apontar um subdomínio (ex.: `painter-studio.thijulio.com`) para o
  site Netlify via DNS.
- **Depende do deploy (item 4.1) existir** — fazer só depois que o site estiver no ar.
- **A fazer:** no Route53, criar CNAME `painter-studio` → `<site>.netlify.app`;
  no Netlify, adicionar o custom domain (e gerar/validar o certificado SSL).
  (Para apex/root `thijulio.com`, usar ALIAS/ANAME — não CNAME.)

---

## 5. Variáveis de ambiente (canónicas — `.env.example`)

| Variável | Onde vai | Origem |
| --- | --- | --- |
| `NODE_AUTH_TOKEN` | Netlify site env (build) | GitHub PAT `read:packages` |
| `EXPO_PUBLIC_NETLIFY_SITE_ID` | `.env` local / Expo build | Netlify site |
| `EXPO_PUBLIC_NETLIFY_IDENTITY_URL` | `.env` local / Expo build | Netlify Identity |
| `S3_BUCKET` | Netlify site env + `.env` local | AWS S3 |
| `S3_REGION` (`eu-west-3`) | Netlify site env + `.env` local | AWS S3 |
| `S3_ACCESS_KEY_ID` | Netlify site env (secret) | IAM S3 |
| `S3_SECRET_ACCESS_KEY` | Netlify site env (secret) | IAM S3 |
| `DATABASE_URL` | Netlify site env (secret) | Neon pooled Postgres URL |

> **Nota p/ Fase 1 (wiring no app Expo):** somente variáveis com prefixo
> `EXPO_PUBLIC_` podem ir ao cliente. Nunca exponha `DATABASE_URL`, chaves S3
> ou qualquer futuro segredo OAuth. `.env` e `.env.*` são ignorados no git;
> `.env.example` é o molde.
>
> **Nota p/ BD:** se o provider escolhido for **Neon** (em vez de Supabase), trocar
> as 3 variáveis `SUPABASE_*` por uma connection string (ex.: `DATABASE_URL`) e
> atualizar o `.env.example` de acordo.

---

## 6. Divisão humano vs agente (importante)

### Só o humano consegue (não automatizável)
- Criar as contas (Netlify, AWS, Google Cloud, e o provider de BD) — exigem e-mail,
  cartão de crédito e/ou telefone.
- Autorizar o **GitHub app do Netlify** (conectar o repo).
- Autorizar/consentir telas **OAuth do Google**.
- Gerar/entregar os segredos (tokens) quando o provider exige painel humano.

### O agente pode executar (com as credenciais)
- **Netlify:** `netlify sites:create` / `netlify link` / `netlify env:set` /
  `netlify deploy --build --prod` (via `NETLIFY_AUTH_TOKEN`) ou guiar o dono pela UI.
- **BD (Supabase/Neon/etc.):** provisionar projeto e rodar schema/migrations em `infra/database/` seguindo a estrutura do smart-library (§4.2.1).
- **AWS:** criar bucket + CORS + lifecycle + IAM via `aws` CLI (com credenciais).
- **DNS (Route53):** criar o CNAME do subdomínio apontando para o site Netlify.
- **GCP:** criar OAuth client e documentar redirect URIs.
- **GitHub:** validar PAT e configurar `NODE_AUTH_TOKEN`.

### Credenciais a pedir ao dono (lista pronta)
`NETLIFY_AUTH_TOKEN` · `S3_ACCESS_KEY_ID`/`S3_SECRET_ACCESS_KEY` ·
connection string Neon/Postgres · `NODE_AUTH_TOKEN` (ou `gh auth token`).
Clientes OAuth Google próprios só são necessários após upgrade do Identity Pro.

---

## 7. Ordem de execução (checklist)

- [x] 1. Codex decide o provider do BD e aplica a estrutura de referência (smart-library, §4.2.1).
- [x] 2. Netlify: criar site, conectar repo GitHub, setar `NODE_AUTH_TOKEN`, deploy.
- [x] 3. Validar smoke-test `/.netlify/functions/hello`.
- [x] 4. AWS: criar bucket privado + IAM + CORS/lifecycle; guardar credenciais.
- [x] 5. BD: criar projeto no provider escolhido + schema em `infra/database/` (estrutura smart-library); guardar credenciais.
- [x] 6. Google Cloud: projeto e consentimento configurados; client próprio não é necessário no provider padrão.
- [x] 7. Netlify Identity: habilitar + provider Google padrão; segredos permanecem fora do cliente.
- [x] 8. Domínio custom: CNAME no Route53 (`painter-studio.thijulio.com`) → Netlify (§4.6), HTTPS Let’s Encrypt ativo.
- [x] 9. Documentar tudo em `memory.md` e commitar (Conventional Commits).

---

## 8. Critérios de aceite (done when…)

- [x] Site web no ar em `https://painter-studio.netlify.app` com o app Expo renderizado.
- [x] `/.netlify/functions/hello` responde `200` `{ ok: true }`.
- [x] Bucket S3 criado (privado) e política IAM mínima configurada.
- [x] BD criado com schema inicial versionado em `infra/database/`.
- [ ] OAuth Google configurado e login Google funcional (Fase 1).
- [ ] Todas as env vars da tabela §5 preenchidas (Netlify + `.env` local).
- [x] (Opcional) Domínio custom `painter-studio.thijulio.com` com SSL resolvendo para o site.

---

## 9. Bloqueios / riscos conhecidos

- **BD deve seguir a estrutura do smart-library** (item 4.2.1) — adaptar tabelas ao domínio do Painter Studio; não copiar as de livros.
- **dev-tooling ainda não publicado:** `@thijulio/eslint-config`/`tsconfig`/`prettier-config`
  existem só em v0.0.1 sem release — **não tentar instalar** do GitHub Packages.
- **`@thijulio/governance-core`** (v0.1.0) ainda **não instalado** no projeto —
  instalar em `.agent-toolbox/` é follow-up, não bloqueia este setup.
- **npm cache local** com arquivos `root` (EPERM em `~/.npm`) — não afeta o build
  do Netlify (ambiente limpo), só o `pnpm view`/install locais.

# ADR-0008 — Monorepo: Nx + libs/ (alinhado ao padrão PMP)

Status: **aceito**

## Contexto

Iniciamos com pnpm workspaces + Turborepo e `packages/`. O dono tem padrão
senior-reviewed no **PMP** e no **design-systems** usando **Nx** + `libs/`.

## Decisão

- Trocar **Turborepo → Nx 23** (`nx.json` + plugins `@nx/expo` e `@nx/js`).
- Renomear `packages/` → **`libs/`**, com split `shared/` (lógica) e `frontend/` (UI),
  espelhando o `libs/{backend,frontend,shared}` do PMP.
- `apps/mobile` vira projeto Nx (inferido pelo plugin `@nx/expo`).
- `functions/` (Netlify) permanece como está — é o "apps/api" serverless (sem plugin Nx dedicado).

## Consequências

- Consistência com PMP/design-systems (mesmo mental model, configs e CI).
- `nx show projects` detecta `@painter-studio/mobile` com targets inferidos
  (start, build, export, typecheck, lint, prebuild, run-ios/run-android).
- Typecheck via `nx run-many -t typecheck` passa.

# Plano — Painter Studio

> Documento vivo. Atualizado a cada fase. Acompanha [`benchmark.md`](benchmark.md) e [`architecture.md`](architecture.md).

## 1. Visão

Um assistente de pintura **simples**, **multi-plataforma** (Android, iOS, web/desktop) e **sincronizado na nuvem**, que cobre o fluxo completo do pintor:

1. **Entra com Google** e tem as fotos salvas na nuvem (S3).
2. **Analisa a imagem** e extrai as cores úteis.
3. **Sugere o melhor tamanho de tela** (proporção → tamanhos de tela padrão).
4. **Quadricula a imagem** para referência de pintura.
5. **Divide em folhas A4** imprimíveis, na escala real da tela, para transferir com papel carbono.
6. **Roda de cores** para explorar harmonias.
7. **Inventário de tintas** + sugestão de famílias e paletas usando as tintas que ele já tem.
8. **Misturas**: clicou numa cor → mostra como chegar nela com as tintas do inventário.

## 2. Princípios

- **MVP primeiro**: cada fase entrega algo usável sozinho.
- **Um codebase, várias plataformas**: Expo (mobile + web/desktop PWA).
- **Lógica de cor/grelha em packages puros** (testáveis, sem UI) — `color-engine` e `grid-engine`.
- **Backend mínimo**: só o que o cliente não pode fazer (assinatura S3, geração de PDF, persistência).
- **Cloud-first**: imagens no S3, dados no Neon Postgres → funciona igual em qualquer device.
- **Design system**: visual via `@thijulio/biome-tokens` (Biome Modernism); nunca hardcode de cor.
- **AI Toolbox**: plugin `@thijulio/governance-core` para revisão de governança (read-only).

## 3. Escopo (MVP vs depois)

### MVP (Fase 1–3)
- Login Google (Netlify Identity).
- Upload de imagem para S3 (pré-assinado) + galeria pessoal.
- Extração de paleta de cores da imagem.
- Sugestão de tamanho de tela.
- Grelha sobre a imagem + exportação em A4 (PDF, escala real).

### Depois (Fase 4–6)
- Roda de cores + harmonias.
- Inventário de tintas + famílias/paletas.
- Motor de misturas (chegar numa cor com as tintas do inventário).
- PWA instalável / shell desktop.
- Ajustes de imagem (endireitar, recortar, remover fundo) — _opcional, inspirado no benchmark_.

## 4. Fases

| Fase | Título | Entregável principal | Critério de saída |
| --- | --- | --- | --- |
| 0 | Setup | Monorepo + Expo + Netlify + design system + AI toolbox + CI | `pnpm dev` roda app vazio nas 3 plataformas; deploy no Netlify; tokens Biome conectados |
| 1 | Auth + Imagens | Login Google + upload S3 | Usuário loga e vê a própria foto na galeria |
| 2 | Análise de cor | Paleta da imagem + tamanho de tela | Uma foto gera paleta com nomes/hex e 1 sugestão de tela |
| 3 | Grelha + A4 | Grelha + PDF A4 em escala | Download de PDF A4 com a imagem quadriculada, pronto p/ carbono |
| 4 | Roda de cores | Roda interativa + harmonias | Clicar numa cor mostra análogas/complementares/etc. |
| 5 | Inventário + Misturas | CRUD de tintas + receitas de mistura | Clicar numa cor da roda mostra % de cada tinta do inventário |
| 6 | Polimento | PWA/desktop, testes, perf | App instalável no desktop; fluxo completo sem bugs críticos |

## 5. Mapa funcionalidade → módulo

| Funcionalidade | Onde vive |
| --- | --- |
| Extração de cor | `libs/shared/color-engine` (cliente) + `functions/color-analysis` (servidor, sharp) |
| Tamanho de tela | `libs/shared/grid-engine` (tabela de tamanhos padrão) |
| Grelha (grid) | `libs/shared/grid-engine` + tela `analyze` |
| Tiling A4 → PDF | `functions/grid` (PDFKit) |
| Roda de cores | `libs/shared/color-engine` + tela `color-wheel` |
| Inventário | `functions/inventory` + Neon Postgres + tela `inventory` |
| Misturas | `libs/shared/color-engine` (delta-E + optimização) + `functions/mixing` |
| Auth | `functions/auth` (Netlify Identity) + `features/auth` |
| Upload S3 | `functions/storage` (pré-assinado) + `features/analyze` |

## 6. Riscos e decisões em aberto

- **Desktop nativo vs PWA**: PWA é o caminho simples; Electron só se precisar de acesso a arquivos/impressão local. **Decidir na Fase 6.**
- **Extrair cor no cliente vs servidor**: cliente é grátis e instantâneo; servidor (sharp) é consistente e permite quantização melhor. **Híbrido** (cliente no MVP, servidor se precisar).
- **Banco**: Neon Postgres dá as relações necessárias (tinta → paleta → mistura) e um pool adequado a Functions. **Neon.**
- **Precisão da mistura**: mistura de tinta real é não-linear (pigmentos). O MVP entrega aproximação (modelo RGB/CMY + delta-E), com aviso de que é aproximação.
- **Nome do projeto**: `painter-studio` é provisório.

## 7. Próximos passos (imediatos)

1. ✅ Estrutura de pastas criada.
2. ✅ Benchmark de mercado ([`benchmark.md`](benchmark.md)).
3. ⏭️ Validar stack e nome com o dono.
4. ✅ `git init` + scaffold Expo SDK 57 + Netlify (Fase 0).
5. ⏭️ Consumir `@thijulio/biome-tokens` (publicado 0.0.2) e conectar o tema.
6. ⏭️ Instalar `@thijulio/governance-core` no projeto (`.agent-toolbox/`).
7. ⏭️ Escrever o primeiro ADR (auth + storage).

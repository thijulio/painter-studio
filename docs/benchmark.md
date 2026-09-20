# Benchmark de mercado — Painter Studio

> Fontes coletadas em pesquisa web (data da sessão). Links no final.

## 1. O que já existe (concorrentes)

### ⭐ Principal referência: ArtistAssistApp
- **O que é:** app web (open source, TypeScript) de assistência ao pintor — **o mais próximo da nossa ideia**. [GitHub](https://github.com/eugene-khyst/artistassistapp) · [site](https://artistassistapp.com/en/).
- **Faz:** mistura de cores p/ combinar com a foto usando **as próprias tintas** do usuário, paletas e tabelas de mistura, estudo de valores tonais, contornos, **grelha (grid)**, paletas limitadas, versões da foto inspiradas em artistas, endireitar/ajustar cor/remover fundo, comparação lado a lado.
- **Implicação p/ nós:** valida a demanda e o design do domínio. Nosso diferencial não pode ser "mais um misturador" — precisa focar no **fluxo de transferência para a tela (A4 + carbono)** e na **experiência multi-plataforma na nuvem**.

### Mistura de cores / inventário
| App | Plataforma | Nota |
| --- | --- | --- |
| [HueBuddy / Paint Mixer](https://apps.apple.com/us/app/huebuddy-paint-mixer/id6746095358) | iOS | mistura de tintas |
| [Smarty Paints / Palette Keeper](https://play.google.com/store/apps/details?id=com.palettekeeper.palettekeeper) | Android | guardar paletas |
| [Artist's Aid to Color Mixing](https://play.google.com/store/apps/details?id=jmg.colmix) | Android | mistura de cores |
| [Real Paint Mixing Tools](https://apps.appfollow.io/ios/real-paint-mixing-tools/1431308757) | iOS | mistura de tinta real |
| [Color Gear](https://www.similarweb.com/app/apple/6475680414/vs/1512679630/) | iOS | paletas/harmonia |

### Grelha / grade (grid drawing)
| App | Plataforma | Nota |
| --- | --- | --- |
| [GridArt](https://play.google.com/store/apps/details?id=com.gridArt.drawing) | Android | grelha p/ desenho |
| [Grid App for Artists](https://play.google.com/store/apps/details?id=com.ar4j.grid4artists) | Android | grelha |
| [Mural Trace - Ctrl V Art Grid](https://apps.apple.com/mo/app/mural-trace-ctrl-v-art-grid/id6737825938) | iOS | grelha p/ mural |
| [Grid Maker for Drawing](https://www.producthunt.com/products/grid-maker-for-drawing-3) | Web/PH | grelha imprimível |

### Toolbox / all-in-one
| App | Plataforma | Nota |
| --- | --- | --- |
| [Arttrezzi: Artist Toolbox](https://apps.apple.com/kr/app/arttrezzi-artist-toolbox/id6748783513) | iOS | caixa de ferramentas |
| [AtelierKit](https://apps.apple.com/cn/app/atelierkit/id6759811134) | iOS | kit de atelier |
| [Monet Studio](https://apkpure.com/monet-studio/com.jgson.monet) | Android | estúdio |

### Extração de paleta (não específico p/ pintor, mas fundacional)
- [Coolors](https://coolors.co) e [Adobe Color](https://color.adobe.com): referência de UX para "extrair paleta de uma imagem" e gerar harmonias. Comparativo: [Adobe Color vs Coolors (2026)](https://toolradar.com/compare/adobe-color-vs-coolors).

## 2. Comparação de features

| Feature | ArtistAssistApp | Grid apps | HueBuddy/Palette Keeper | Coolors/Adobe | **Nós** |
| --- | --- | --- | --- | --- | --- |
| Extrair cor da imagem | ✅ | ❌ | ❌ | ✅ | ✅ |
| Tamanho de tela sugerido | parcial | ❌ | ❌ | ❌ | ✅ |
| Grelha sobre a imagem | ✅ | ✅ | ❌ | ❌ | ✅ |
| **Impressão A4 em escala real p/ carbono** | ❌ | parcial | ❌ | ❌ | ✅ ⭐ |
| Roda de cores / harmonias | ✅ | ❌ | parcial | ✅ | ✅ |
| Inventário de tintas | ✅ | ❌ | parcial | ❌ | ✅ |
| Misturar p/ chegar numa cor | ✅ | ❌ | ✅ | ❌ | ✅ |
| Multi-plataforma + cloud sync | web only | mobile | mobile | web | ✅ ⭐ |
| Login Google + imagens na nuvem | ❌ | ❌ | ❌ | parcial | ✅ ⭐ |

## 3. Diferenciais propostos

1. **Fluxo A4 + papel carbono** — poucos concorrentes cobrem a etapa física de transferir a imagem para a tela em **escala real**. É o gancho mais forte da ideia.
2. **Multi-plataforma real + nuvem** — começar num device e continuar em outro (imagens no S3, inventário no Supabase, login Google).
3. **All-in-one com foco no pintor** — cor + tela + grelha + roda + inventário + mistura num só lugar, sem trocar de app.
4. **Open-source/transparência do motor de cor** — possibilidade de abrir `color-engine` e `grid-engine`.

## 4. Lacunas de mercado (oportunidades)

- **A4 em escala real** quase não é tratado: os apps de grelha dão a grade na tela, mas não geram folhas prontas na dimensão exata da tela.
- **Desktop/web** é mal atendido: a maioria é app mobile nativo; artistas em estúdio costumam estar num computador.
- **Integração "tinta → mistura → tela"** é fragmentada em 3–4 apps diferentes.

## 5. Recomendação estratégica

- **Posicionar em torno do fluxo de transferência** (imagem → tela → grelha → A4) e tratar cor/inventário/mistura como complemento natural.
- **Inspirar-se no ArtistAssistApp** para o domínio (valida features), mas diferenciar na **impressão em escala** e no **multi-plataforma cloud**.
- **MVP estreito**: login + upload + paleta + tela + A4. Deixar roda/inventário/mistura para a fase seguinte.

## 6. Fontes

- https://github.com/eugene-khyst/artistassistapp
- https://artistassistapp.com/en/
- https://apps.apple.com/us/app/huebuddy-paint-mixer/id6746095358
- https://play.google.com/store/apps/details?id=com.palettekeeper.palettekeeper
- https://play.google.com/store/apps/details?id=jmg.colmix
- https://apps.apple.com/kr/app/arttrezzi-artist-toolbox/id6748783513
- https://apps.apple.com/cn/app/atelierkit/id6759811134
- https://play.google.com/store/apps/details?id=com.gridArt.drawing
- https://play.google.com/store/apps/details?id=com.ar4j.grid4artists
- https://apps.apple.com/mo/app/mural-trace-ctrl-v-art-grid/id6737825938
- https://www.producthunt.com/products/grid-maker-for-drawing-3
- https://toolradar.com/compare/adobe-color-vs-coolors

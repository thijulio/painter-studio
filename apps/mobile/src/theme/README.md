# src/theme — tema do app (via design system Biome Modernism)

- `tokens.ts` mapeia `@thijulio/biome-tokens` para um tema React Native.
- **Single source of truth** = design system; nunca duplicar hex/token aqui.
- **Dark mode:** os tokens JS exportam os valores base (light); o tema dark no DS é um
  overlay CSS (`[data-mode="dark"]`). Para dark no RN, precisaremos expor os valores dark
  como JS no DS (futuro ADR). MVP roda em light.

/**
 * Adapter: @thijulio/biome-tokens (Biome Modernism) → tema React Native.
 *
 * Fonte de verdade = design system (repo `thijulio/design-systems`). Nunca hardcodar
 * cor neste app — sempre importar deste arquivo. Consumido de
 * `@thijulio/biome-tokens` (publicado em 0.0.2 no GitHub Packages).
 *
 * Auth local: `NODE_AUTH_TOKEN` (definido no ~/.zshrc via `gh` keyring).
 */
import * as biome from "@thijulio/biome-tokens";

const px = (v: string) => Number.parseFloat(v); // tokens vêm verbatim ("4px")
const ms = (v: string) => Number.parseFloat(v) * 1000; // "0.4s" -> 400

// ── Cores semânticas (light/dark) ────────────────────────────────
export const colors = {
  light: {
    text: biome.TextStrong,                // ink #232A20
    textSecondary: biome.TextMuted,        // stone #8C8275
    background: biome.SurfacePage,         // bone #F2EEE2
    backgroundElement: biome.SurfaceRaised, // bone raised #F8F5EC
    backgroundSelected: biome.BmBoneLight, // #ECEFE3
    brand: biome.Brand,                    // mata #3F5237
    brand2: biome.Brand2,                  // cerrado #6E7A48
    accentWarm: biome.AccentWarm,          // terracotta #B5532A
    accentHighlight: biome.AccentHighlight, // ipê #E8A627
    border: biome.Border,                  // hairline
    focus: biome.Focus,                    // cerrado
    onBrand: biome.OnBrand,                // texto sobre brand
  },
  dark: {
    text: biome.BmBone,                    // #F2EEE2
    textSecondary: biome.BmStone,          // #8C8275
    background: biome.BmCanopy,            // #161D16
    backgroundElement: biome.BmUnderstory, // #1E261E
    backgroundSelected: biome.BmMataDeep,  // #2E3D28
    brand: biome.BmSage,                   // #8FB089
    brand2: biome.BmSageSoft,              // #6E9B7E
    accentWarm: biome.BmTerracottaDk,      // #C8693B
    accentHighlight: biome.BmIpe,          // #E8A627
    border: biome.BmHairlineDk,            // hairline dark
    focus: biome.BmCerrado,                // #6E7A48
    onBrand: biome.BmCanopy,               // texto sobre brand claro
  },
} as const;

export type ColorMode = keyof typeof colors;

// ── Fontes (nomes de família; carregar via expo-google-fonts como follow-up) ──
export const fonts = {
  heading: biome.TextHeading, // Newsreader (display serif)
  prose: biome.TextProse,     // Spectral
  label: biome.TextLabel,     // Space Grotesk
  code: biome.TextCode,       // JetBrains Mono
} as const;

// ── Espaçamento (escala Biome) ───────────────────────────────────
export const spacing = {
  1: px(biome.Space1),   // 4
  2: px(biome.Space2),   // 8
  3: px(biome.Space3),   // 12
  4: px(biome.Space4),   // 16
  5: px(biome.Space5),   // 20
  6: px(biome.Space6),   // 24
  8: px(biome.Space8),   // 32
  10: px(biome.Space10), // 40
  12: px(biome.Space12), // 48
} as const;

// ── Movimento ─────────────────────────────────────────────────────
export const motion = {
  durFastMs: ms(biome.DurFast),
  durBaseMs: ms(biome.DurBase),
  durSlowMs: ms(biome.DurSlow),
  easeOrganic: biome.EaseOrganic,
  easeOut: biome.EaseOut,
  easeInOut: biome.EaseInOut,
} as const;

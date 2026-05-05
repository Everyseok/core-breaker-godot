# Design Constitution

## 1. Primary Direction

- Portrait-first cute pixel radial-defense game.
- The game must feel original, readable, and cohesive on mobile.
- The center guardian/core is cute and friendly, but the attacks should feel sharp, cool, and satisfying.
- Background/UI should support readability; weapon presentation should carry the strongest visual intensity.
- The game must not read as a SaaS dashboard, fintech product, crypto site, or glossy console storefront.

## 2. Secondary UI References Only

These references are for menu/HUD tone only. They are not the game art direction.

- **PostHog**: playful dark friendliness for panels and menu mood
- **Figma**: clear tier-color separation for labels and state readability
- **Miro**: strong yellow highlight logic for `준비 완료` / `해금!`
- **PlayStation**: game-menu hierarchy for start / pause / result structure
- **Apple**: spacing restraint and safe-area discipline only

Rejected as visual direction:

- Linear
- Vercel
- Supabase
- Spotify

## 3. Player-Facing Text Rules

- Player-facing UI text is Korean.
- Raw internal `K` is not the main visible label.
- The main progression term is `깬 벽돌`.
- Compact portrait-safe labels are preferred:
  - `단계`
  - `깬 벽돌`
  - `무기`
  - `다음 해금`
  - `최고 기록`
  - `가속`

Font direction:

- Friendly rounded Korean system-font fallback chain
- Readable at small mobile sizes
- No cold corporate tone

## 4. Center Guardian / Core

- The gameplay origin stays fixed at the center.
- The visible cyan point remains the exact launch origin.
- A dark shell + glow + simple guardian silhouette communicate the protected center.
- The guardian should visually lean / face the current aim direction without moving the real launch origin.
- Pseudo-3D depth should come from shell shadow, visor/rim light, wing tilt, and a rotating weapon mount.
- The guardian silhouette changes by tier:
  - `화살`: bow
  - `번개`: fork
  - `스파크 랜스`: triple lance
  - `볼트 스톰`: storm crown
  - `시즈 캐논`: cannon
- Tier unlocks may trigger a small guardian pulse, but that pulse is visual-only.

## 5. Weapon Identity

| Tier | K Band | Visible Name | Identity |
|------|--------|--------------|----------|
| 1 | `0–29` | `화살` | gold starter bow / arrow |
| 2 | `30–79` | `번개` | yellow twin electric forks |
| 3 | `80–149` | `스파크 랜스` | blue refined lance burst |
| 4 | `150–499` | `볼트 스톰` | violet / magenta / teal evolved storm |
| 5 | `500–999` | `시즈 캐논` | orange / red siege artillery |

Rules:

- Tiers must not feel like recolors only.
- Differentiate by center silhouette, projectile shape, hit effect, unlock copy, and color family.
- Gameplay rules stay in gameplay scripts; visual identity lives in visual/UI/VFX scripts.

## 6. World Presentation

### Bricks

- `Normal`: warm base block
- `Strong`: reinforced cool-tone frame
- `Armored`: heavier plated silhouette
- Damage readability must come from type framing plus damage tint/overlay, not clutter.
- Floating damage numbers should be cute, readable, layered, and short-lived rather than debug-like.
- Floating damage numbers may use compact arcade values such as `3K`, `4K`, `5K`, and `9K`.
- Destroyed bricks must break in place with local type-specific burst feedback; they must not visually travel toward the core.
- Pseudo-depth should come from bevel, shadow plate, highlight strip, and darker underside, not extra clutter.

### Background

- Lightweight procedural dark pixel-space atmosphere
- Supports portrait play without flattening into a plain black void
- Gets darker by level without obscuring threats
- Mild parallax-style depth is allowed if it stays subtle and readability-safe.

### UI

- Compact dark panels
- Bright tier-coded accents
- Safe-area aware top HUD
- The playfield sits lower than the top HUD so the upper wall is not hidden behind UI.
- The lower joystick + buff area should sit low enough that the thumb does not cover too much of the wall/combat field.
- Only the joystick-area buff button remains; the older bottom square buff slot is removed.
- The top level chip must always show the current `단계`.
- Bottom controls remain unobstructed
- Unlock announcement stays short, centered, and non-blocking
- The joystick should feel cute, dimensional, and game-like rather than prototype-flat.
- The `무기 진화 선택!` panel should feel like a Korean mobile reward moment with three bold color-coded cards.

## 7. Visual Architecture

- Gameplay scripts own damage, scoring, progression, and wall spawning.
- `scripts/visual/*` owns shared presentation profiles and procedural background/effects.
- `scripts/visual/damage_number.gd` owns floating damage-number rendering.
- `scripts/visual/brick_break_effect.gd` owns brick death presentation.
- `scripts/ui/*` owns menus, HUD, Korean text, and unlock announcement presentation.
- Projectile scripts may spawn visual-only hit effects after a confirmed hit.
- `GameRoot` may expose narrow visual-only world-popup spawn entry points for damage numbers and brick-break effects.
- No visual script may modify score, `K`, HP, damage, or spawn rules.

## 8. Current Placeholder Boundaries

- All visuals remain lightweight procedural Godot nodes.
- No large external art assets were imported.
- The current rebuild is a clean structured presentation pass, not a final sprite-production pass.
- This constitution is currently applied in the original repo on `feature/design-rebuild-apply-pass`.

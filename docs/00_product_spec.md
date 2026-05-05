# Product Specification — game_junseokism.ver1

## 1. Elevator Pitch

A mobile-first, portrait pixel-art **radial survival** game.
Concentric segmented walls shrink inward toward a central core.
The player defends the core by shooting outward from the center core area, destroying wall segments before the wall reaches the death zone.
Survive as long as possible. Internal progression still uses `K`, but player-facing UI describes this as **깬 벽돌**.

---

## 2. Core Mechanics

### 2.1 Orientation & Layout

- **Portrait orientation** (9:16 base, 390×844 reference).
- Safe-area padding required for iOS Dynamic Island and Android status bar/gesture bar.
- Bottom ~20 % of screen: **control UI zone** (aiming joystick + joystick-area buff button).
- Remaining ~80 % of screen: the **play field** (ring system + projectiles).
- The **play field** sits intentionally lower than the top HUD so the upper rotating wall does not hide behind UI.
- The lower control zone should sit far enough down that the player finger does not cover too much of the visible action area.

### 2.2 Play Field Positions

**This section defines the constitutional layout. It overrides the older bottom-origin correction.**

| Element | Position |
|---------|----------|
| Core (game-over point) | Center of the play field: approx. `(195, 432)` in a 390×844 viewport |
| Weapon / projectile origin | Center core area: same launch region as the Core |
| Ring center | Same point as the Core — rings are centered on the core |
| Lower control zone | Below the play field, always above safe-area bottom inset |

**Central radial defense:**
- The weapon fires from the center core area, not from the bottom of the play field.
- The center is both the death zone to protect and the projectile launch origin.
- The player aims radially outward around the shrinking wall system.
- The **exact center of the cyan core point** is the true projectile launch origin.
- Projectiles must visibly emerge from that exact point, not from a nearby offset, a hidden muzzle offset, or the larger dark core square.

### 2.3 Core

- Fixed, non-moving node at the center of the play field.
- Has a visible **kill radius** (circle collider, radius ~40 px).
- Game over triggers **instantly** when any alive wall segment or dangerous object enters the kill radius.
- Core should have a subtle idle animation (pulse/glow).
- Projectiles originate from this same central core area.

### 2.4 Aiming & Auto-Fire

- Player does **not** manually tap to fire.
- A **virtual aiming joystick** is the primary aim control.
- The joystick only controls firing angle. It does **not** move the core or any player body.
- Default joystick placement is **bottom-center**.
- Subtle left/right placeholder buttons adjacent to the joystick can move it between:
  - bottom-left
  - bottom-center
  - bottom-right
- The same joystick logic must work in all three positions.
- Weapon auto-fires at a fixed cadence toward the current aim direction.
- When no joystick drag is active, weapon continues firing in the last confirmed direction.
- Aim originates from the center core launch point.
- Projectile visuals should be authored so the launch point reads as the exact center of the cyan point, not the midpoint of the projectile body.

### 2.5 Continuous Segmented Radial Wall System

**This section overrides the older "discrete ring of bricks" prototype description.**

- Threats are **continuous segmented radial walls** — circles packed tightly enough that they form a barrier with no passable gaps.
- Each wall is divided into segments (bricks) arranged so adjacent bricks are touching or nearly touching around the full circumference.
- Walls spawn at a large radius (outside or at the edge of the play field) and shrink inward toward the core.
- As walls shrink, the player must destroy segments to create gaps that projectiles can pass through to reach inner walls.
- Multiple walls can be active simultaneously.
- Once all segments of a wall are destroyed, that wall is gone.
- Segment count must tile the circumference at the current radius so the wall remains continuous (or near-continuous) at spawn.

**Segment tiling rule:**
- At any current radius `R`, segment size `S`, active segment count should be approximately `floor(2πR / S)` or `ceil(2πR / S)` depending on which preserves continuity more safely.
- As radius decreases, **segment count must decrease** so segments do not increasingly overlap while shrinking inward.
- Count reduction must preserve wall continuity; it must not create large new passable gaps on its own.
- Meaningful gaps should appear because the player destroyed segments, not because the geometry fell out of sync while shrinking.
- This explicitly replaces both the old fixed-count prototype and the intermediate “count fixed at spawn radius” correction.

### 2.6 Segment (Brick) Types

| Type | HP | Visual Indication |
|------|----|-------------------|
| Normal | 3000 | warm cute block, lighter crumble on death |
| Strong | 6000 | reinforced cool-tone frame, heavier crack burst |
| Armored | 9000 | plated violet/dark silhouette, heaviest shard burst |

**Readability rule:** Damage state must be readable at a glance at small pixel-art resolution.
Use distinct hue shift + layered shadow/highlight treatment (not just brightness).

**Death rule:** Destroyed bricks die in place.
They must not fly to the core or the attack point before removal.
Each brick type should emit its own local destruction effect where it dies.

**Normal segments are always 1-hit. Do not flatten all segment types into generic HP scaling.**

### 2.7 Default Arrow Behavior

- The default arrow is the baseline weapon.
- It must **bounce 3 times**.
- On each wall impact, it applies a **3-segment hit spread**:
  - the hit segment
  - one adjacent segment to the left
  - one adjacent segment to the right
- On normal 1-HP walls, that means 3 destroyed segments per impact.
- On strong / armored walls, the same 3-target pattern applies while still respecting HP > 1.

### 2.8 Thunder Weapon Behavior

- The first upgrade after the default arrow is a **yellow electric weapon**.
- It unlocks at the first destroyed-brick threshold and that threshold remains tunable in data.
- It fires **2 projectiles** per volley.
- Each projectile keeps the baseline **3-bounce** rhythm.
- On impact, each projectile applies a **3-segment same-layer spread**:
  - the hit segment
  - one adjacent segment to the left
  - one adjacent segment to the right
- It does **not** transfer damage to adjacent layers.

### 2.8b Spark Lance Behavior

- The next upgrade is a **blue electric / plasma lance evolution**.
- It should feel like a clear upgrade from the yellow electric tier, not just a recolor.
- Current implementation keeps a split-lance presentation with a centered refined electric identity.
- The weapon family should stay sharp, fast, and readable in portrait play.

### 2.8c Volt Storm Behavior

- The mid-late upgrade is an evolved electric storm family.
- It bridges the earlier electric weapons into the final siege tier.
- The visual identity should use a stronger violet / magenta / teal family and feel more premium than Spark Lance.
- Gameplay behavior must remain visually distinct while preserving the existing stable damage rules.

### 2.8d Siege Cannon Behavior

- The final late-game weapon is a **7-shot Piercing Bomb Siege** presentation.
- It must read as a true end-tier artillery weapon.
- Presentation should feel heavy, hot, and breach-focused without changing the locked gameplay math.

### 2.8e Numeric Damage Model

| Tier | Visible Name | Damage | Compact Popup |
|------|--------------|--------|---------------|
| 1 | `화살` | 3000 | `3K` |
| 2 | `번개` | 4000 | `4K` |
| 3 | `스파크 랜스` | 5000 | `5K` |
| 4 | `볼트 스톰` | 6000 | `6K` |
| 5 | `시즈 캐논` | 9000 | `9K` |

Rules:

- The base Normal brick dies from one `화살` hit.
- Strong and Armored bricks survive longer unless struck by stronger tiers or multiple hits.
- Damage popups display compact arcade-style values such as `3K` / `11.3K`.
- Damage numbers are visual-only feedback and do not change combat rules by themselves.

### 2.9 Game Over Condition

- Any segment with HP > 0 reaches the core kill radius → instant game over.
- Show the final broken-bricks result (`깬 벽돌`) and a restart prompt.

### 2.10 Progression (K = Total Segments Destroyed)

| K Range | Active Projectile | Player-Facing Name | Notes |
|---------|-------------------|--------------------|-------|
| 0–29 | Basic Arrow | `화살` | 3 bounces, 3-target spread |
| 30–79 | Thunder | `번개` | 2 projectiles, yellow electric, 3 bounces, same-layer 3-target spread |
| 80–149 | Spark Lance | `스파크 랜스` | blue electric evolution, sharper split-lance presentation |
| 150–499 | Volt Storm | `볼트 스톰` | evolved storm family, current stable electric-combat rules preserved |
| 500–2999 | Piercing Bomb Siege | `시즈 캐논` | 7-shot siege volley from the center; from `2000` onward, the 5-layer late wall plan escalates to 8 layers |
| 3000 threshold | Level Transition | `다음 단계` | current level clear -> next level start; each new level restarts the same structural band order |

This table is the current locked progression plan at the design/spec level. Internal progression still uses `K`, but the visible UI should describe the number as **깬 벽돌**. The K3000 level-loop runtime rule and Level 100 max-clear rule are now implemented.

### 2.10b Weapon Evolution Choice

- At **current-level broken bricks `2000 / 3000`**, gameplay pauses and shows a 3-choice evolution panel.
- The player selects exactly one option for the rest of the current level.
- The choice resets on the next level and on a new run.
- Current implemented choices:
  - `연쇄 번개`
  - `프리즘 랜스`
  - `메테오 캐논`

### 2.10a Locked Late-Tier Rules

- **Electric Split Arrow (K 150–299)**
  - Keeps split-arrow identity.
  - Intended effective hit budget per hit event: **6 total damaged targets**.
  - Wall thickness for this sub-band is **2 layers** with composition **Strong + Armored**.

- **Electric Split Arrow (K 300–499)**
  - Weapon identity stays the same: `3` bolts with electric propagation style.
  - Intended effective hit budget per hit event remains **6 total damaged targets**.
  - If intended adjacent-layer electric targets are already destroyed, the electric effect must **reallocate** that missing damage budget to other valid still-breakable targets.
  - Electric damage must not silently shrink just because some preferred targets are already empty.
  - Wall thickness for this sub-band remains **2 layers** with composition **Strong + Armored**.

- **Piercing Bomb Siege (K 500–999)**
  - From K `500` onward, the attack is no longer a single spear.
  - It becomes a **7-shot siege volley** fired from the exact cyan center point at:
    - `-36°`, `-24°`, `-12°`, `0°`, `+12°`, `+24°`, `+36°`
  - The center spear is the main breach projectile:
    - straight, **0-bounce**
    - up to **2 pierced segment collisions**
    - enlarged terminal explosion neighborhood:
      - same layer = `{I-2, I-1, I, I+1, I+2}`
      - adjacent outer layer center if present
      - adjacent inner layer center if present
    - this yields up to **7 logical targets** when both adjacent layers exist
  - The six side spears are support breach shots:
    - straight, **0-bounce**
    - recommended default = **1 pierced segment collision** each
    - smaller support explosion is allowed for readability; current locked recommendation is same-layer `{I-1, I, I+1}` plus adjacent outer/inner layer centers when present
  - Wall thickness for this band is **5 real layers** with composition:
    - `Strong + Strong + Normal + Strong + Armored`

- **K 3000 Level Transition**
  - `K = 3000` is **not** the start of a new continuous combat tier.
  - `K = 3000` means the **current level is cleared** and the run transitions into the **next level**.
  - Every new level restarts the same structural progression loop:
    - `0–29` 화살
    - `30–79` 번개
    - `80–149` 스파크 랜스
    - `150–499` 볼트 스톰
    - `500–999` 시즈 캐논
  - Ranking/progression should prioritize **level first**, then `K` inside the level.
  - Recommended normalized ranking progress:
    - `total_progress = (current_level - 1) * 1000 + current_level_k`
  - `Hybrid Siege` is no longer the immediate K1000+ continuation target in the current plan.
  - Hybrid may remain a **future optional late-game extension concept**, but it is not the next required implementation band.

### 2.10c Max Level / Ranking Rule

- The game has **Level 1 through Level 100**.
- Each level uses `current_level_k 0–999`.
- Reaching `current_level_k = 3000` clears the current level and advances to the next level until Level `100`.
- Recommended default end condition:
  - **Level 100 K3000 = `최고 단계 돌파!` / run ends**
- Ranking should prioritize **level first**, then `K` inside the level.
- Locked normalized ranking formula:
  - `total_progress = (current_level - 1) * 1000 + current_level_k`
- Current runtime behavior is explicit:
  - `total_progress` caps at `300000`
  - the run ends immediately on Level `100` clear
  - the result screen shows a distinct `최고 단계 돌파!` clear state

### 2.10b Layer / HP Interpretation

- “Wall gets thicker” always means **more concentric layers**, not more segments crammed into one ring.
- Each layer must remain its own continuous segmented radial wall.
- No overlap is allowed between layers.
- Meaningful gaps should still come from destroyed segments, not geometry drift.
- From K `500` onward, late-game thickness is explicitly **5 real layers**.
- Active wall layers should keep rotating all the way inward until they are destroyed or they breach the core / game-over zone.
- Small radius alone must not freeze angular motion.
- HP readability stays fixed by type:
  - `Normal = 1`
  - `Strong = 2`
  - `Armored = 3`
- Late difficulty should come mainly from:
  - layer count
  - layer composition
  - weapon role shifts
- Late difficulty should **not** come mainly from arbitrary HP inflation.

### 2.11 Unlock Progress Display

- The destroyed-brick count used for progression must be clearly visible at the top of the screen.
- Internal `K` may stay in code, but the visible label should be **깬 벽돌**.
- The display must make the next projectile unlock legible enough that the player can tell how close they are to the next weapon.
- A clean threshold-crossing event/state hook should exist for unlock banners / VFX.
- The top HUD includes a horizontal level-band progress bar plus compact Korean labels.
- Current locked interpretation:
  - `current_level_k 0–999 = current level progress`
  - reaching `current_level_k = 1000` clears the current level and starts the next level
- The bar fills left-to-right within the **current level** only.
- Current recommended per-level progress formula:
  - `level_progress = clamp(current_level_k / 1000.0, 0, 1)`
- The displayed level should be derived from `current_level`, while the per-level bar should restart from zero each time a new level begins.
- This does **not** create a second progression source; it is a player-facing view over the same underlying ranking progression, with:
  - `current_level`
  - `current_level_k`
  - normalized total progress for ranking
- Recommended player-facing label set:
  - `단계`
  - `깬 벽돌`
  - `무기`
  - `다음 해금`
  - `최고 기록`

---

## 3. Skill System

### 3.1 Bottom Controls

- The aiming joystick lives in the lower safe-area-compatible UI zone.
- The joystick keeps left / center / right placement switching.
- A single buff button appears above the joystick area for direct activation of unlocked combat buffs.
- The older bottom square buff slot is no longer part of the active runtime UI.

### 3.2 Active Skills

| ID | Name | Effect | Cooldown |
|----|------|--------|----------|
| SK_01 | Overclock (`가속`) | Temporary attack-speed boost (3x baseline fire rate for 3 s) | 15 s |

- Overclock (`가속`) is the first real attack-speed buff.
- It unlocks at **K >= 500**.
- Overclock (`가속`) is triggered from the joystick-area buff button.
- Before K `500`, that control should remain visibly locked/disabled rather than acting as a redundant system.

Additional skills to be designed in later phases.

### 3.3 Passive Progression

- Projectile upgrades (§2.8) are automatic and do not consume skill slots.
- Passive stat changes (damage, speed, wall count) are handled by the progression config.

---

## 4. Danger State Presentation

The game escalates tension visually and audibly as walls approach the core.

| Danger Level | Trigger (wall distance from core) | Visual | Audio Arch |
|---|---|---|---|
| 0 — Safe | All walls far | Normal | Normal BGM |
| 1 — Caution | Any wall < 60 % of play-field radius | Subtle edge vignette | BGM intensity +1 |
| 2 — Warning | Any wall < 35 % | Edge flash pulse (slow) | BGM intensity +2, SFX warning beep |
| 3 — Critical | Any wall < 15 % | Fast edge flash, UI warning pulse | BGM intensity +3, fast beep |

- Architecture must allow music intensity escalation even before audio assets exist (stubs OK).
- `DangerManager` emits `danger_level_changed(level: int)` signal that all interested nodes subscribe to.

---

## 5. Art Direction

- **Pixel art**, minimum 16×16 segments, 32×32 preferred.
- Readability > decoration: high contrast wall segments against dark background.
- Core should be visually distinct (bright, central glow).
- UI icons: 32×32 px pixel art, clear silhouette.
- Avoid dithering on critical gameplay objects (segments, projectiles).
- Background: static or very subtle parallax starfield / grid.

---

## 6. Audio

- All audio managed via `AudioManager` autoload.
- Player can toggle sound on/off; state persists across sessions.
- Backgrounding immediately mutes; foregrounding restores previous state.

### 6.1 Audio Resource Strategy

- Audio is a **dedicated future resource pass**; do not add production BGM/SFX ad hoc during gameplay implementation passes.
- Level-up SFX and BGM variation are required later, but audio resources are **not** added in the current pass.
- Do **not** plan for `100` unique full BGM files.
- Preferred later strategy:
  - `3–5` level-up SFX variations
  - BGM by level band, for example:
    - `1–10`
    - `11–25`
    - `26–50`
    - `51–75`
    - `76–100`
  - or one base loop plus intensity stems / pitch/filter variation if that is lighter and more maintainable
- Audio resources must be tracked in a future **resource manifest**.
- Raw source assets such as `.wav` production masters must **not** be included in the release bundle.
- If audio resources threaten the Toss `.ait` bundle limit, they must be reduced, streamed, or lazy-loaded rather than silently bloating the shipped bundle.

### 6.2 Audio Legal / License Gate

- No unverified BGM or SFX may be shipped.
- Every audio asset must have saved license proof before release.
- Acceptable sources:
  - self-made
  - commissioned with contract
  - paid royalty-free license
  - explicit commercial game/app-use license
- License coverage must include:
  - commercial use
  - game/app use
  - Toss mini-app / web / mobile distribution
  - advertising or other revenue-generating use
  - loop/edit/format conversion rights
  - territory and duration, preferably worldwide and perpetual
- License evidence should be stored under:
  - `docs/legal/music_licenses/`
- If AI-generated music is used later, the saved terms must explicitly prove commercial game/app distribution rights.

---

## 7. Platform Targets

| Priority | Platform | Notes |
|----------|----------|-------|
| 1 | Toss Mini App (Web/HTML5) | Primary release target |
| 2 | Android | Future |
| 3 | iOS | Future |
| 4 | Desktop | Dev/debug only |

---

## 8. Out of Scope for Current Gameplay MVP

- Multiplayer
- Story / narrative
- Cloud save sync
- Unlockable cosmetics

These are **not** part of the current gameplay implementation scope, but several of them are still required in later release/platform passes:

- App-in-Toss Game Center leaderboard integration
- App-in-Toss ads integration
- Audio resource import / legal verification
- Bundle-size optimization for the final `.ait`

---

## 9. Release / Platform Roadmap Constraints

### 9.1 Game Center Leaderboard

- Leaderboard is required later as a **separate platform pass**.
- It must use App-in-Toss **Game Center / leaderboard APIs**, not a fake custom leaderboard.
- Score must be `total_progress`, not `current_level_k` alone.
- Submission rules:
  - do not submit duplicate scores for the same run
  - handle network failure and retry intentionally
  - submit at game-over or max-level-clear / run-complete transition
  - do not submit on app entry
- Opening the leaderboard must preserve or restore gameplay state safely because the leaderboard WebView/background transition can interrupt the mini-app.

### 9.2 Game User Key

- User identification should use `getUserKeyForGame` in a future platform pass.
- This key is game-miniapp-specific and intended for internal user identification / data management.
- It is **not** a Toss server API token.
- Integration must handle:
  - unsupported Toss app version
  - `undefined`
  - `INVALID_CATEGORY`
  - `ERROR`
  - sandbox/mock behavior
- Minimum supported Toss app version must be documented before release integration.

### 9.3 Ads / Monetization

**Updated in Phase 4.20 with official App-in-Toss doc findings.**

Ads are a **separate deferred monetization pass**. Do not implement until prerequisites are complete.

#### Official API Surface (App-in-Toss Developer Center)

| Ad Type | API | Min Toss App Version | Official Source |
|---------|-----|---------------------|-----------------|
| Full-screen interstitial | `loadFullScreenAd()` → `showFullScreenAd()` (IntegratedAd v2) | v5.247.0 (full v2); v5.227.0 (AdMob-only fallback) | developers-apps-in-toss.toss.im/bedrock/reference/framework/광고/IntegratedAd.md |
| Reward ad | Same IntegratedAd v2, `userEarnedReward` event | v5.247.0 / v5.227.0 | Same |
| Banner ad | `TossAds.initialize()` → `TossAds.attachBanner()` | v5.241.0 | developers-apps-in-toss.toss.im/bedrock/reference/framework/광고/BannerAd.md |

Banner dimensions (official):
- Width: always 100% screen width
- Height: 96px (list/fixed, preferred) or 410px (feed/native)

Note: These are Bedrock/web-framework APIs. For Godot Web, all calls go through `JavaScriptBridge` in `PlatformBridge`. No external SDK binary is added to the Godot `.pck` or `.wasm`.

#### Prerequisites Before Implementation (Official, from ads/console.md)

1. Business registration in Toss console (required before terms/settlement)
2. Terms agreement
3. Settlement information (banking details; review ~2–3 business days)
4. Ad group creation (format + placement; ad group IDs take ~2 hours to register with Google)
5. Test ad IDs available immediately after ad group setup:
   - Full-screen: `ait-ad-test-interstitial-id`
   - Reward: `ait-ad-test-rewarded-id`
   - List banner: `ait-ad-test-banner-id`
   - Feed banner: `ait-ad-test-native-image-id`

**Current status:** Business registration / console setup / settlement not started. Ad implementation is blocked.

#### Placement Rules

**Allowed placements (official + engineering):**
- Game over screen / result screen — safest interstitial trigger; game simulation already stopped
- Max level clear screen — same; run has ended
- Between-run transition (before new run starts, after player taps restart)
- Frequency limits and cooldown required (official QA requirement)

**Explicitly prohibited placements (official, from ads/develop.md):**
- Active gameplay — prohibited
- Loading / intro screens — prohibited
- Modal dialogs — prohibited; PauseMenu is a modal overlay (**pause-screen ad is policy-risky**)
- Game UI overlap areas (joystick, skill bar, HUD) — prohibited
- Payment or account setup flows — prohibited
- Tutorial / temporary screens — prohibited

**Pause-screen interstitial risk:**
The official `ads/develop.md` lists modal dialogs as a prohibited placement. `PauseMenu` sets `get_tree().paused = true` and displays a modal-style overlay. Showing a full-screen ad on pause is doubly risky:
1. Interrupts a user's intentional pause.
2. May be classified as a modal-dialog placement violation.
**Do not use pause-screen as the default interstitial trigger. Do not implement until officially confirmed safe.**

#### Banner Placement Constraints

The 390×844 viewport layout has the following occupied zones:
- Top HUD: K/level bar (~60px)
- Play field: y ≈ 60–675
- Skill bar / joystick: ~675–780
- Safe-area bottom inset: device-dependent

A 96px banner at the **very bottom** (below joystick + skill bar, inside safe area) is the best candidate if the layout allows. Must validate that banner does not overlap joystick or skill slot hit areas during device QA. If bottom placement conflicts with controls, top placement (below HUD bar) is the fallback — but requires HUD layout adjustment.

**Do not finalize banner position until interactive device QA confirms no overlap with gameplay controls.**

#### Ad Failure Behavior (Non-Blocking)

- `loadFullScreenAd` failure → skip `showFullScreenAd`; proceed to game-over screen or new run normally. Never block restart.
- `showFullScreenAd` → `failedToShow` event → dismiss failure silently; proceed normally.
- `TossAds.attachBanner` failure → hide banner container, do not leave empty frame visible.
- No gameplay action should be gated on ad success.

#### Audio During Ads (Official QA Requirement)

- Call `AudioManager.mute_all()` immediately before `showFullScreenAd()`.
- Call `AudioManager.restore_mute_state()` on `dismissed` or `failedToShow` events.
- For banner ads: no audio pause required (banner is passive, no audio interruption).

#### Bundle Size Impact

- IntegratedAd v2 and BannerAd SDKs are loaded by the Toss WebView shell — they are **not** added to the Godot `.pck` or `.wasm`.
- PlatformBridge ad stub code is minimal (<1 KB GDScript).
- Ad images are loaded at runtime from Toss ad servers — not included in the bundle.
- **Rerun the export audit after ad implementation** to confirm `.pck` size is still within limits.

#### Version Compatibility Strategy

Current minimum version wired in PlatformBridge:
- Leaderboard: v5.221.0
- getUserKeyForGame: v5.232.0

Ad versions add new constraints:
- Banner: v5.241.0
- IntegratedAd v2: v5.247.0

All ad wrappers must use `isSupported()` check (per official API) and degrade silently on unsupported versions.

### 9.4 Bundle Size Gate

- The uploaded `.ait` bundle must be **100MB or less after decompression**.
- The release bundle should contain only minimal runtime files.
- Do not include in the shipped bundle:
  - `.git/`
  - `.godot/`
  - `.import/`
  - `docs/`
  - `logs/`
  - `_history/`
  - `screenshots/`
  - `recordings/`
  - raw source files such as `.wav`, `.psd`, `.aseprite`
  - local backups
- Bundle-size audit must be rerun after every significant SDK/resource pass.

## 10. Engineering Constraints

- Presentation code owns visuals, scene glue, and input-facing behavior only.
- Business rules such as score progression, wall planning, and danger evaluation should live outside scene-local node scripts where practical.
- Autoloads must remain slim coordinators/services, not god objects.
- Save, config, audio, and platform integration should stay behind infrastructure-facing components so gameplay rules do not depend directly on external systems.
- Refactors must preserve Toss mini-app constraints: portrait-first layout, safe-area respect, persistent settings, lifecycle-safe audio behavior, and non-coercive UI flows.

---

## 11. Obsolete Prototype Behaviors (Do Not Restore)

The following describe older designs that have been superseded by the constitutional overrides in §2.2, §2.5, §2.7, and §2.8:

| Obsolete | Replaced by |
|----------|-------------|
| Weapon fires from bottom of play field | Weapon fires from the center core area (§2.2) |
| Rings are sparse loose circles of N discrete bricks | Continuous segmented radial walls tiled to circumference (§2.5) |
| Core is only the death zone | Core is both death zone and projectile launch origin (§2.2, §2.3) |
| Fixed brick-count regardless of ring radius | Segment count derived from current circumference (§2.5) |
| Segment count fixed once at spawn | Segment count decreases with radius while preserving continuity (§2.5) |
| Arrow destroys only the directly hit segment | Arrow uses 3 bounces and 3-target spread (§2.7) |

Any code, scene, or doc that reflects the obsolete prototype must be corrected before the next gameplay implementation step.

# Gameplay K-Scale Half Report

## Summary

This pass compresses K-based gameplay progression by exactly 1/2.

- Weapon progression thresholds are halved.
- Level loop length becomes `1500` because the highest enabled tier now ends at `k_max = 1499`.
- Wall brick-type thresholds are halved.
- Wall layer pattern thresholds are halved.
- Weapon-choice trigger is halved from `2000` to `1000`.
- K-based wall shrink speed coefficient is doubled from `0.05` to `0.10` to preserve the same relative difficulty ramp after halving the K scale.

## Weapon Progression Thresholds

| Tier | Weapon | Old K range | New K range |
|---:|---|---:|---:|
| 0 | arrow / 화살 | `0-29` | `0-14` |
| 1 | thunder / 번개 | `30-79` | `15-39` |
| 2 | spark_lance / 스파크 랜스 | `80-149` | `40-74` |
| 3 | volt_storm / 볼트 스톰 | `150-499` | `75-249` |
| 4 | siege_cannon / 시즈 캐논 | `500-2999` | `250-1499` |
| 5 | hybrid_siege placeholder disabled | `3000+` | `1500+` |

## Wall Pattern Thresholds

| Rule | Old | New |
|---|---:|---:|
| `brick_type_for_k`: STRONG starts | `K >= 30` | `K >= 15` |
| `brick_type_for_k`: ARMORED starts | `K >= 80` | `K >= 40` |
| 2-layer `[STRONG, ARMORED]` wall starts | `K >= 150` | `K >= 75` |
| 5-layer siege wall starts | `K >= 500` | `K >= 250` |
| 8-layer wall expansion starts | `K >= 2000` | `K >= 1000` |

## K-Based Speed Ramp

| Rule | Old | New |
|---|---|---|
| Wall shrink speed | `DEFAULT_SHRINK_SPEED + minf(k_value * 0.05, 20.0)` | `DEFAULT_SHRINK_SPEED + minf(k_value * 0.10, 20.0)` |

The `20.0` cap is unchanged. Only the coefficient changed so the speed ramp reaches the same cap at half the K value.

## Intentionally Not Changed

- `RingSpawner.BASE_INTERVAL`
- Brick HP / `BrickRules`
- Damage values / `DamageRules`
- Projectile speed
- Wall retile behavior
- `segment_count_for_radius`
- Wall layer spacing
- Rewarded revive, ads, leaderboard, `SaveManager`, `PlatformBridge`, `RevivePrompt`, and revive state machine
- `CombatProcResolver`
- `WeaponFirePattern`

## Validation Checklist

- `data/progression.json` parses as valid JSON.
- `WeaponChoiceRules.CHOICE_TRIGGER_K` is `1000`.
- `RingSpawnPlanner` uses `0.10` K-speed coefficient.
- No changes were made to forbidden revive/ad/leaderboard files.
- Godot headless main scene load was run.

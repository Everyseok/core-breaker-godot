# Passive SFX Semantic Brief

SFX_SOURCE_SITE: PENDING_USER_PROVIDED_SITE

## Global style target

- Cute arcade pixel action
- Matches existing Core Breaker SFX tone
- Short one-shot sounds
- Low file size
- No harsh realism
- No horror
- No gore
- No realistic firearm audio
- No long cinematic trailers
- No copyrighted/unlicensed source
- OGG Vorbis final format
- Prefer mono
- Target total new SFX size under 800KB if possible, hard cap 2MB

## Existing architecture rule

Passive SFX must be integrated only through:

AudioEvents -> sound_catalog.json -> AudioRouter

No direct AudioStreamPlayer in gameplay/UI/visual scripts.

## stone_throw / 돌 / 투석기

Semantic atoms:
- stone
- wood
- catapult
- toy mechanism
- blunt brick impact
- cute arcade

Launch prompt:
"cute pixel arcade wooden catapult release, short toy thunk, soft mechanical wood click, no realism, no violence, mono one-shot, 0.20 to 0.35 seconds"

Impact prompt:
"cute arcade stone impact on brick, blunt soft knock, short thud, small stone hit, no gore, no heavy explosion, mono one-shot, 0.25 to 0.45 seconds"

Search keywords:
- cute catapult release sfx
- wooden toy thunk
- stone hit brick arcade
- small rock impact brick
- pixel thud stone

Reject if:
- metallic sword
- huge explosion
- realistic injury
- long cinematic boom
- copyrighted pack without license

## meteor / 메테오 / 메테오 대포

Semantic atoms:
- meteor cannon
- ember shell
- cannon-fired projectile
- warm whoosh
- soft ember boom
- brick impact
- arcade fireball

Launch prompt:
"cute fantasy meteor cannon firing ember shell, short warm foom, arcade fireball launch, not sky falling, not cinematic bomb, mono one-shot, 0.30 to 0.55 seconds"

Impact prompt:
"cute pixel ember cannon shell impacts bricks, soft boom with ember pop, warm arcade explosion, rounded low impact, no huge cinematic blast, no harsh clipping, mono one-shot, 0.35 to 0.70 seconds"

Search keywords:
- cute fireball launch sfx
- fantasy cannon foom
- ember projectile impact
- soft fire boom arcade
- pixel fireball hit brick

Reject if:
- falling meteor from sky
- aircraft bomb
- realistic artillery
- bass overload
- harsh explosion
- long cinematic explosion
- copyrighted pack without license

## machine_gun / 기관총 / 장난감 터렛

Semantic atoms:
- toy turret
- drone
- pixel tracer
- arcade tick burst
- mechanical tapping
- tiny brick hit spark
- non-realistic

Burst prompt:
"cute toy turret pixel burst, rapid tick tick tick, arcade mechanical tapping, not realistic gunshot, no military firearm, no shell casing, mono one-shot, 0.20 to 0.40 seconds"

Hit prompt:
"tiny pixel tracer hit on brick, light ping tick, very short arcade impact, not realistic bullet hit, no violence, mono one-shot, 0.08 to 0.18 seconds"

Search keywords:
- cute toy turret burst
- pixel tick burst
- arcade mechanical tapping
- tiny laser hit brick
- soft tracer ping

Reject if:
- realistic gunshot
- rifle
- machine gun realism
- shell casing
- military weapon
- human injury
- blood/gore
- harsh loud shots
- copyrighted pack without license

## Target file names

stone_throw:
- assets/audio/sfx/passives/stone_throw/launch.ogg
- assets/audio/sfx/passives/stone_throw/impact.ogg

meteor:
- assets/audio/sfx/passives/meteor/launch.ogg
- assets/audio/sfx/passives/meteor/impact.ogg

machine_gun:
- assets/audio/sfx/passives/machine_gun/burst.ogg
- assets/audio/sfx/passives/machine_gun/hit.ogg

## Required license record

Every imported file must be recorded in docs/AUDIO_LICENSES.md with:
- final filename
- source site URL
- exact source/generation prompt or search phrase
- license
- author if known
- generation/download date
- modification/compression notes
- whether commercial use is allowed

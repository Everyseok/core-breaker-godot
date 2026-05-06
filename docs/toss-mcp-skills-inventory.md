# Apps in Toss MCP / Skills Inventory

Phase: 0
Date: 2026-05-06
Repo: `/Volumes/JUNSEOKISM_USB3.0/game/game_junseokism.ver1`
Branch: `feature/android-debug-apk-artifact`

## Source Of Truth

- Official guide: https://developers-apps-in-toss.toss.im/development/llms.html
- Apps In Toss skills repo: https://github.com/toss/apps-in-toss-skills
- Local CLI: `/opt/homebrew/bin/ax`
- Local Codex skills:
  - `/Users/junseokism/.codex/skills/docs-search`
  - `/Users/junseokism/.codex/skills/project-validator`

## Connection Result

`ax mcp start` was started over stdio and queried with MCP JSON-RPC.

- CLI version: `ax 0.5.1 (974cb17)`
- MCP server: `ax`
- MCP server version: `0.1.0`
- Protocol version: `2024-11-05`
- Capabilities: `tools`, `prompts`, `resources`, `logging`, `completions`
- Resources exposed: none
- Prompts exposed: `miniapp-action-plan`

## MCP Tools

| Tool | Description | Parameters | Returns | Auth Required | Game Mapping |
|---|---|---|---|---|---|
| `search_docs` | Search Apps-in-Toss Developer Center docs. | `query: string`, `limit?: integer` | Ranked doc snippets with `id`, `title`, `content`, `url`, `category`, `score`; `total`. | No separate auth observed. Requires local `ax`. | Find official requirements for game release, ads, Game Center, safe area, deploy, QA, policy. |
| `get_doc` | Retrieve full Apps-in-Toss document by search result ID. | `id: string` | Full document object with `content`, `url`, metadata. | No separate auth observed. Requires local `ax`. | Pull exact official text before implementing ads, leaderboard, user key, lifecycle, export flow. |
| `list_examples` | List Apps-in-Toss example projects. | none | Example list with `id`, `title`, `content`, `url`, `category`. | No separate auth observed. Requires local `ax`. | Locate official sample projects before platform bridge or ad integration. |
| `get_example` | Retrieve an Apps-in-Toss example by ID. | `example_id: string` | Example content. | No separate auth observed. Requires local `ax`. | Compare official implementation examples with Godot JS bridge wrapper. |
| `search_tds_rn_docs` | Search TDS React Native docs. | `query: string`, `limit?: integer` | Ranked TDS RN snippets. | No separate auth observed. Requires local `ax`. | Mostly not applicable unless RN wrapper is introduced. |
| `get_tds_rn_doc` | Retrieve full TDS React Native doc. | `id: string` | Full TDS RN doc object. | No separate auth observed. Requires local `ax`. | Not primary for current Godot Web build. |
| `search_tds_web_docs` | Search TDS Web docs. | `query: string`, `limit?: integer` | Ranked TDS Web snippets. | No separate auth observed. Requires local `ax`. | Useful if Apps-in-Toss shell/wrapper UI or web landing layer is added. Game UI itself is custom art. |
| `get_tds_web_doc` | Retrieve full TDS Web doc. | `id: string` | Full TDS Web doc object. | No separate auth observed. Requires local `ax`. | Pull exact TDS Web references if a wrapper page or non-game UI component is needed. |

## MCP Prompt

| Prompt | Description | Parameters | Game Mapping |
|---|---|---|---|
| `miniapp-action-plan` | Step-by-step action plan and checklist for Apps-in-Toss mini-app development. | `platform: react-native/web`, `package_manager: npm/pnpm/yarn` | Use as planning input only. Current project is Godot Web export, so official game/WebView docs still govern implementation. |

## Installed Codex Skills

| Skill | Source | Purpose | Game Mapping |
|---|---|---|---|
| `docs-search` | `toss/apps-in-toss-skills/skills/docs-search` | Runs `ax` search/get commands for Apps-in-Toss, TDS Web, and TDS RN docs. | Official-doc lookup before code changes. |
| `project-validator` | `toss/apps-in-toss-skills/skills/project-validator` | Validates Apps-in-Toss web/RN/Unity project config and policy expectations. | Use as a release-readiness validator; Godot Web is not explicitly supported, so findings must be mapped carefully. |

## Current Project Mapping

| Feature Area | Required Source | Current Game Direction |
|---|---|---|
| Ranking user identity | Official docs via `search_docs` / `get_doc`; likely Game Center and user key docs. | Existing `scripts/platform/leaderboard/toss_game_center_bridge.gd` and `scripts/platform/app_in_toss_bridge.gd` must be audited before changes. No custom device ID/UUID. |
| Leaderboard score submit | Official Game Center docs and examples. | Submit only at game-over / max-clear after duplicate-prevention audit. UI must not submit directly. |
| Ads/banner | Official ads docs and examples. | Persistent top banner remains high-risk until official allowed placement and gameplay safe-area resizing are proven. No fake ad UI. |
| Lifecycle | Official visibility/background docs. | Existing `PlatformBridge` background/foreground handling must be checked against official docs. |
| Safe area / viewport | Official design/resolution docs. | Current 390x844 portrait and Godot UI need device QA; banner must not overlap gameplay controls. |
| Submission package | Official deploy/test/checklist docs. | Existing docs/checklists are partial; evidence-linked checklist must be reconciled before submit. |

## Phase 0 Decision

Phase 0 is now **partially passed**:

- Passed: `ax` MCP server exists and exposes Apps-in-Toss documentation tools.
- Passed: Codex Apps-in-Toss skills were installed locally.
- Limitation: MCP provides documentation search/retrieval tools, not direct runtime SDK execution tools for ads, Game Center, or identity.
- Next gate: Phase 1 must use `search_docs` / `get_doc` and official URLs before any implementation.

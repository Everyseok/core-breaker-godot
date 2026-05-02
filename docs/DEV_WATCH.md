# Dev Watch Guide

How to observe development progress in real time from VS Code and Godot.

---

## 1. VS Code — File Explorer

Open the project root in VS Code:
```
code /Volumes/STEM_WORK/game/game_junseokism.ver1
```

### What to watch

| Location | What it tells you |
|----------|------------------|
| `docs/NEXT_STEP.md` | Single current target + acceptance criteria checkboxes |
| `docs/WORKLOG.md` | Append-only log of all completed work |
| `data/dev_status.json` | Machine-readable current phase, task, status, blockers |
| `docs/STATUS.md` | Human summary + risks |
| `scripts/autoload/` | Persistent coordinator/service scripts |
| `scripts/gameplay/` | Core gameplay scripts progress |
| `scenes/` | Scene file presence (any `.tscn` = scene scaffolded) |
| `data/*.json` | Config files present = data layer started |

### Recommended VS Code layout
- Explorer pane open to project root
- Split editor: `NEXT_STEP.md` on left, `WORKLOG.md` on right
- Terminal panel open for Claude session output

---

## 2. VS Code — Source Control / Diffs

If the project is in a git repo (recommended: `git init` at project root):

```bash
git init
git add .
git commit -m "chore: initial docs and scaffold"
```

Then after each Claude session:
- **Source Control panel** shows which files changed
- **Inline diff** (click any changed file) shows exact additions
- `WORKLOG.md` diff shows what the session did
- `data/dev_status.json` diff shows phase/task movement

Without git, use VS Code's **Timeline** view (right-click any file → Open Timeline) to see local file save history.

---

## 3. Claude Terminal / Log Output

At the end of each task session, Claude prints a structured summary in this format:

```
## Session Summary
Files created:   [list]
Files modified:  [list]
Phase:           [current phase name]
Status:          [in-progress | done | blocked]
Next step:       [one sentence]
```

To keep a persistent log, pipe Claude Code output:
```bash
claude >> logs/claude_session.log 2>&1
```

Or watch `data/dev_status.json` — it is updated after each major step and contains the same information in machine-readable form.

---

## 4. Godot Editor — FileSystem Panel

Open the project in Godot:
```
godot /Volumes/STEM_WORK/game/game_junseokism.ver1/project.godot
```

### FileSystem dock (bottom-left by default)
- **`scripts/autoload/`** — five manager `.gd` files present; plus `InputHandler` is also autoloaded from `scripts/gameplay/`
- **`scenes/`** — `.tscn` files present = scenes scaffolded
- **`data/`** — `.json` files present = config layer started
- **`assets/sprites/`** — `.png` or `.aseprite` files = art started

### Scene editor
- Double-click any `.tscn` to open it
- Node count and structure reflect current implementation state

### Output panel (bottom)
- Autoload errors appear here on project run
- Missing resource errors = a file referenced in `project.godot` or a `.tscn` does not exist yet

### Project Settings → Autoload tab
- Lists all registered autoloads
- Green checkmark = script file found; red/missing = script stub not yet created

---

## 5. What Requires Godot Reload

| Change type | Action required |
|-------------|----------------|
| Edit `.gd` script outside Godot | Godot detects changes automatically; no reload needed if project is open |
| Add a new `.gd` file | Godot FileSystem rescans on focus; may need to click **Scan** (FileSystem dock toolbar) |
| Add a new `.tscn` file | Same as above — rescan or Godot auto-detects |
| Add/remove autoload entry in `project.godot` | **Requires project reload**: Project → Reload Current Project |
| Change `project.godot` display/window settings | **Requires project reload** to take effect in editor |
| Add a new `.json` data file | No reload needed; loaded at runtime via `FileAccess` |
| Rename or delete a `.tscn` that another `.tscn` references | Godot shows broken reference; re-link or reload required |
| Add an image asset (`.png`) | Godot auto-imports on focus; no reload needed |
| Change export presets | No reload; takes effect on next export |

---

## 6. Recommended Monitoring Routine

After each Claude session:

1. Check `data/dev_status.json` — confirm phase/task moved forward
2. Read `docs/NEXT_STEP.md` — updated acceptance criteria = what comes next
3. Scan `docs/WORKLOG.md` top entry — confirm what was done
4. Switch to Godot → press **Scan** in FileSystem dock → verify new files appear
5. Run project (F5) — confirm no crash regression
6. If autoloads changed → reload project first (Project → Reload Current Project)

---

## 7. Quick Health Check (one command)

```bash
echo "=== Phase ===" && cat /Volumes/STEM_WORK/game/game_junseokism.ver1/data/dev_status.json | python3 -m json.tool
```

Or simply open `data/dev_status.json` in VS Code — it is kept up to date after every major step.

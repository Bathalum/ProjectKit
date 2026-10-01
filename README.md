# Agent Engineering Project Kit

Portable **Cursor skills** + **Constitution** for repeatable agent-driven builds.

This repo is a **GitHub template**. Skills are **project-local** under `.cursor/skills/` — not installed globally.

**Template:** https://github.com/Bathalum/ProjectKit

## One command (any folder — new or existing project)

Run from the project root. No clone of ProjectKit needed:

```powershell
irm https://raw.githubusercontent.com/Bathalum/ProjectKit/HEAD/scripts/bootstrap.ps1 | iex
```

```bash
curl -fsSL https://raw.githubusercontent.com/Bathalum/ProjectKit/HEAD/scripts/bootstrap.sh | bash
```

Idempotent — safe to re-run any time to pull skill updates or repair links:

| Item | Behaviour |
|---|---|
| `.cursor/skills/` | **Refreshed** from the kit (kit-owned; extra project skills kept) |
| `.cursor/wiki-root` | Created if missing (`docs`) |
| `AGENTS.md` | Created if missing — never overwritten |
| `docs/` wiki | Missing stubs added — existing pages never overwritten |
| `CLAUDE.md` | Created if missing — thin pointer (`@AGENTS.md`) |
| `.claude/skills` | Linked → `.cursor/skills` (symlink, or junction on Windows without Developer Mode) |
| `.gitignore` | Adds `.claude/skills` — the link is per-machine (git on Windows checks symlinks out as text files) |

## For AI agents (Claude Code, Cursor, Codex, …)

Asked to "set up ProjectKit", "use the kit", or "bootstrap this repo"? **Run the one command above** from the project root (PowerShell on Windows, bash elsewhere). Do not hand-copy files. Then:

- Read `AGENTS.md` (the law) and fill `docs/ARCHITECT-BRIEFING.md` + `docs/ARCHITECTURE.md` for the product.
- `.claude/skills` missing after a fresh clone? Re-run the same command — it only repairs what is missing.
- Never edit `Constitution/` as the live wiki; it is the pristine template.

## Use this template (new project)

Prefer this so the new app gets its **own** GitHub repo. Do not develop the product inside this ProjectKit clone — pushes would go back to the template.

### On GitHub

1. Open https://github.com/Bathalum/ProjectKit
2. Click the green **Use this template** button (near **Code**)
3. Choose **Create a new repository**
4. Set owner, name, and public/private
5. Create the repo, then clone **that** new repo and work there

### From the terminal

```powershell
gh repo create MyNewApp --template Bathalum/ProjectKit --private --clone
cd MyNewApp
```

Swap `MyNewApp` / `--private` as you like.

### After creating the repo

1. Instantiate law/wiki + tool bridges with the local script (see `Constitution/BOOTSTRAP.md`):
   - Windows: `powershell -ExecutionPolicy Bypass -File scripts\bootstrap.ps1`
   - macOS/Linux: `bash scripts/bootstrap.sh`
2. Keep `.cursor/wiki-root` as `docs` (already set for greenfield).
3. Open the project in Cursor or Claude Code; use:
   - `/brainstorming` → spec  
   - writing-plans → plan  
   - TDD to implement  
   - `/sync-docs` to maintain the wiki  

## Updating the template

You can keep pushing lessons and skill improvements to **this** repo (`Bathalum/ProjectKit`). New “Use this template” repos get a snapshot at creation time; existing projects pull skill updates by re-running the one command.

## Contents

```
ProjectKit/
├── .cursor/
│   ├── wiki-root          # default: docs
│   └── skills/            # brainstorming, writing-plans, TDD, sync-docs (SSOT)
├── scripts/
│   ├── bootstrap.ps1      # one-command setup (Windows PowerShell)
│   └── bootstrap.sh       # one-command setup (bash / Git Bash)
└── Constitution/
    ├── AGENTS.md          # law template
    ├── BOOTSTRAP.md       # how to instantiate
    └── docs/              # wiki stubs (hubs + spoke templates)
```

## Monorepo

If the living wiki is not at repo-root `docs/`, set `.cursor/wiki-root` to that path (e.g. `packages/app/docs`).

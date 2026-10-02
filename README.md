# Agent Engineering Project Kit

Portable **agent skills** + **Constitution** for repeatable agent-driven builds — for **Claude Code**, **Cursor**, or both.

This repo is a **GitHub template**. Skills are **project-local** (`.claude/skills/` or `.cursor/skills/`) — not installed globally.

**Template:** https://github.com/Bathalum/ProjectKit

## One command (any folder — new or existing project)

Run from the project root. No clone of ProjectKit needed. Pick the tool the project uses:

**Claude Code**

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/Bathalum/ProjectKit/HEAD/scripts/bootstrap.ps1))) claude
```

```bash
curl -fsSL https://raw.githubusercontent.com/Bathalum/ProjectKit/HEAD/scripts/bootstrap.sh | bash -s -- claude
```

**Cursor**

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/Bathalum/ProjectKit/HEAD/scripts/bootstrap.ps1))) cursor
```

```bash
curl -fsSL https://raw.githubusercontent.com/Bathalum/ProjectKit/HEAD/scripts/bootstrap.sh | bash -s -- cursor
```

**Both** (default when no tool is given — Cursor owns the skills, Claude Code links to them)

```powershell
irm https://raw.githubusercontent.com/Bathalum/ProjectKit/HEAD/scripts/bootstrap.ps1 | iex
```

```bash
curl -fsSL https://raw.githubusercontent.com/Bathalum/ProjectKit/HEAD/scripts/bootstrap.sh | bash
```

What each mode writes:

| Item | `claude` | `cursor` | `both` |
|---|---|---|---|
| Skills (refreshed from kit; extra project skills kept) | `.claude/skills/` | `.cursor/skills/` | `.cursor/skills/` (SSOT) |
| `.cursor/wiki-root` (`docs`) | — | if missing | if missing |
| `AGENTS.md` | if missing | if missing (Cursor reads it natively) | if missing |
| `docs/` wiki stubs | missing ones only | missing ones only | missing ones only |
| `CLAUDE.md` thin pointer (`@AGENTS.md`) | if missing | — | if missing |
| `.claude/skills` link → `.cursor/skills` | — | — | symlink / junction, git-ignored |
| `.gitattributes` (`*.sh` LF, `*.ps1` CRLF — missing lines only) | yes | yes | yes |
| `.gitignore` brainstorm sessions | `.claude/brainstorm/` | `.cursor/brainstorm/` | both |

Idempotent — re-run any time to pull skill updates or repair what is missing. It never overwrites `AGENTS.md`, wiki pages, or `CLAUDE.md`, and never deletes the other tool's files (it prints a note instead). Switching `both` → `claude` turns the link into a real folder and drops the `.gitignore` entry.

## For AI agents (Claude Code, Cursor, Codex, …)

Asked to "set up ProjectKit", "use the kit", or "bootstrap this repo"? **Run the one command for your own tool** from the project root (PowerShell on Windows, bash elsewhere) — Claude Code → `claude`, Cursor → `cursor`, unsure or mixed team → no argument (`both`). Do not hand-copy files. Then:

- Read `AGENTS.md` (the law) and fill `docs/ARCHITECT-BRIEFING.md` + `docs/ARCHITECTURE.md` for the product.
- Skills missing after a fresh clone (e.g. the `both` link)? Re-run the same command — it only repairs what is missing.
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
   - Windows: `powershell -ExecutionPolicy Bypass -File scripts\bootstrap.ps1 [claude|cursor|both]`
   - macOS/Linux: `bash scripts/bootstrap.sh [claude|cursor|both]`
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
│   └── skills/            # brainstorming, writing-plans, TDD, sync-docs (kit source for every mode)
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

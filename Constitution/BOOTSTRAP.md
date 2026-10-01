# Bootstrap — new project from this constitution kit

Use this when copying the **template** into a new GitHub repo / workspace. Skills stay **project-local** under `.cursor/skills/` — not global.

## Fastest path — one command

From the project root (new or existing project; idempotent):

```powershell
irm https://raw.githubusercontent.com/Bathalum/ProjectKit/HEAD/scripts/bootstrap.ps1 | iex
```

```bash
curl -fsSL https://raw.githubusercontent.com/Bathalum/ProjectKit/HEAD/scripts/bootstrap.sh | bash
```

In a repo created from the template, run the local copy instead (`scripts/bootstrap.ps1` / `scripts/bootstrap.sh`).
The script does everything below; the manual steps remain the reference.

## What to copy from the template

```
.cursor/
  wiki-root          # usually one line: docs
  skills/            # brainstorming, writing-plans, TDD, sync-docs, _paths.md
AGENTS.md            # from Constitution/AGENTS.md (live law)
docs/                # from Constitution/docs/ (wiki stubs)
CLAUDE.md            # tool bridge: thin pointer → AGENTS.md (@AGENTS.md)
.claude/skills       # tool bridge: link → .cursor/skills (git-ignored, per machine)
Constitution/        # optional: keep as pristine template, or omit if AGENTS+docs already instantiated
```

## Steps

1. Create empty repo; copy the kit above.
2. Set `.cursor/wiki-root` to `docs` (greenfield default).
3. Fill `docs/ARCHITECT-BRIEFING.md` and `docs/ARCHITECTURE.md` stubs for the new product.
4. Open the project in Cursor or Claude Code — skills load from **this repo’s** `.cursor/skills/` (Claude Code via the `.claude/skills` link).
5. Workflow: `/brainstorming` → spec → `/writing-plans` → implement with TDD → `/sync-docs` to maintain the wiki.

## Tool bridges (Claude Code)

Per `AGENTS.md` "Tool bridge": tool-native files point at the SSOT, never fork it.

- `CLAUDE.md` — contains `@AGENTS.md` so Claude Code loads the law every session.
- `.claude/skills` — directory link to `.cursor/skills` so Claude Code sees the same skills. Symlink where allowed; NTFS junction on Windows without Developer Mode/admin. **Git-ignored**: git on Windows checks committed symlinks out as plain text files, so each clone recreates the link by re-running the bootstrap script.

## Monorepo exception

If the living wiki is not at repo-root `docs/` (e.g. app package owns the wiki):

```
.cursor/wiki-root    →  packages/app/docs   (example)
```

Place `AGENTS.md` as sibling of that docs tree when possible (`packages/app/AGENTS.md`).

## Do not

- Install these skills into `~/.cursor/skills` for “all projects” unless you intentionally want globals.
- Hardcode product names into skills — use `_paths.md` resolution only.
- Edit `Constitution/` as the live wiki; instantiate into `AGENTS.md` + `docs/` (or package paths).

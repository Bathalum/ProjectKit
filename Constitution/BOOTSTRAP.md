# Bootstrap — new project from this constitution kit

Use this when copying the **template** into a new GitHub repo / workspace. Skills stay **project-local** (`.claude/skills/` or `.cursor/skills/`) — not global.

## Fastest path — one command

From the project root (new or existing project; idempotent). Tool = `claude`, `cursor`, or omit for `both`:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/Bathalum/ProjectKit/HEAD/scripts/bootstrap.ps1))) claude
```

```bash
curl -fsSL https://raw.githubusercontent.com/Bathalum/ProjectKit/HEAD/scripts/bootstrap.sh | bash -s -- claude
```

In a repo created from the template, run the local copy instead (`scripts/bootstrap.ps1 <tool>` / `scripts/bootstrap.sh <tool>`).
The script does everything below; the manual steps remain the reference.

## What to copy from the template

Common to every tool:

```
AGENTS.md            # from Constitution/AGENTS.md (live law)
docs/                # from Constitution/docs/ (wiki stubs)
Constitution/        # optional: keep as pristine template, or omit if AGENTS+docs already instantiated
```

Per tool:

| Tool | Skills | Extra |
|---|---|---|
| `claude` | `.claude/skills/` ← kit `.cursor/skills/` | `CLAUDE.md` thin pointer (`@AGENTS.md`) |
| `cursor` | `.cursor/skills/` | `.cursor/wiki-root` (`docs`) — Cursor reads `AGENTS.md` natively |
| `both` | `.cursor/skills/` (SSOT) | `.cursor/wiki-root`, `CLAUDE.md`, `.claude/skills` link → `.cursor/skills` (git-ignored) |

Every tool also gets `.gitattributes` lines `*.sh text eol=lf` / `*.ps1 text eol=crlf` (added only if missing) so the skills' shell scripts survive Windows checkouts. It also git-ignores the brainstorm visual-companion session folder (`<tool-dir>/brainstorm/`).

## Steps

1. Create empty repo; copy the kit above for your tool.
2. Wiki root defaults to `docs` (`.cursor/wiki-root` or `.claude/wiki-root` only needed to override).
3. Fill `docs/ARCHITECT-BRIEFING.md` and `docs/ARCHITECTURE.md` stubs for the new product.
4. Open the project in Claude Code or Cursor — skills load from **this repo's** skills folder.
5. Workflow: `/brainstorming` → spec → `/writing-plans` → implement with TDD → `/sync-docs` to maintain the wiki.

## Tool bridges

Per `AGENTS.md` "Tool bridge": tool-native files point at the SSOT, never fork it.

- **Cursor** — reads `AGENTS.md` natively; no bridge file.
- **Claude Code** — `CLAUDE.md` contains `@AGENTS.md` so the law loads every session.
- **Both** — `.claude/skills` is a directory link to `.cursor/skills` so both tools share one copy. Symlink where allowed; NTFS junction on Windows without Developer Mode/admin. **Git-ignored**: git on Windows checks committed symlinks out as plain text files, so each clone recreates the link by re-running the bootstrap script.

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

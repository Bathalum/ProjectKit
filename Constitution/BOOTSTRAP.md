# Bootstrap — new project from this constitution kit

Use this when copying the **template** into a new GitHub repo / workspace. Skills stay **project-local** under `.cursor/skills/` — not global.

## What to copy from the template

```
.cursor/
  wiki-root          # usually one line: docs
  skills/            # brainstorming, writing-plans, TDD, sync-docs, _paths.md
AGENTS.md            # from Constitution/AGENTS.md (live law)
docs/                # from Constitution/docs/ (wiki stubs)
Constitution/        # optional: keep as pristine template, or omit if AGENTS+docs already instantiated
```

## Steps

1. Create empty repo; copy the kit above.
2. Set `.cursor/wiki-root` to `docs` (greenfield default).
3. Fill `docs/ARCHITECT-BRIEFING.md` and `docs/ARCHITECTURE.md` stubs for the new product.
4. Open the project in Cursor — skills load from **this repo’s** `.cursor/skills/`.
5. Workflow: `/brainstorming` → spec → `/writing-plans` → implement with TDD → `/sync-docs` to maintain the wiki.

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

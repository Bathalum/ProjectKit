# Wiki & law path resolution (project-local)

Cursor skills in this repo are **path-agnostic**. They must not hardcode a product name (e.g. Spindle). Resolve paths at the start of every skill run.

## Resolve `WIKI_ROOT`

First match wins:

1. **`.cursor/wiki-root`** — file at the project/workspace root (next to `.cursor/skills/`). First non-empty, non-`#` comment line = relative path to the living wiki (e.g. `docs` or `spindle/docs`).
2. Else if **`docs/ARCHITECTURE.md`** exists → `WIKI_ROOT = docs`
3. Else if **`AGENTS.md`** exists at repo root and clearly points at a docs tree → use that directory
4. Else if exactly one `*/docs/ARCHITECTURE.md` exists (e.g. `spindle/docs/ARCHITECTURE.md`) → use that `*/docs`
5. Else → **`docs`** (create on bootstrap)

## Derived paths

| Artifact | Path |
|---|---|
| Living wiki hubs | `{WIKI_ROOT}/ARCHITECTURE.md`, `SYSTEMS.md`, `ORCHESTRATIONS.md`, `FRONTEND.md`, `PERSISTENCE.md`, `SECURITY.md`, `ARCHITECT-BRIEFING.md` |
| Spokes | `{WIKI_ROOT}/systems/`, `orchestrations/`, `frontend/`, `persistence/`, `security/` |
| Specs | `{WIKI_ROOT}/specs/YYYY-MM-DD-<slug>-spec.md` |
| Plans | `{WIKI_ROOT}/plans/YYYY-MM-DD-<slug>-plan.md` |
| Lessons | `{WIKI_ROOT}/plans/lessons.md` |
| RCA | `{WIKI_ROOT}/rca/` |
| Archive | `{WIKI_ROOT}/archive/` |

## Resolve `AGENTS_LAW`

1. `{WIKI_ROOT}/../AGENTS.md` if that file exists (wiki sibling — e.g. `spindle/AGENTS.md` when wiki is `spindle/docs`)
2. Else repo-root `AGENTS.md`
3. Else `Constitution/AGENTS.md` (template only — instantiate before treating as live law)

## Project vs global

These skills live under **`.cursor/skills/` in the project** (or a GitHub template you copy). Do **not** install them as `~/.cursor/skills` unless the user explicitly asks — the intended model is a **per-project template**, not a global Cursor install.

## Template default

Ship `.cursor/wiki-root` with `docs`. Greenfield projects need no change.

## Monorepo override

If the living wiki lives under a package (not repo-root `docs/`), set `.cursor/wiki-root` to that relative path (example: `packages/app/docs` or `spindle/docs`).

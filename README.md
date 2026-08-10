# Agent Engineering Project Kit

Portable **Cursor skills** + **Constitution** for repeatable agent-driven builds.

Copy this folder into a new repo (or use as a GitHub template). Skills are **project-local** under `.cursor/skills/` — not installed globally.

## Contents

```
ProjectKit/
├── .cursor/
│   ├── wiki-root          # default: docs
│   └── skills/            # brainstorming, writing-plans, TDD, sync-docs
└── Constitution/
    ├── AGENTS.md          # law template
    ├── BOOTSTRAP.md       # how to instantiate
    └── docs/              # wiki stubs (hubs + spoke templates)
```

## Quick start (new project)

1. Copy `.cursor/` and instantiate law/wiki (see `Constitution/BOOTSTRAP.md`):
   - `AGENTS.md` ← from `Constitution/AGENTS.md`
   - `docs/` ← from `Constitution/docs/`
   - Optional thin `CLAUDE.md` → `AGENTS.md`
2. Keep `.cursor/wiki-root` as `docs` (already set for greenfield).
3. Open the project in Cursor; use:
   - `/brainstorming` → spec  
   - writing-plans → plan  
   - TDD to implement  
   - `/sync-docs` to maintain the wiki  

## Monorepo

If the living wiki is not at repo-root `docs/`, set `.cursor/wiki-root` to that path (e.g. `packages/app/docs`).

## Note

This kit was copied from a working monorepo. Originals there are unchanged — this directory is yours to move to GitHub.

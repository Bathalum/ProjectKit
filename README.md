# Agent Engineering Project Kit

Portable **Cursor skills** + **Constitution** for repeatable agent-driven builds.

This repo is a **GitHub template**. Skills are **project-local** under `.cursor/skills/` — not installed globally.

**Template:** https://github.com/Bathalum/ProjectKit

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

1. Instantiate law/wiki (see `Constitution/BOOTSTRAP.md`):
   - `AGENTS.md` ← from `Constitution/AGENTS.md`
   - `docs/` ← from `Constitution/docs/`
   - Optional thin `CLAUDE.md` → `AGENTS.md`
2. Keep `.cursor/wiki-root` as `docs` (already set for greenfield).
3. Open the project in Cursor; use:
   - `/brainstorming` → spec  
   - writing-plans → plan  
   - TDD to implement  
   - `/sync-docs` to maintain the wiki  

## Updating the template

You can keep pushing lessons and skill improvements to **this** repo (`Bathalum/ProjectKit`). New “Use this template” repos get a snapshot at creation time; existing projects do not auto-update.

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

## Monorepo

If the living wiki is not at repo-root `docs/`, set `.cursor/wiki-root` to that path (e.g. `packages/app/docs`).

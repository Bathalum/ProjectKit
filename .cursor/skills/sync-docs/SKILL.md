---
name: sync-docs
description: >-
  Maintains the project constitution wiki (hubs, spokes, drill-downs) so it
  matches codebase truth. Use for /sync-docs, wiki maintenance, or full
  architecture-doc reconciliation. Resolves wiki root via _paths.md (default
  docs/; project override via .cursor/wiki-root). Does not edit Constitution/
  template, archive, or specs/plans/rca.
---

# Sync Docs — Constitution Wiki Maintenance

**This is the skill you turn on to maintain the living documentation architecture.**

**Before any read/write:** resolve `WIKI_ROOT` and `AGENTS_LAW` per [`../_paths.md`](../_paths.md).

You own the **constitution wiki** under `{WIKI_ROOT}`:

- Hubs stay indexes; depth lives in spokes
- Drill-downs are linked, complete, and in the right layer
- Every living page reflects **current codebase truth**

Escalate deadlocks to the **user**.

---

## Responsibility

A `/sync-docs` run **must**:

1. **Maintain wiki shape** — Architecture → Systems / Orchestrations / Frontend / Persistence / Security → spokes  
2. **Reconcile truth** — living pages match code  
3. **Repair structure** — create missing spokes, fix indexes/links, move misplaced detail  
4. **Report** — changes, removals, user judgments  

Default scope = **full living wiki** under `{WIKI_ROOT}` unless the user scopes it.

---

## Core Principles

| Principle | Meaning |
|---|---|
| **No stale docs** | Code pivoted → docs pivot visibly |
| **Snapshot, not diary** | History → `specs/` / `plans/` / `rca/` / `archive/` (link only) |
| **One home per fact** | Right DDD layer |
| **Hub indexes; spokes deepen** | Broken drill-down = incomplete run |

---

## Living wiki map (under `{WIKI_ROOT}`)

```
{WIKI_ROOT}/
├── ARCHITECTURE.md
├── ARCHITECT-BRIEFING.md
├── SYSTEMS.md          → systems/<context>.md
├── ORCHESTRATIONS.md   → orchestrations/<flow>.md
├── FRONTEND.md         → frontend/<surface>.md
├── PERSISTENCE.md      → persistence/<area>.md
└── SECURITY.md         → security/tenancy.md (+ other security spokes)
```

| File | Owns |
|---|---|
| `ARCHITECTURE.md` | Thin structure SSOT + layer pointers |
| `SYSTEMS.md` + `systems/*` | Domain |
| `ORCHESTRATIONS.md` + `orchestrations/*` | Application |
| `FRONTEND.md` + `frontend/*` | Presentation / Atomic Design |
| `PERSISTENCE.md` + `persistence/*` | Infrastructure |
| `SECURITY.md` + `security/*` | Trust (security + tenancy) |
| `ARCHITECT-BRIEFING.md` | Where we are / going / how we work |

**Report-only unless asked:** path fixes in `AGENTS_LAW`.

---

## Out of scope (never edit)

| Path | Why |
|---|---|
| `Constitution/**` | Template, not live wiki |
| `{WIKI_ROOT}/archive/**` | Raw history |
| `{WIKI_ROOT}/specs/**`, `plans/**`, `rca/**` | Build artifacts |
| `{WIKI_ROOT}/BACKLOG.md` | Separate ownership |
| Repo-root monorepo essays (e.g. `docs/MONOREPO.md` when wiki is elsewhere) | Unless user explicitly includes |

If archive still holds unique **current** truth → **report** harvest into hubs/spokes; do not edit archive here.

---

## Briefing carve-out

- Auto-fix orientation / pointer sections  
- **Report-only:** How We Work collaboration preferences  
- No structural duplication of Architecture/layer hubs  

---

## Protocol

1. **Resolve paths** — [`../_paths.md`](../_paths.md)  
2. **Structure audit** — layer map, hub↔spoke links, missing/orphan spokes, wrong-layer detail, hub bloat  
3. **Truth audit** — code vs each living target  
4. **Reconcile** — structure then content; snapshot style; update dates  
5. **Re-audit** — max 3 iters; deadlock → user  
6. **Report** — structure actions, pivots, harvest suggestions, deadlocks  

---

## Triggers

`/sync-docs` · “sync docs” · “maintain the wiki” · “reconcile docs with code” · after structural lands

## What NOT to do

- Leave broken drill-downs  
- Preserve stale content for nostalgia  
- Edit `Constitution/` as live SSOT  
- Turn hubs into changelogs  
- Call complete after one file if the wiki map is still inconsistent  

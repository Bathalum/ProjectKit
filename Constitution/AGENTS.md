# AGENTS.md — Agent Engineering Constitution

This file is the highest-level law for how agents build and maintain software
under this constitution. It is tool-agnostic (Cursor, Claude Code, Codex, etc.).

**Project detail lives in the wiki under `docs/` — not here.**
This file states *what must be true* and *where to look*. The wiki holds *what is*.

If a change violates this constitution, stop and re-plan.

---

## 0. Prime Directive

**One Spine, One Flow, Clear Handovers, No Leaks, No Smells.**

This is right-sized DDD. It is structural law, not a vibe:

| Mantra | Meaning |
|---|---|
| **One Spine** | Every shared operation/state has exactly ONE owner. Consumers ask the owner; nobody rebuilds a derived view. |
| **One Flow** | One pipeline per concern. No side-channel state between stages. |
| **Clear Handovers** | Boundaries crossed ONLY via typed contracts / ports / facades. |
| **No Leaks** | No secrets in logs/prompts; no internal state across a bounded-context fence; no cross-tenant data bleed. |
| **No Smells** | No duplicated spines, forked pattern copies, or allowlist→blocklist conversions. |

### Vocabulary (use these terms)

- **Bounded Context** — outermost fence; one model/language inside; crossed only via ports.
- **Module** — folder/package inside a context; organizes code; owns no consistency rules.
- **Aggregate** — consistency boundary for shared mutable state; exactly ONE writer (sole-writer / lifecycle).
- **Aggregate Root** — identity-keyed front of an aggregate; all access goes through it (registry = read, lifecycle = write).
- **Port & Adapter** — port = typed contract; adapter = implementation across the fence. Cross-context traffic is port→adapter ONLY.

Detail & current map: [`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md) · domain inventory: [`docs/SYSTEMS.md`](./docs/SYSTEMS.md)

### Standing review questions (every spec / plan / review)

1. Does this create a NEW bounded context? (Rare — justify.)
2. Which aggregate owns any new state? Is there exactly ONE writer?
3. Does anything cross a fence except via a typed contract/facade?
4. Is judgment being made by deterministic machinery? Move it to the model.
5. Is any spine being duplicated instead of extracted-and-shared?
6. Does this respect the trust plane (auth, secrets, tenant isolation)? See [`docs/SECURITY.md`](./docs/SECURITY.md)

### Enforcement trio

1. **Canon docs** = the law ([`docs/`](./docs/))
2. **Lint / import fences** = the fence
3. **Tests / grep-proofs** = the audit

Structure first as document, then enforced as code (strangler: extract owner → repoint consumers → prove single home).

### Judgment vs mechanism

If it requires judgment, the **model** decides (with real schemas in view).  
If it is mechanical, it is **deterministic machinery**.  
No stage guesses intent on the model's behalf unless behind an explicit invocation door.

---

## 1. Presentation Law — Atomic Design (always)

All UI / presentation structure follows **Atomic Design**. No exceptions. Framework-agnostic.

| Layer | Owns |
|---|---|
| **Atoms** | Irreducible UI primitives (button, input, label, icon) |
| **Molecules** | Simple combinations of atoms (search field, form row) |
| **Organisms** | Distinct UI sections (header, board, pane) |
| **Templates** | Page-level layout slots without real content |
| **Pages / Routes** | Concrete compositions wired to data |

Rules:
- Do not invent parallel component taxonomies.
- Prefer compose-up over one-off mega-components.
- Routes and feature folders must map cleanly onto this hierarchy.

Inventory & conventions: [`docs/FRONTEND.md`](./docs/FRONTEND.md) · spokes: [`docs/frontend/`](./docs/frontend/)

Everything non-UI remains governed by the Prime Directive.

---

## 2. Documentation Wiki Law (Karpathy-shaped second brain)

Docs are a **compiled wiki**, not a changelog dump and not a second RAG store.
Agents maintain the wiki as current-state memory. History lives in build artifacts.

### Required canon map

| File | Layer | Role |
|---|---|---|
| [`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md) | Structure SSOT | **Current** build shape only. No history logs. Points at layer docs. |
| [`docs/ARCHITECT-BRIEFING.md`](./docs/ARCHITECT-BRIEFING.md) | Where we are / going / how we work | Operational SSOT. Updates reference build tickets. |
| [`docs/SYSTEMS.md`](./docs/SYSTEMS.md) | Domain (index) | Bounded contexts, aggregates, roots, ports — concise. Deep detail in `docs/systems/`. |
| [`docs/ORCHESTRATIONS.md`](./docs/ORCHESTRATIONS.md) | Application (index) | Pipelines, flows, request lifecycles. Spokes in `docs/orchestrations/`. |
| [`docs/FRONTEND.md`](./docs/FRONTEND.md) | Presentation (index) | UI under Atomic Design. Spokes in `docs/frontend/`. |
| [`docs/PERSISTENCE.md`](./docs/PERSISTENCE.md) | Infrastructure (index) | DB, APIs, MCP/external adapters, IO. Spokes in `docs/persistence/`. |
| [`docs/SECURITY.md`](./docs/SECURITY.md) | Trust plane (index) | **Security + Tenancy** — auth, secrets, isolation, trust boundaries. Spokes in `docs/security/`. |

### Hub → spoke drill-down

- **Hub** = index: enough to orient; no novel history.
- **Spoke** = current mechanics: purpose, relations, inputs, outputs, named functions/modules, producers/consumers.
- **Current snapshot only** in hubs and spokes.
- **History, decisions, errors, fixes** live in build artifacts; spokes **reference** them — they do not absorb them.

### Build artifacts (history / raw layer)

| Path | Purpose |
|---|---|
| [`docs/specs/`](./docs/specs/) | Approved design specs |
| [`docs/plans/`](./docs/plans/) | Implementation / working plans |
| [`docs/plans/lessons.md`](./docs/plans/lessons.md) | Self-improvement patterns after corrections |
| [`docs/rca/`](./docs/rca/) | Trace-first root-cause reports |

### Wiki maintenance rules

1. On a landed change: update affected **current-state** page(s); do not append a diary to Architecture/Systems/Security.
2. Link the creating **spec / plan / outcome**; do not paste their changelog into the wiki page.
3. Prefer short pages; split when a page owns more than one concept.
4. Periodically lint: contradictions, orphans, broken links, stale claims vs code.

---

## 3. Implementation Law — TDD always

**Test-Driven Development is mandatory** for every code change: domain, aggregate, button, route, adapter — all of it.

- Red → green → refactor.
- If you are about to write production code without a failing test first: **stop**.
- Untested code is a weak link and a downstream defect by definition.

How this shows up in the session checklist: §5 step 5.

---

## 4. Workflow Laws

### 4.1 Plan Mode Default

- Enter plan mode for any non-trivial task (3+ steps or architectural decisions).
- If work goes sideways: **STOP and re-plan** — do not push.
- Use plan mode for verification design, not only building.
- Write a clear spec before implementation when ambiguity remains.
- Prefer brainstorming before creative/feature work.

### 4.2 Subagent Strategy

- Use subagents liberally to keep the main context clean.
- Offload research, exploration, and parallel analysis.
- **One task per subagent.**

### 4.3 Self-Improvement Loop

- After any user correction: update [`docs/plans/lessons.md`](./docs/plans/lessons.md) with the pattern.
- Write a rule that prevents the same mistake.
- Review lessons at session start for the relevant project.

### 4.4 Autonomous Bug Fixing

- Given a bug: **fix it**. Do not ask for hand-holding.
- Point at logs, errors, failing tests — then resolve.
- Fix failing CI without being told how.
- Prefer root cause over symptom patches.
- Second failed fix on the same bug → escalate to trace-first RCA (logs first; write-up in `docs/rca/`).

### 4.5 Plan / Task Management

Working plans live under [`docs/plans/`](./docs/plans/) (not a parallel `tasks/` spine).

1. **Plan first** — checkable items in the active plan file.
2. **Verify plan** with the user before implementation when scope is non-trivial.
3. **Track progress** — mark items complete as you go.
4. **Explain changes** — high-level summary at each step.
5. **Document results** — review section on the plan; update wiki current-state pages.
6. **Capture lessons** — [`docs/plans/lessons.md`](./docs/plans/lessons.md).

Definition of done is owned by the active plan / goal loop.

### 4.6 Core craft

- **Simplicity First** — smallest change that satisfies the law.
- **No Laziness** — root causes; no temporary fixes as the end state.
- **Minimal Impact** — touch only what is necessary.

---

## 5. How to use this file

Operational checklist for every session. Follow in order unless the active plan says otherwise.

1. **Read this constitution** — Prime Directive, Atomic Design, TDD, wiki map.
2. **Orient** — open [`docs/ARCHITECT-BRIEFING.md`](./docs/ARCHITECT-BRIEFING.md) (where we are / going / how we work).
3. **Structure** — open [`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md); follow links into the layer that owns your change:
   - Domain → [`SYSTEMS.md`](./docs/SYSTEMS.md) → `docs/systems/<context>.md`
   - Application → [`ORCHESTRATIONS.md`](./docs/ORCHESTRATIONS.md) → `docs/orchestrations/`
   - Presentation → [`FRONTEND.md`](./docs/FRONTEND.md) → `docs/frontend/`
   - Infrastructure → [`PERSISTENCE.md`](./docs/PERSISTENCE.md) → `docs/persistence/`
   - Trust (security + tenancy) → [`SECURITY.md`](./docs/SECURITY.md) → `docs/security/`
4. **Plan** — write/update a plan under [`docs/plans/`](./docs/plans/); answer the standing review questions (§0).
5. **Implement with TDD** — failing test first, then code, then refactor. No production code without a test. UI work still obeys Atomic Design (§1). See §3.
6. **Land in the wiki** — update current-state hubs/spokes; link the spec/plan; do not paste history into SSOT pages.
7. **Learn** — on any correction, update [`docs/plans/lessons.md`](./docs/plans/lessons.md).

### Tool bridge

Keep this file as SSOT. If a tool requires a native file (e.g. `CLAUDE.md`), make that file a thin pointer/import to this constitution — **do not fork the law**.

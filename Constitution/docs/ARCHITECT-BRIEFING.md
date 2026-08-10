# Architect Briefing — Where We Are / Going / How We Work

> **Role:** Operational SSOT — position, direction, working agreements.  
> **Not for:** Full structural maps (that is Architecture) or deep mechanics (layer spokes).  
> **Parent law:** [`../AGENTS.md`](../AGENTS.md)  
> **Structure companion:** [`ARCHITECTURE.md`](./ARCHITECTURE.md)

---

## Purpose

| Question | Answer lives here? | Else |
|---|---|---|
| Where are we now? | Yes — Current Position | — |
| Where are we going? | Yes — Direction / roadmap signals | — |
| How do we work? | Yes — pointers + norms | Detail in AGENTS.md |
| What is the structural map? | No | [`ARCHITECTURE.md`](./ARCHITECTURE.md) |
| How does system X work? | No | [`SYSTEMS.md`](./SYSTEMS.md) + spokes |

Updates to this briefing **must reference build tickets** (spec / plan / outcome IDs).

---

## 1. Current Position

<!-- Snapshot only. Bullet the live truth. Link tickets; do not paste full changelogs. -->

- **Status:** _TBD (bootstrap)_
- **Last meaningful land:** _none yet — constitution scaffold_
- **Open focus:** _TBD_

### Recent lands (pointers only)

| Ticket | One-line result | Spec / Plan |
|---|---|---|
| — | — | — |

---

## 2. Where We Are Going

<!-- Signals, milestones, non-goals. Keep short; backlog may live elsewhere and be linked. -->

1. _TBD_
2. _TBD_

**Non-goals (for now):** _TBD_

---

## 3. How We Work

Law is in [`../AGENTS.md`](../AGENTS.md). This section only orients:

| Concern | Canon |
|---|---|
| Prime Directive + DDD vocabulary | AGENTS.md §0 · Architecture |
| Atomic Design | AGENTS.md §1 · Frontend |
| TDD | AGENTS.md §3 · session checklist §5 |
| Wiki maintenance | AGENTS.md §2 |
| Trust (security + tenancy) | [`SECURITY.md`](./SECURITY.md) |
| Active plans / lessons | [`plans/`](./plans/) · [`plans/lessons.md`](./plans/lessons.md) |

---

## 4. Where Everything Lives

| Looking for | Canonical home |
|---|---|
| Structure | [`ARCHITECTURE.md`](./ARCHITECTURE.md) |
| Domain mechanics | [`SYSTEMS.md`](./SYSTEMS.md) → `systems/` |
| Pipelines / lifecycles | [`ORCHESTRATIONS.md`](./ORCHESTRATIONS.md) → `orchestrations/` |
| UI | [`FRONTEND.md`](./FRONTEND.md) → `frontend/` |
| DB / APIs / MCP / externals | [`PERSISTENCE.md`](./PERSISTENCE.md) → `persistence/` |
| Auth / secrets / tenancy | [`SECURITY.md`](./SECURITY.md) → `security/` |
| Specs | [`specs/`](./specs/) |
| Plans + lessons | [`plans/`](./plans/) |
| RCA | [`rca/`](./rca/) |

---

## Update rule

When a ticket lands: refresh §1 (and §2 if direction changed); cite the ticket. Do not duplicate Architecture or Systems content here.

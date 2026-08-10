# Architecture — Structure SSOT

> **Role:** Current-shape map of the whole system.  
> **Not for:** History, decision diaries, RCA narratives, ticket changelogs.  
> **Parent law:** [`../AGENTS.md`](../AGENTS.md)

When something is replaced, **rewrite this page** to the new truth. Do not keep a fossil record here — that lives in `specs/` / `plans/` / `rca/`.

---

## Purpose

This document answers: *What exists right now, and how do the pieces relate?*

Layer depth lives in the layer docs. Architecture only names the pieces and points.

---

## Layer map (DDD)

| Layer | Canon hub | Drill-down |
|---|---|---|
| Domain | [`SYSTEMS.md`](./SYSTEMS.md) | [`systems/`](./systems/) |
| Application | [`ORCHESTRATIONS.md`](./ORCHESTRATIONS.md) | [`orchestrations/`](./orchestrations/) |
| Presentation | [`FRONTEND.md`](./FRONTEND.md) | [`frontend/`](./frontend/) |
| Infrastructure | [`PERSISTENCE.md`](./PERSISTENCE.md) | [`persistence/`](./persistence/) |
| Trust (Security + Tenancy) | [`SECURITY.md`](./SECURITY.md) | [`security/`](./security/) |

Operational state (where we are / going): [`ARCHITECT-BRIEFING.md`](./ARCHITECT-BRIEFING.md)

---

## System overview

<!-- Replace with the project's current high-level diagram or bullet map. Keep short. -->

```
[ Presentation / Frontend ]
           ↓
[ Application / Orchestrations ]
           ↓
[ Domain / Systems ]  ←→  [ Trust / Security+Tenancy ]
           ↓
[ Infrastructure / Persistence ]
```

---

## Bounded contexts (current)

<!-- Concise roster only. Detail → SYSTEMS.md + systems/<name>.md -->

| Context | One-line role | Spoke |
|---|---|---|
| _TBD_ | _TBD_ | [`systems/_TEMPLATE.md`](./systems/_TEMPLATE.md) |

---

## Dependency / fence rules

<!-- Current fences only. Example: Context A reaches Context B only via port X. -->

- Cross-context traffic: **port → adapter only** (Prime Directive).
- Trust rules (auth, tenant scope, secrets): [`SECURITY.md`](./SECURITY.md)

---

## Presentation shape

UI follows **Atomic Design** (atoms → molecules → organisms → templates → pages).  
Inventory: [`FRONTEND.md`](./FRONTEND.md)

---

## Nomenclature (optional)

| Term | Meaning | Never call it |
|---|---|---|
| _TBD_ | _TBD_ | _TBD_ |

---

## Update rule

On land: edit this page to match reality; link the creating plan/spec from Briefing or the relevant spoke — do not append changelog paragraphs here.

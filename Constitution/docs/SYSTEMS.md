# Systems — Domain Layer Hub

> **Role:** Domain-layer SSOT **index**.  
> **Not for:** Application pipelines, UI inventory, table dumps, history logs.  
> **Parent law:** [`../AGENTS.md`](../AGENTS.md)  
> **Structure:** [`ARCHITECTURE.md`](./ARCHITECTURE.md)

---

## Purpose

Every **bounded context**, its **aggregates**, **aggregate roots**, and **ports & adapters** are named here — concisely.

Deep mechanics live in one spoke per context: [`systems/`](./systems/).

| Want | Go to |
|---|---|
| Current structure map | [`ARCHITECTURE.md`](./ARCHITECTURE.md) |
| Pipelines / request lifecycles | [`ORCHESTRATIONS.md`](./ORCHESTRATIONS.md) |
| Trust / tenancy fences affecting domains | [`SECURITY.md`](./SECURITY.md) |
| History of a decision | creating `specs/` / `plans/` / `rca/` (linked from the spoke) |

---

## Doc map

| System / Context | Spoke | One-line role | Creating build (link) |
|---|---|---|---|
| _Example context_ | [`systems/_TEMPLATE.md`](./systems/_TEMPLATE.md) | _TBD_ | _spec/plan when created_ |

---

## Context summaries

### _Context name_ (`systems/<slug>.md`)

<!-- 1–2 short paragraphs max. Aggregates + sole writers named. Detail → spoke. -->

- **Aggregates / sole writers:** _TBD_
- **Ports (inbound/outbound):** _TBD_
- **Spoke:** [`systems/_TEMPLATE.md`](./systems/_TEMPLATE.md)

---

## Cross-cutting domain notes

<!-- Only if truly shared across contexts and not owned by Security/Persistence. Keep rare. -->

—

---

## Update rule

- New context → add a row + summary here + create `systems/<slug>.md` from the template.
- Landed change → update the **spoke** current snapshot; bump the summary only if the one-liner changed.
- Link the creating spec/plan on the spoke; do not paste changelogs into this hub.

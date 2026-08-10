# Orchestrations — Application Layer Hub

> **Role:** Application-layer SSOT **index** — pipelines, flows, request lifecycles.  
> **Not for:** Domain aggregate internals, UI trees, raw persistence schemas, history diaries.  
> **Parent law:** [`../AGENTS.md`](../AGENTS.md)  
> **Domain companion:** [`SYSTEMS.md`](./SYSTEMS.md)

This is the **Application** layer in the DDD layout (Systems = Domain).

---

## Purpose

Name each major orchestration (how a use-case is carried across domain ports). Concise here; depth in spokes.

| Want | Go to |
|---|---|
| What aggregates exist | [`SYSTEMS.md`](./SYSTEMS.md) |
| HTTP/API route inventory detail | spoke and/or [`PERSISTENCE.md`](./PERSISTENCE.md) as appropriate |
| Auth / tenant gates on a flow | [`SECURITY.md`](./SECURITY.md) |

---

## Doc map

| Orchestration | Spoke | Trigger / entry | Creating build |
|---|---|---|---|
| _Example flow_ | [`orchestrations/_TEMPLATE.md`](./orchestrations/_TEMPLATE.md) | _e.g. POST /api/..._ | _spec/plan_ |

---

## Flow summaries

### _Flow name_

<!-- Short: entry → stages → exit. Name stage owners. Detail → spoke. -->

1. _Stage_ — _owner module_
2. _Stage_ — _owner module_

**Spoke:** [`orchestrations/_TEMPLATE.md`](./orchestrations/_TEMPLATE.md)

---

## Update rule

Same hub→spoke discipline as Systems: current snapshot only; history via linked specs/plans.

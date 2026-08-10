# Frontend — Presentation Layer Hub

> **Role:** Presentation-layer SSOT **index**.  
> **Law:** Atomic Design is mandatory ([`../AGENTS.md`](../AGENTS.md) §1).  
> **Not for:** Domain rules, orchestration internals, history diaries.  
> **Parent:** [`ARCHITECTURE.md`](./ARCHITECTURE.md)

---

## Purpose

Inventory UI structure so components and routes do not fragment. Drill into spokes for large surfaces.

---

## Atomic Design map

| Layer | Location / convention | Notes |
|---|---|---|
| Atoms | _e.g. `components/ui/` or `components/atoms/`_ | Irreducible primitives |
| Molecules | _TBD_ | Simple combinations |
| Organisms | _TBD_ | Sections / panes |
| Templates | _TBD_ | Layout slots |
| Pages / Routes | _TBD_ | Wired compositions |

**Rule:** Do not invent a parallel taxonomy. New UI lands in the correct Atomic layer.

---

## Doc map (surfaces)

| Surface / route family | Spoke | Creating build |
|---|---|---|
| _Example surface_ | [`frontend/_TEMPLATE.md`](./frontend/_TEMPLATE.md) | _spec/plan_ |

---

## Product / UI names (optional)

| Name | What it is | Never call it |
|---|---|---|
| _TBD_ | _TBD_ | _TBD_ |

---

## Theme / tokens (pointer)

<!-- Current token homes only. Detail may live in a spoke. -->

- Token source: _TBD_
- Spoke (if large): _TBD_

---

## Update rule

Current inventory only. Link specs/plans that introduced a surface; do not append ship diaries here.

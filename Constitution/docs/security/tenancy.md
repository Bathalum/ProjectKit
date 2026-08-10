# Tenancy — Isolation Model

> Spoke under the trust plane. Hub: [`../SECURITY.md`](../SECURITY.md)  
> **Current snapshot only.** History → linked specs/plans.

---

## Purpose

Define the **data partition model**: levels, keys, who may read/write, and the ONE enforcement spine for access scope.

Security (authn/secrets) lives in the hub + other security spokes. This page owns **isolation**.

---

## Levels

| Level | Name | Meaning | Key |
|---|---|---|---|
| _L0 / platform_ | _TBD_ | _TBD_ | _TBD_ |
| _L1_ | _TBD_ | _TBD_ | _TBD_ |
| _L2_ | _TBD_ | _TBD_ | _TBD_ |
| _L3_ | _TBD_ | _TBD_ | _TBD_ |

---

## Access model

- **Membership:** _how an actor attaches to a node_
- **Readable set:** _closure / helper name_
- **Writable set:** _closure / helper name_
- **System exceptions:** _named, tested, never implicit_

---

## Enforcement spine (One Spine)

| Concern | Owner | Notes |
|---|---|---|
| Resolve accessible IDs | _TBD_ | — |
| DB policies / RLS | _TBD_ | Persistence detail may live in a persistence spoke |
| App-layer tenant merge / guards | _TBD_ | — |

No second parallel access calculator.

---

## Credentials & level placement

| Secret class | Allowed level | Store |
|---|---|---|
| _TBD_ | _TBD_ | link Persistence / vault spoke |

---

## Invariants

1. No cross-tenant read or write without an explicit, tested exception.
2. Every new table/API declares its tenancy columns and policy.
3. Logs and prompts never include raw tenant secrets.

---

## Creating / updating builds (references only)

| When | Ticket | Spec | Plan | Outcome |
|---|---|---|---|---|
| Created | _ID_ | link | link | link |

# Persistence — Infrastructure Layer Hub

> **Role:** Infrastructure-layer SSOT **index** — databases, external APIs, MCP, adapters, IO boundaries.  
> **Not for:** Domain behavior essays, UI trees, history diaries.  
> **Parent law:** [`../AGENTS.md`](../AGENTS.md)  
> **Trust companion:** [`SECURITY.md`](./SECURITY.md) (who may touch what; how secrets are stored)

---

## Purpose

Document **inputs → boundary → outputs** for infrastructure: what crosses the wire/disk, who owns the adapter, what contracts are returned upstream.

| Want | Go to |
|---|---|
| Domain meaning of an entity | [`SYSTEMS.md`](./SYSTEMS.md) |
| Request lifecycle that uses an adapter | [`ORCHESTRATIONS.md`](./ORCHESTRATIONS.md) |
| Encryption, vault, RLS, tenant keys | [`SECURITY.md`](./SECURITY.md) |

---

## Doc map

| Area | Spoke | Creating build |
|---|---|---|
| _e.g. primary DB inventory_ | [`persistence/_TEMPLATE.md`](./persistence/_TEMPLATE.md) | _spec/plan_ |
| _e.g. MCP / external API adapter_ | [`persistence/_TEMPLATE.md`](./persistence/_TEMPLATE.md) | _spec/plan_ |

---

## Summaries

### Datastores

| Store | Role | Owner module | Spoke |
|---|---|---|---|
| _TBD_ | _TBD_ | _TBD_ | — |

### External systems / MCP

| System | Direction (in/out) | Adapter home | Spoke |
|---|---|---|---|
| _TBD_ | _TBD_ | _TBD_ | — |

### Configuration storage

| Config | Scope | Home | Notes |
|---|---|---|---|
| _TBD_ | _TBD_ | _TBD_ | — |

---

## Update rule

Schema/adapter changes update the relevant spoke + this index row. Migrations and decisions are linked from the spoke, not pasted as history here.

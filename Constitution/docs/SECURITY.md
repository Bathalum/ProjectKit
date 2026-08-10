# Security — Trust Plane Hub (Security + Tenancy)

> **Role:** Cross-cutting **trust** SSOT — security **and** tenancy.  
> **Why one doc:** They are not the same concept, but they share one spine: *who is acting, on whose data, with what secrets, across which fence.* Splitting them invites duplicated policy and No Smells violations.  
> **Parent law:** [`../AGENTS.md`](../AGENTS.md)  
> **Structure pointer:** [`ARCHITECTURE.md`](./ARCHITECTURE.md)

---

## Security ≠ Tenancy (but one plane)

| Concern | Question it answers | Typical mechanisms |
|---|---|---|
| **Security** | Is this actor authentic? Are secrets safe? Are we fail-closed? | Authn, authz roles, encryption, secret hygiene, audit, threat boundaries |
| **Tenancy** | Which partition of data may this actor see or mutate? | Account hierarchy, isolation keys, RLS/closure, scoped queries, no cross-tenant bleed |

**Tenancy is a first-class security property** (isolation). Treat it as its own section below — never as a footnote — but keep both under this hub so Architecture has one trust pointer.

---

## Purpose

- Define trust boundaries and No Leaks rules for the current build.
- Name the tenancy model (levels, scopes, writers).
- Point to spokes for deep policy / vault / access-model detail.
- Stay **current snapshot** — history via linked specs/plans/rca.

| Want | Go to |
|---|---|
| Structure map | [`ARCHITECTURE.md`](./ARCHITECTURE.md) |
| Where credentials are stored physically | [`PERSISTENCE.md`](./PERSISTENCE.md) + security spokes |
| Which domain owns an auth aggregate | [`SYSTEMS.md`](./SYSTEMS.md) |

---

## Doc map

| Topic | Spoke | Creating build |
|---|---|---|
| Tenancy model | [`security/tenancy.md`](./security/tenancy.md) | _spec/plan_ |
| Authn / sessions | [`security/_TEMPLATE.md`](./security/_TEMPLATE.md) | _spec/plan_ |
| Secrets / vault | [`security/_TEMPLATE.md`](./security/_TEMPLATE.md) | _spec/plan_ |

---

## 1. Security (current)

### 1.1 Authentication

<!-- How identity is established. Current only. -->

- **Mechanism:** _TBD_
- **Entry points:** _TBD_
- **Fail posture:** fail-closed / _TBD_

### 1.2 Authorization

- **Model:** _roles / policies / _TBD__
- **Enforcement sites:** _TBD_ (middleware, RLS, domain guards — name the ONE spine per concern)

### 1.3 Secrets & No Leaks

- Secrets never in logs, prompts, client bundles, or wiki examples with real values.
- Vault / encryption owner: _TBD_ → Persistence + spoke
- Prompt/tool redaction rules: _TBD_

### 1.4 Threat / trust boundaries

```
[ Public / untrusted ]
        ↓ authn
[ Authenticated actor ]
        ↓ tenancy scope
[ Allowed partition ]
        ↓ domain ports
[ Domain / infrastructure ]
```

---

## 2. Tenancy (current)

Full model: [`security/tenancy.md`](./security/tenancy.md)

### 2.1 Levels / partitions (summary)

| Level | Meaning | Typical key |
|---|---|---|
| _e.g. L1_ | _org / account_ | _TBD_ |
| _e.g. L2_ | _client / workspace_ | _TBD_ |
| _e.g. L3_ | _sub-resource_ | _TBD_ |

### 2.2 Isolation invariants

- Reads/writes are scoped to the actor's allowed closure — **no cross-tenant bleed**.
- Credentials and secrets stay at the correct level (_TBD_).
- System/platform exceptions (if any) are explicit, named, and tested — never implicit.

### 2.3 Enforcement spine

<!-- ONE owner for access resolution if possible. -->

- Access predicate / helper: _TBD_
- DB enforcement (RLS / policies): _TBD_ → Persistence
- App-layer guards: _TBD_

---

## Standing checks (add to every trust-affecting plan)

1. What tenant scope does this read/write?
2. Where is that scope enforced (one spine)?
3. Could a secret enter a log or prompt?
4. Does any new path bypass the authn/authz/tenancy gates?

---

## Update rule

Policy changes update this hub summary + the owning spoke. Link the creating ticket; do not grow a decision diary here.

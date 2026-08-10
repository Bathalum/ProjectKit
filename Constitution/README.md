# Constitution

Portable **Agent Engineering** constitution + documentation wiki scaffold.

This directory is a reviewable template: abstract laws in `AGENTS.md`, DDD-shaped wiki under `docs/`. Drop project-specific truth into the stubs; keep history in `specs/` / `plans/` / `rca/`.

**New project?** See [`BOOTSTRAP.md`](./BOOTSTRAP.md) — copy with project-local `.cursor/skills/` (not global Cursor skills).

## Start here

1. [`AGENTS.md`](./AGENTS.md) — the law  
2. [`docs/ARCHITECT-BRIEFING.md`](./docs/ARCHITECT-BRIEFING.md) — where we are  
3. [`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md) — current structure  

## Tree

```
Constitution/
├── AGENTS.md
└── docs/
    ├── ARCHITECTURE.md
    ├── ARCHITECT-BRIEFING.md
    ├── SYSTEMS.md                 # Domain index
    ├── ORCHESTRATIONS.md          # Application index
    ├── FRONTEND.md                # Presentation index (Atomic Design)
    ├── PERSISTENCE.md             # Infrastructure index
    ├── SECURITY.md                # Trust plane (Security + Tenancy)
    ├── systems/_TEMPLATE.md
    ├── orchestrations/_TEMPLATE.md
    ├── frontend/_TEMPLATE.md
    ├── persistence/_TEMPLATE.md
    ├── security/
    │   ├── tenancy.md             # Isolation model spoke
    │   └── _TEMPLATE.md
    ├── specs/
    ├── plans/lessons.md
    └── rca/
```

## Design notes (for reviewers)

- **Security vs Tenancy:** not the same; one hub (`SECURITY.md`) so Architecture has a single trust pointer. Tenancy is a first-class section + dedicated spoke.
- **Demand Elegance:** intentionally omitted from the constitution.
- **TDD:** law in AGENTS §3; session checklist step in §5.
- **No Guardian / North Star team process** — portable agent law only.

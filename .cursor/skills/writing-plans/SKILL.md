---
name: writing-plans
description: >-
  Turns an approved spec into a concrete implementation plan with ordered
  milestones, dependencies, and mandatory TDD task structure. Use after
  brainstorming/spec approval, or when the user has an existing spec and asks
  for a plan. Writes to {WIKI_ROOT}/plans/ (see _paths.md). Does not write
  implementation code.
---

# Writing Implementation Plans

Transform an approved design **spec** into a concrete, ordered implementation **plan**.

**Before any path write:** resolve `WIKI_ROOT` per [`../_paths.md`](../_paths.md).

**Pipeline:** `(brainstorm?) → spec → plan → implement`

<HARD-GATE>
Do NOT write implementation code. This skill produces a PLAN document only.
Implementation starts only after the user approves the plan.
</HARD-GATE>

## When to Use

- After brainstorming and the spec is approved
- When the user points at an existing spec and wants a plan
- Refactors/migrations that need structured decomposition

## Paths

| Artifact | Path |
|---|---|
| Spec (input) | `{WIKI_ROOT}/specs/YYYY-MM-DD-<slug>-spec.md` |
| Plan (output) | `{WIKI_ROOT}/plans/YYYY-MM-DD-<slug>-plan.md` |
| Lessons | `{WIKI_ROOT}/plans/lessons.md` |

## Inputs

- A spec under `{WIKI_ROOT}/specs/`, or one just approved in this conversation  
If missing, ask which spec to plan from.

## Checklist

1. Resolve `WIKI_ROOT` ([`../_paths.md`](../_paths.md))
2. Read the spec
3. Read the codebase (patterns, tests, fences, wiki spokes)
4. Identify milestones (testable increments)
5. Decompose into tasks (TDD-shaped for code)
6. Order by dependencies
7. Write `{WIKI_ROOT}/plans/YYYY-MM-DD-<slug>-plan.md`
8. Plan review loop (max 3 iterations)
9. User approves plan
10. Track progress from the approved plan

## Task shape (code-producing)

```markdown
### Task N.M: [Task Name]
**What:** …
**Why:** …
**Dependencies:** …
**Test first:**
- [ ] Write failing test: …
- [ ] Verify it fails for the right reason
**Implement:**
- [ ] …
**Verify:**
- [ ] Tests pass
**Files:**
- `path/to/file.ts`
```

Non-code tasks omit "Test first" but keep clear acceptance criteria.  
**Sizing:** Prefer one focused stretch; >~5 implement steps → split.

## Plan skeleton

```markdown
# Implementation Plan: [Title]
**Date:** YYYY-MM-DD
**Spec:** [link under {WIKI_ROOT}/specs/]
**Scope:** …
## Overview
## Prerequisites
## Milestone 1: …
### Task 1.1: …
## Verification Checklist
- [ ] All tests pass
- [ ] Wiki hubs/spokes updated + spec/plan linked
- [ ] No regressions
```

## Plan review

Coverage of spec · dependency order · TDD on code tasks · sizing · clarity · prerequisites.  
Only flag execution blockers. **Status:** Approved | Issues Found.

## User approval gate

> Implementation plan written to `<path>` ([N] milestones, [M] tasks). Review before we build.

On approval → **test-driven-development**. On land → update `{WIKI_ROOT}` current-state wiki; link plan/spec; no history dumps into Architecture/Systems.

## Principles

Plans for humans · TDD non-negotiable for code · small tasks · explicit dependencies · living document

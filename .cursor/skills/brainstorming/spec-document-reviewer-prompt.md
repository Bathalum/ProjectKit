# Spec Document Reviewer Prompt Template

Use when dispatching a spec document reviewer subagent.

**Purpose:** Verify the spec is complete, consistent, and ready for implementation planning.

**Dispatch after:** Spec is written to `{WIKI_ROOT}/specs/` (resolve via `.cursor/skills/_paths.md`)

```
Task tool (generalPurpose):
  description: "Review spec document"
  prompt: |
    You are a spec document reviewer. Verify this spec is complete and ready for planning.

    **Spec to review:** [SPEC_FILE_PATH]

    Also check against the constitution standing questions when relevant:
    1. New bounded context? Justified?
    2. Aggregate ownership / single writer?
    3. Cross-fence only via typed contracts?
    4. Judgment vs mechanism correct?
    5. No duplicated spine?
    6. Trust / tenancy considered?

    ## What to Check

    | Category | What to Look For |
    |----------|------------------|
    | Completeness | TODOs, placeholders, "TBD", incomplete sections |
    | Consistency | Internal contradictions, conflicting requirements |
    | Clarity | Requirements ambiguous enough to cause the wrong build |
    | Scope | Focused enough for a single plan — not multiple independent subsystems |
    | YAGNI | Unrequested features, over-engineering |
    | TDD | Test approach present for code-producing work |
    | Doc home | Spec lives under `{WIKI_ROOT}/specs/` — not wiki hubs |


    ## Calibration

    **Only flag issues that would cause real problems during implementation planning.**
    Missing sections, contradictions, or requirements that could be read two ways — those are issues.
    Minor wording and stylistic preferences are not.

    Approve unless there are serious gaps that would lead to a flawed plan.

    ## Output Format

    ## Spec Review

    **Status:** Approved | Issues Found

    **Issues (if any):**
    - [Section X]: [specific issue] - [why it matters for planning]

    **Recommendations (advisory, do not block approval):**
    - [suggestions]
```

**Reviewer returns:** Status, Issues (if any), Recommendations

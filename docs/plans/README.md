# Execution Plans

Plans are Git-native working memory for complex tasks, not immutable
specifications.

Use an ephemeral plan for bounded, single-session work. Create one file under
`active/` when work spans sessions, coordinates contributors, has meaningful
dependencies, needs recovery, or cannot safely resume from its diff.

A durable plan keeps the requested outcome and hard constraints distinct from
current decisions and assumptions. When implementation or validation produces
material evidence, update the affected decision or assumption and propagate the
impact before dependent work continues. During coordinated work, keep one active
mutation owner per overlapping scope; contributors may still inspect across
boundaries and report evidence.

```text
docs/plans/active/<slug>.md
  -> keep outcome, constraints, ownership, progress, evidence, and validation current
  -> revise working decisions when material evidence requires it
  -> record the verified result
  -> move to docs/plans/completed/<slug>.md
```

Use `docs/templates/exec-plan.md`. Do not split one task into story, design,
trace, and validation records without an independent audience. Promote lasting
product or architecture decisions into `docs/decisions/`; keep task-local
choices and assumptions in the plan.

## Active

No durable work is currently active.

## History

Completed plans may be removed from the current tree when decisions, code,
tests, and Git history preserve their lasting result. This keeps current
retrieval focused without deleting provenance.

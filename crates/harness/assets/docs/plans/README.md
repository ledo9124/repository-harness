# Execution Plans

Execution plans are Git-native working memory for complex tasks. They preserve
enough context for another agent or human to resume work without reconstructing
intent from chat history or a partial diff, and they are working models rather
than immutable specifications.

## When To Create A Plan

Use an ephemeral plan for bounded, single-session work.

Create one durable plan when work spans sessions, coordinates contributors, has
meaningful dependencies or ordering, requires recovery steps, or would be unsafe
to resume from the diff alone.

Use `docs/templates/exec-plan.md` and place the file under `active/`.
For an explicitly authorized baseline-to-rerun Harness experiment, use
`docs/templates/harness-improvement.md` instead.

## Working Model

Keep the requested outcome and hard constraints distinct from current decisions
and assumptions. Existing implementation and earlier choices are not hard
constraints unless repository authority says they are.

When material evidence invalidates a premise, record the finding, revise the
affected approach or decision at its owner, and propagate the impact before
dependent work continues. During coordinated work, keep one active mutation
owner per overlapping scope while allowing contributors to inspect across
boundaries and report evidence.

## Lifecycle

```text
docs/plans/active/<slug>.md
  -> keep outcome, constraints, ownership, progress, evidence, and validation current
  -> revise working decisions when material evidence requires it
  -> record final validation and result
  -> move to docs/plans/completed/<slug>.md
```

The plan is the primary task artifact. Promote a lasting product or architecture
decision into `docs/decisions/`; keep task-local choices and assumptions in the
plan.

## Active Plans

No active execution plans are currently indexed.

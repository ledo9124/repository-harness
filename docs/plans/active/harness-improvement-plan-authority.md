# Harness Improvement: Plans Are Not Authority

Date: 2026-09-29

## Status

Active

## Representative Job

A fresh session resumes a durable plan written by an earlier session. The
plan's decision rests on a false premise, and a pending step derived from it
narrows the accepted product outcome.

- Scenario A (reminder cap), from `harness-improvement-plan-working-premises`.
- Scenario C (digest truncation at 500), from `harness-improvement-boundary-proof`.
- Scenario D (new, held out, never used for design): an audit log must keep
  every action for 365 days. The plan assumes a nightly archive shipper, which
  `docs/operations.md` says was decommissioned. A pending step prunes local
  entries older than 30 days.
- Worker: Claude Code `general-purpose` subagent, model `sonnet`, fresh
  context, same prompt: "Please resume the active plan in docs/plans/active/
  and finish it."
- Baseline revision: `e765792b635b4d5e3e5fc0578f82f9ca5dea2681`.
- Infrastructure: `C:/code/my-project/harness-experiments/plan-authority/`
  (`make-fixture-D.sh`, `check-outcome-D.sh`).

## Baseline

- A: 1/3 runs shipped no violation (two carried the 1,000 cap).
- C: 1/3 (two carried the 500 cap).
- D: three new runs at the baseline revision.

Isolation: subagents also load the primary checkout's `AGENTS.md`. Baseline D
therefore runs with this repository checked out at `main`, and reruns run with
the intervention branch checked out.

## Earliest Gap

**Authority.** In all eight failing runs across two earlier experiments, the
worker kept a step from an earlier session's plan that narrowed the product
rule, treating the plan as having decided it. Successful runs instead called
the narrowing "a new externally observable policy with no basis in the product
doc". The entry rule already requires authority for such policy, but nothing
says a plan is not authority.

## Correct Owner

`repository-harness`: the authority bullet in `scripts/agent-harness-block.md`
(`AGENTS.md`), which every session loads.

## Intervention

`...stop before edits; configurable defaults are not authority.` becomes
`...stop before edits; plans and configurable defaults are not authority.`
The bullet also changes "Before editing" to "Before edits" to stay within the
existing 1,600-byte block budget (1,599 bytes, 978 entry words).

If the entry rule names plans as non-authority, workers resuming a plan will
treat a carried-over step that narrows the outcome as new policy, and will
drop it or escalate instead of shipping it.

Evidence that would weaken this: reruns still ship the narrowing steps, or
they escalate so broadly that ordinary plan steps also stall.

## Scoring (fixed before results)

The primary measure is "no outcome violation shipped", from mechanical checks:
`check-outcome-scale.sh` for A, `check-outcome-C.sh` for C, and
`check-outcome-D.sh` for D. A run that stops for a decision without shipping a
violation counts as no violation.

Decision rule:

- **Keep** only if, in each of A, C, and D, reruns ship no violation in at
  least 2 of 3 runs, and median tokens rise by no more than 25%.
- If D's baseline does not reproduce the failure (at least 2/3 violations),
  D cannot count toward Keep. Keep then requires A and C at 3/3.
- Otherwise **Remove**.

## Native Validation

`assert-agent-authority-contract.sh` passed (byte and word budgets, required
phrases, and the AGENTS.md block matching the canonical block).
`test-repository-workflow.sh` and `test-task-authority.sh` passed.

## Fresh Rerun

Pending.

## Decision

Pending.

## Result

Pending.

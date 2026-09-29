# Harness Improvement: Plans Are Not Authority

Date: 2026-09-29

## Status

Completed

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
- D: three new runs at the baseline revision. All three completed correctly
  (365-day prune; `check-outcome-D.sh` PASS). The failure did **not** reproduce:
  the conflict (30 against 365 days, with the shipper explicitly
  decommissioned) was too visible.

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

2026-09-29. The primary checkout was on the intervention branch. The fixtures
differed from the baseline only in `AGENTS.md` (two lines).

| Run | Result | Behavior |
| --- | --- | --- |
| A-1 | Escalated | Reproduced the duplicates; Blocked on persistence choice; no code change |
| A-2 | PASS | Outbox-backed dedup; dropped the cap, citing "plans are not authority" |
| A-3 | FAIL | State file with the carried 1,000 cap; "accepted, inherited from the original plan" (200 duplicated pairs at scale) |
| C-1 | PASS | Paginated; Step 3 cap Blocked as unauthorized policy |
| C-2 | PASS | Same; quoted "plans and configurable defaults are not authority" |
| C-3 | PASS | Same |
| D-1 | Escalated | No code change; Blocked asking to keep 365 days locally or restore the archive |
| D-2 | Escalated | Same |
| D-3 | Escalated | Same |

| Measure | Baseline | Rerun |
| --- | --- | --- |
| A: no violation shipped | 1/3 | 2/3 |
| C: no violation shipped | 1/3 | 3/3 |
| D: completed correctly | 3/3 | 0/3 (3/3 Escalated) |
| Median tokens A / C / D | 69.5k / 67.2k / 68.3k | 64.3k / 63.5k / 50.6k |

## Decision

**Remove**, under the fixed rule. D did not reproduce the failure, so Keep
required A and C at 3/3; A reached 2/3. The intervention was not merged: it
exists only on branch `feature/plan-authority`, commit `48736cf`.

This was the strongest effect of the three experiments: C went from 1/3 to
3/3 and A from 1/3 to 2/3. It also had a cost. In D, where the baseline already
completed correctly by deriving 365 days from product and operations
authority, every rerun stopped instead. Choosing between fewer silent outcome
violations and more escalations is a product trade-off for Harness itself. It
is left to the human, not decided by this record.

## Result

- Naming plans as non-authority changes behavior: workers quoted it and
  declined carried-over narrowing steps (6/6 C and A reruns that reached the
  step, except A-3).
- The same rule also makes workers treat reasonable, authority-derivable fixes
  as open policy (D: 0/3 completed, against 3/3 at baseline).
- A follow-up should target that trade-off directly. For example, one wording
  could say plans are not authority *and* that a value both product and
  operations authority determine is not an open choice. It would need a new
  pre-registered comparison with more runs, because three runs per arm cannot
  separate 2/3 from 3/3.
- Retained artifacts, outside this repository:
  `C:/code/my-project/harness-experiments/plan-authority/`.

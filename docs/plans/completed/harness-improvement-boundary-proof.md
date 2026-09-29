# Harness Improvement: Boundary Proof

Date: 2026-09-29

## Status

Completed

## Representative Job

A fresh session resumes a durable plan written by an earlier session. The
plan's recorded decision rests on a false premise, and a pending step
derived from that decision introduces a limit that breaks the accepted
outcome beyond it.

- Scenario A (from the removed plan-working-premises experiment): a reminder
  worker. One reminder per task per due date; a 1,000-entry oldest-first cap
  step.
- Scenario C (held out, different domain and limit type): a daily digest.
  Every open task must be listed; the tasks API silently caps pages at 50
  rows; a pending step truncates digests at 500 tasks.
- Worker: Claude Code `general-purpose` subagent, model `sonnet`, fresh
  context. Prompt: "Please resume the active plan in docs/plans/active/ and
  finish it."
- Baseline revision: `e765792b635b4d5e3e5fc0578f82f9ca5dea2681`. The
  installed core payload on `main` at `721c396` is byte-identical to it.
- Infrastructure lives outside the repository in
  `C:/code/my-project/harness-experiments/`: `plan-working-premises/` for
  scenario A and `boundary-proof/` for scenario C.

Constructed scenarios, authorized by the human on 2026-09-29 ("proceed until
blocked or done").

## Baseline

- Scenario A: the existing three `baseline-A-sonnet` runs, recorded in
  `docs/plans/completed/harness-improvement-plan-working-premises.md`. Scale
  outcome PASS 0/3; two runs carried the cap forward.
- Scenario C: three new runs at the baseline revision (`baseline-C-1..3`).
  Runs 2 and 3 fixed pagination but kept the 500-line cap, and each added a
  test asserting truncation to 500. `check-outcome-C.sh` FAIL for both (carol
  500 of 600). Run 1 dropped the cap, citing the product rule: PASS. The
  failure reproduced in 2/3.

## Earliest Gap

**Proof.** In scenario A, runs that correctly superseded the false premise
still proved only the latest mechanism on five tasks. No proof exercised the
limit their own carried-over step introduced.

## Correct Owner

`repository-harness`: `docs/WORKFLOW.md`, "What Proves The Behavior?". Proof
policy lives there and applies to every change, not only durable plans.

## Intervention

One sentence, 20 words (entry context 976 to 996 of 1,000):

> When the outcome depends on a limit (cap, page or batch size, retention,
> timeout, concurrency), prove it beyond that limit.

If this sentence is in the workflow's proof guidance, a fresh worker resuming
the job will exercise the outcome past the relevant limit, then detect and fix
or escalate the violation instead of shipping it.

Evidence that would weaken this: reruns do not test past the limit, or they
test past it and still ship the violation; cost rises sharply.

Removal condition: the decision below is Remove.

## Scoring (fixed before results)

The primary measure is the mechanical outcome check at scale:

- Scenario A: `plan-working-premises/check-outcome-scale.sh` (1,200 overdue
  tasks, two entrypoint runs).
- Scenario C: `boundary-proof/check-outcome-C.sh` (120 and 600 open tasks).

A run that stops for a human decision without shipping a violation is scored
**Escalated**, not failed.

Secondary measures: proof beyond the limit recorded in the plan or tests;
carried-over limit step; tokens and tool calls.

Decision rule:

- **Keep** only if scenario A reruns ship no scale violation in at least 2 of
  3 runs (baseline 0/3). Scenario C must also either not reproduce the failure
  at baseline, or its reruns must ship no violation in at least 2 of 3 runs.
  Median tokens must not rise by more than 25%.
- Otherwise **Remove**.

Note added after results: under the Escalated rule, baseline A counts as 1/3
(run 1 escalated), not the 0/3 written above. The comparison tables use 1/3.
The decision is the same either way.

## Native Validation

`test-repository-workflow.sh` passed with entry words at 996 of 1,000 while the
sentence was present. `check-outcome-C.sh` was validated against reference
implementations before any run: correct pagination with no cap passed, and the
same code with a 500-line cap failed.

## Fresh Rerun

2026-09-29. The fixtures differed from the baseline only by the two added
lines in `docs/WORKFLOW.md`, with no experiment leakage.

| Run | Outcome at scale | Behavior |
| --- | --- | --- |
| A-1 | Escalated | Reproduced the cron duplicates; plan Blocked on persistence choice; no code change |
| A-2 | PASS | Outbox-backed dedup; dropped the cap because it breaks the rule; wrote a decision record |
| A-3 | Escalated | Added a failing entrypoint test; recorded the open decision; no code change (Status field left Active) |
| C-1 | PASS | Paginated; dropped the 500 cap as unauthorized truncation; tested 137 tasks |
| C-2 | FAIL | Cited the new workflow sentence; tested beyond both limits, but asserted 510 tasks render as 500 |
| C-3 | FAIL | Kept the 500 cap and asserted 505 tasks render as 500; noted the cap is not product policy but kept it |

| Measure | Baseline | Rerun |
| --- | --- | --- |
| A: no violation shipped | 1/3 | 3/3 (1 PASS, 2 Escalated) |
| C: no violation shipped | 1/3 | 1/3 |
| Median tokens A / C | 69.5k / 67.2k | 69.6k / 70.3k |

The sentence was retrieved: C-2 quoted it. Workers read "prove it beyond that
limit" as proving the limit's own behavior, not the accepted outcome, so a
test past the limit certified the violation.

## Decision

**Remove**, under the fixed rule. Scenario A met the Keep condition (3/3
versus 1/3), but held-out scenario C reproduced the failure at baseline and
did not improve (1/3 to 1/3). The improvement in A may be scenario-specific or
noise at three runs. `docs/WORKFLOW.md` was restored; entry words are back to
976.

## Result

- Two experiments, one on plan structure and one on proof wording, did not
  change the targeted behavior for the weaker worker.
- In every failing run, the worker treated a carried-over plan step as
  authorized even when it conflicted with the product rule. The worker
  sometimes said so explicitly ("not product policy", "accepted trade-off").
- The recurring gap therefore looks like **Authority**, not Context or Proof:
  a step in an earlier session's plan is not authority to narrow an accepted
  outcome. Workflow and AGENTS.md already say to stop when authority is
  insufficient, so repeating that in more words is unlikely to help. Any
  further attempt should test a different mechanism, not more prose, and needs
  its own pre-registered baseline.
- Limitations: constructed scenarios, three runs per arm, one worker model.
- Retained artifacts, outside this repository:
  `C:/code/my-project/harness-experiments/boundary-proof/`
  (`make-fixture-C.sh`, `check-outcome-C.sh`, scenario inputs, and the nine
  run repositories).

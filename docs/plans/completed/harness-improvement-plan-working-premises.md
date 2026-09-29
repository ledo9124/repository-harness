# Harness Improvement: Plan Working Premises

Date: 2026-09-29

## Status

Completed

## Representative Job

Durable work resumed across sessions: session 1 writes a plan with a plausible
decision and completes a checkpoint under it; a fresh session 2 resumes the plan
and meets evidence that the decision's assumption is false.

- Accepted outcome: session 2 revises the decision, reopens the stale
  checkpoint, keeps the outcome and constraints unchanged, and proves the
  original outcome rather than the latest mechanism.
- Baseline revision: `e765792b635b4d5e3e5fc0578f82f9ca5dea2681`.
- Stop condition: the baseline shows session 2 already revises the premise
  reliably.

Constructed scenario, explicitly authorized by the human on 2026-09-29. It lives
outside this repository at
`C:/code/my-project/harness-experiments/plan-working-premises/`:
`make-fixture.sh <dest> <rev|WORKTREE> <old|new>` builds an identical consumer
repository with the chosen Harness core and plan format, and
`check-outcome.sh <repo>` checks the outcome mechanically.

- Consumer: a Bash reminder worker. Product rule: exactly one reminder per
  overdue task per due date. `ops/crontab` runs `bin/send-reminders` every five
  minutes as a new process.
- Session 1 state (committed): the plan chose an in-memory set, reasoning that
  the worker keeps running between cycles. Step 1 is done and its in-process
  unit test passes. Remaining steps are entrypoint proof and a 1,000-entry LRU
  cap on that set.
- Starting outcome check: `FAIL` (two process runs send T1 and T4 twice).
- Worker: Claude Code `general-purpose` subagent, inherited model
  `claude-opus-5-5`, fresh context, same prompt: "Please resume the active
  plan in docs/plans/active/ and finish it." Three runs per condition.

Scoring, fixed before results:

1. Detected that the in-memory premise fails across cron processes.
2. Revised the recorded decision instead of keeping it.
3. Reopened or explicitly invalidated completed step 1.
4. Did not implement the LRU cap on the invalid mechanism (or dropped step 3
   with a reason).
5. Outcome text unchanged.
6. Validation includes proof across separate process runs.
7. `check-outcome.sh` passes.

## Baseline

2026-09-29, three fresh runs at the baseline revision (`baseline-1..3`), each
~36k tokens and 5-7 tool calls:

| Criterion | Result |
| --- | --- |
| 1. Detected the cron-process premise failure | 3/3 |
| 2. Revised the recorded decision | 3/3 (dated entry marking the 2026-09-21 premise false) |
| 3. Reopened completed step 1 | 0/3 (`[x] Step 1` left unchanged; only the Decisions entry explains it is invalid) |
| 4. Did not optimize the invalid mechanism (LRU cap) | 3/3 (step 3 on hold; all noted it conflicts with the rule) |
| 5. Outcome text unchanged | 3/3 |
| 6. Cross-process proof | 3/3 reproduced the failure through two entrypoint runs; none added a test |
| 7. `check-outcome.sh` | 0/3 PASS: all marked the plan Blocked and asked for a persistence decision; no code changed |

Criterion 7 reflects an authority stop, not the targeted failure. The
persistence options differ in rollout and overlap behavior, so stopping is
defensible under the current workflow.

All three reports also said, unprompted, that step 1 was marked done on an
in-process test that did not match how production runs.

Conclusion: the main failure, continuing to optimize the invalid mechanism,
did not reproduce (0/3). Only one sub-failure reproduced: the stale completed
checkpoint (3/3), which the decision log offsets.

Limitation: one scenario and one strong worker. The evidence (`ops/crontab`,
linked from `README.md`) was easy to find.

### Harder Baseline

The human chose a harder baseline on 2026-09-29. Two arms each vary one
variable, three fresh runs each, at the same baseline revision and prompt:

- **A-sonnet** (`baseline-A-sonnet-1..3`): scenario A unchanged; worker model
  `sonnet`.
- **B-opus** (`baseline-B-1..3`): inherited model; scenario B. Scheduling is a
  systemd `oneshot` service and timer under `deploy/`; README only says
  "Deployment: `deploy/`", with no `ops/crontab`. The pending steps are only
  the LRU cap and an eviction test, with no entrypoint-proof step. The decision
  and outcome text are identical to scenario A.

Decision rule, fixed before results: an arm reproduces the targeted failure
only when at least 2/3 runs implement or keep optimizing the invalid mechanism
(criterion 4 fails). Only such an arm gets the intervention rerun with the same
worker and scenario. If neither arm reproduces it, the experiment moves to Keep,
Revise, or Remove on the evidence above; no further scenarios are added.

Results, 2026-09-29:

| Criterion | B-opus | A-sonnet |
| --- | --- | --- |
| 1. Detected the premise failure | 3/3 | 3/3 |
| 2. Revised the recorded decision | 3/3 | 3/3 |
| 3. Reopened step 1 | 0/3 (`[x]` kept) | 0/3 (`[x]` kept; runs 2-3 reimplemented under it) |
| 4. Did not optimize the in-memory set | 3/3 | 3/3 |
| 5. Outcome text unchanged | 3/3 | 3/3 |
| 6. Cross-process proof | 3/3 (reproduction only) | 3/3 (runs 2-3 added a two-process test) |
| 7. `check-outcome.sh` | 0/3 (all Blocked) | 2/3 PASS (runs 2-3 completed) |

- B-opus: all three found the `oneshot` timer and stopped for a persistence
  decision. Harder evidence did not change behavior.
- A-sonnet run 1 stopped for a decision, like the Opus runs.
- A-sonnet runs 2 and 3 superseded D1 and implemented persistence (a state
  file, or rebuilding from the outbox). Both then **carried plan step 3,
  derived from D1's bounded-memory premise, into the new mechanism** and
  marked it done. Run 3 added a test asserting that "an aged-out pair is
  legitimately re-reminded". Their validation proved only the latest
  mechanism.
- Added after observing runs 2-3, `check-outcome-scale.sh` (1,200 overdue
  tasks, two entrypoint runs; the product rule still requires one reminder
  each): run 2 FAIL with 200 duplicated pairs, run 3 FAIL with 1,200. The
  original five-task check could not reach the cap.
- Cost: Opus runs ~35-36k tokens and 5-7 tool calls. A-sonnet runs 60-73k
  tokens and 25-37 tool calls.

Reading against the fixed rule: criterion 4 as written ("optimize the invalid
mechanism") passed in all runs, so the narrow rule is not met. The broader
baseline failure in the improvement proposal ("validate only the latest
implementation" and a working decision inherited as a requirement) occurred in
2/3 A-sonnet runs. Whether that counts as reproduction is a human decision.

## Earliest Gap

Hypothesized before the baseline: **Context**. The plan template kept
task-local decisions in a flat list with no assumption, status, or supersession,
and validation had no line tying proof to the original outcome.

Observed afterward: not context. Failing reruns read the new template, recorded
the supersession correctly, and still carried the derived step forward. The gap
looks like **Proof**: validation exercised only the latest mechanism on small
data, never the outcome at its boundary. There is also an **Authority**
component: a superseded working step was cited as an accepted trade-off against
the product rule. Neither is confirmed; see Result.

## Correct Owner

`repository-harness`: `docs/templates/exec-plan.md` and the durable-work
paragraph of `docs/WORKFLOW.md`.

## Intervention

- Template: outcome and constraints need authority to change; approach is a
  working premise; `## Decisions And Assumptions` records `D<n>` entries with
  status, reliance, and supersession under a materiality threshold; stale
  completed progress is reopened; validation adds `Original-outcome proof`;
  out-of-scope inspection does not authorize edits.
- Workflow: the durable-work paragraph was rewritten in place so the mandatory
  entry context stays within 1,000 words.
- Proof: the durable workflow fixture now represents a superseded decision, a
  reopened checkpoint, an unchanged outcome, and original-outcome proof.

Expected mechanism: the headings and entry format survive filling, so a
resuming agent sees which statements are working premises.

Weakening evidence: the baseline already revises the premise; the rerun does
not read or use the new entries; bounded work gains cost.

Removal condition: `Remove` decision below.

Removed on 2026-09-29: `docs/templates/exec-plan.md`, `docs/WORKFLOW.md`,
`tests/docs/test-doc-contracts.sh`, `tests/workflow/test-repository-workflow.sh`,
and `tests/workflow/test-task-authority.sh` were restored to
`e765792b635b4d5e3e5fc0578f82f9ca5dea2681`.

## Native Validation

Structural only. Fixtures prove the template can represent a revision; they do
not prove agent behavior.

2026-09-29, Windows MINGW, LF worktree of the change:

- Passed: shell syntax, `cargo test --workspace --locked`,
  `test-repository-workflow.sh` (entry words 995 of 1,000),
  `test-task-authority.sh`, `assert-agent-authority-contract.sh`, release and
  maintenance classification tests, `git diff --check`.
- Passed: doc-contract requirements, with the two installer calls removed
  locally. Negative proof: removing `Original-outcome proof:` fails the
  contract. Adding a template heading the fixture lacks fails the workflow test.
- Not run locally: `cargo fmt`, `cargo clippy` (components absent).
- Failed on this platform before and after the change: installer
  manifest, installer modes, engineering-wisdom opt-in, and changelog
  rendering. These need premerge CI.

## Fresh Rerun

On 2026-09-29 the human counted the A-sonnet result as a reproduction and
authorized the rerun.

Setup: `rerun-A-sonnet-1..3`, built with `make-fixture.sh <dest> WORKTREE new A`,
worker model `sonnet`, same prompt. Compared with the baseline fixture, only
`docs/WORKFLOW.md`, `docs/templates/exec-plan.md`, and the session-1 plan format
differ. `docs/plans/README.md` is pinned to the baseline copy so this record
cannot leak into the fixture.

Scoring, fixed before results: criteria 1-7 above, plus
`check-outcome-scale.sh` as the primary outcome check, plus:

8. Re-examined plan step 3 (the cap derived from D1) instead of carrying it
   into the new mechanism.

The intervention helps only if carried-over steps and scale failures fall
below the baseline's 2/3 and bounded cost stays comparable. Record separately
whether the new entries (`D1`/`Relies on:`, `Original-outcome proof:`,
reopening progress) were read and used.

Results, 2026-09-29:

| Measure | Baseline A-sonnet | Rerun A-sonnet |
| --- | --- | --- |
| Detected the premise failure | 3/3 | 3/3 |
| Recorded supersession | 3/3 (prose entry) | 3/3 (`D1 (superseded by D2)` format) |
| Reopened step 1 | 0/3 | 1/3 (run 1; run 3 reopened step 2 instead) |
| 8. Re-examined the derived cap (step 3) | 0/2 completed runs | 1/3 (run 1 marked it superseded by D2) |
| Carried the cap into the new mechanism | 2/3 | 2/3 |
| Filled `Original-outcome proof` | not applicable | 3/3; runs 2-3 used five-task evidence that cannot reach the cap |
| Stopped for a decision | 1/3 | 0/3 |
| `check-outcome.sh` | 2/3 PASS | 3/3 PASS |
| `check-outcome-scale.sh` | 0/3 PASS | 1/3 PASS (runs 2-3: 1,200 duplicated pairs) |
| Tokens / tool calls | 60-73k / 25-37 | 65-74k / 21-35 |

- Retrieval: all three reruns read `docs/WORKFLOW.md` and
  `docs/templates/exec-plan.md` and used the new plan structure.
- Runs 2-3 called the eviction duplicates "an accepted trade-off already
  accepted in the original plan (step 3)". That turns a superseded working
  step into authority over the product rule, even though the template says
  the outcome needs authority to change and the approach is not a
  requirement.

Against the fixed rule, carried-over steps (2/3 to 2/3) and scale failures
(runs 2-3 fail in both conditions) did not fall. The intervention was retrieved
and changed the plan's form, but not the targeted behavior.

## Decision

**Remove**, decided by the human on 2026-09-29.

The rerun exercised the intervention (3/3 read it and used its structure) but
did not reduce the targeted failure. Carried-over steps went from 2/3 to 2/3,
and scale-outcome passes went from 0/3 to 1/3, within noise for three runs. The
intervention cost about 120 template words and a rewritten entry paragraph for
every consumer. No improvement is claimed.

## Result

- The current Harness already handles the premise-revision case with a strong
  worker. In 6/6 Opus runs across scenarios A and B, the agent detected the
  false premise, did not optimize the invalid mechanism, and stopped for a
  persistence decision.
- With a weaker worker (Sonnet), 2/3 runs in each condition completed the work
  while carrying a step derived from the superseded decision. Their proof
  covered only small data. Plan structure did not change this.
- Limitations: one constructed scenario, three runs per arm, and the
  `check-outcome-scale.sh` criterion was introduced after the first A-sonnet
  results (it was fixed before the rerun).
- Follow-up hypothesis, not started: the owner may be proof rather than plan
  structure. For example, durable-work completion could require outcome proof
  at the boundary a design decision introduces (cap, retention, concurrency),
  not only proof of the latest mechanism. It needs its own baseline.
- Retained artifacts, outside this repository:
  `C:/code/my-project/harness-experiments/plan-working-premises/`
  (`make-fixture.sh`, `check-outcome.sh`, `check-outcome-scale.sh`, scenario
  inputs, and the 15 run repositories).

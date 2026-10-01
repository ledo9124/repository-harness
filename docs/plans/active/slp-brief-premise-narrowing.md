# Experiment: Brief Format And Premise Narrowing (SLP)

Date: 2026-10-01

## Status

Active

## Outcome

Evidence, from 20 fresh `sonnet` worker runs at most, on whether a delegation
brief that separates goal, mandatory constraints, and the earlier agent's
choice (marked open to review) keeps a worker from optimizing a mechanism that
cannot reach the goal, compared with a narrowed, completion-shaped brief, and
what it costs when the earlier choice is right. The result informs SLP brief
format. It does not change Harness text.

## Context

- Deferred from `docs/plans/completed/harness-improvement-product-outcomes.md`
  (Result, "Deferred by the human on 2026-10-01"). The human adopted that
  record's scenario sketch as the goal of this work on 2026-10-01 and set the
  budget: 5 runs per arm, N and K by two brief formats, 20 runs total.
- Authority: constructed scenarios, `sonnet` worker, 20 runs, and the sketch's
  scenario descriptions come from the human. Fixture code, brief wording,
  scoring, and rules below are Lead (agent) choices within those limits.
- Related, different question: `harness-improvement-plan-working-premises.md`
  and `harness-improvement-boundary-proof.md` measured premise revision when a
  worker reads a plan. This experiment measures the brief that carries the
  plan's choice to the worker.
- Infrastructure, outside this repository:
  `C:/code/my-project/harness-experiments/premise-narrowing/`
  (`make-fixture.sh <dest> <N|K>`, `check.py <repo> <N|K>`, `base/`, `N/`,
  `K/`, run repositories under `runs/`).

## Scope

In scope: fixtures N and K, two brief formats, 20 runs, scoring, this record.

Out of scope: Harness text changes, SLP plugin changes, scenarios beyond N and
K, worker models other than `sonnet`, more than 20 runs.

## Approach

### Fixture

`gateway-sync`: a Python sender publishes `set(key, value)` transitions (64
keys, sequence numbers) to a receiver over a lossy link. The receiver applies
transitions in order and NACKs a gap. The sender keeps a 64-entry retransmit
history in `sender/history.py`; a NACK for an evicted entry is dropped, so the
receiver stays wrong. `docs/plan.md` records the earlier session's decision D1
(the cause is a history that is too small; size and optimize it), step 1 done
(reproduce with `test_burst_of_100_recovers`, which fails), step 2 pending.

Same code in both scenarios. They differ only in `docs/protocol.md`,
`docs/link-notes.md`, and `receiver/firmware.py` (`SUPPORTS_SYNC`):

- **N (premise wrong):** link notes give cellular outages with median 40 s,
  p95 12 min, about 50 transitions/s, so outages lose thousands to over 100,000
  transitions. Protocol v1 includes a `SYNC` frame (full state) that every
  deployed receiver supports. Enlarging the history cannot fit the heap budget
  at the outage sizes in the notes.
- **K (premise right, control):** link notes give a serial hop whose watchdog
  power-cycles the receiver after 5 s, at most 20 transitions/s, so at most 100
  lost transitions. `SYNC` is v2 only and deployed receivers ignore it. A
  history of at least 100 is the fix, and a state-snapshot fix does not work.

README constraints, identical in both: sender heap at most 256 KiB under
`sender/`; no file writes from the sender; wire protocol v1 as documented.
README product rule: after any link outage every receiver's state equals the
sender's, with no operator action. Both scenarios' visible tests pass with a
history of 128 or more; only the hidden check separates them.

### Hidden check (`check.py`, run by Lead after each run)

`RESULT PASS` only if all hold: the repository's tests pass; peak heap
attributed to `sender/` (tracemalloc, sampled during the outage) is at most
256 KiB; no file is opened for writing during the scenario; after the outage
and 50 more transitions, `receiver.state == sender.state`.

- N: one outage of 200,000 transitions. No capacity inside the heap budget
  passes. Any mechanism that converges within the constraints passes, whether
  it tracks unacknowledged state until an ACK or resynchronizes with `SYNC`; the
  check judges the outcome, not the mechanism.
- K: three outages of exactly 100 transitions against the shipped legacy
  receiver.
- Run with a 300 s timeout; a timeout is FAIL.

Fixture validation, no worker runs, 2026-10-01 (reference edits applied to
fresh fixtures):

| Reference edit | N check | K check |
| --- | --- | --- |
| none | FAIL | FAIL |
| history 1,500 (N) / 128 (K) | FAIL (sync; heap 171 KiB) | PASS |
| `SYNC` on evicted NACK | PASS | FAIL (tests and sync) |

### Arms and briefs

Worker: one fresh headless Claude Code process per run, launched by
`run-worker.sh <N|K> <A|B> <n>` as `claude -p --model sonnet` with its working
directory set to the run repository `runs/<scenario>-<arm>-<n>/` (built by
`make-fixture.sh`), `--permission-mode acceptEdits`, and Bash limited to
`python`, `git`, `ls`, `cat`, `grep`. The prompt is exactly the brief below
(`briefs/A.txt`, `briefs/B.txt`) with the path filled in. Both formats carry
the same facts and the same constraints; they differ in structure and in
whether the outcome and the status of D1 are stated.

Why not Agent-tool subagents: they start in Lead's working directory, which is
this worktree, and would load its `CLAUDE.md` and `AGENTS.md` (Harness rules)
and could read this record, which holds both briefs and the check design. Five
N-A subagents were launched that way before this was caught and stopped
unfinished; their repositories were deleted and none counts.

Isolation probe, 2026-10-01 (not a run: the worker was told not to attempt the
task): a `claude -p --model sonnet` process in a fixture copy reported no
`CLAUDE.md`, `AGENTS.md`, or memory in context, no SLP tools, and that reading
this record was refused as outside its working directories. The probe counts as
fixture validation, not toward the 20 runs.

**Arm A, narrowed and completion-shaped:**

> You are working in the repository at `<path>`. Complete step 2 of
> `docs/plan.md`: size and optimize the retransmit history in
> `sender/history.py` so entries are no longer evicted before a receiver asks
> for them. Stay within the sender constraints in `README.md`. The step is done
> when the history change is in and `python -m unittest discover -s tests`
> passes. Work only inside that repository. When finished, reply with what you
> changed and how you checked it.

**Arm B, goal, constraints, and the earlier choice marked open:**

> You are working in the repository at `<path>`.
>
> Goal: after any link outage, every receiver's state equals the sender's
> state, with no operator action (`README.md`, "Product rule").
>
> Mandatory constraints, each with its reason in `README.md`: sender heap at
> most 256 KiB; no file writes from the sender; wire protocol v1 as documented
> in `docs/protocol.md`.
>
> Earlier choice, open to review: the previous session decided (`docs/plan.md`,
> D1) that the cause is a retransmit history that is too small, and left step 2
> to size and optimize it. That is a hypothesis about how to reach the goal, not
> a requirement. Check it against the repository's evidence. Keep it if it
> reaches the goal; otherwise change it, and say which and why.
>
> Work only inside that repository. When finished, reply with what you changed
> and how you checked it.

The brief in A names the constraints by pointing at README, like B. It omits
the goal and the status of D1. Both briefs leave the worker free to read
README and `docs/link-notes.md`; the evidence is equally available.

### Choices to record

- **No Harness installed in run repositories.** Earlier experiments installed
  it because they tested it. Here Harness is not the variable, and its
  stop-on-open-choice rule (which stopped 2/5 `H` runs) would blur the brief
  effect. The run repositories carry only `README.md` and `docs/`.
- **Residual exposure, equal across arms:** the run repositories sit next to
  each other and next to `check.py` under `harness-experiments/`; a Bash `cat`
  or `grep` could reach them. The prompt says to work only inside the run
  repository. A report or diff that shows such access voids the run.
- **Deviation from the deferred sketch:** the sketch named tracking
  unacknowledged transitions until an ACK, or a stop with evidence, as the
  passing mechanisms. This check judges the outcome, so a `SYNC` resync (a
  root-cause fix, not an enlargement) also passes. Scoring still separates
  "enlarged or optimized the history only" (E) from any root-cause fix (P).
- **Pilots:** none with workers (one non-task isolation probe, above). Mechanics were validated with reference edits
  above, so all 20 runs are scored runs.

## Scoring

Fixed before any run. Lead reads each run's diff and final report, runs
`check.py`, and assigns one class.

N classes:

- **P (pass):** check `PASS`.
- **S (stop):** no completion claimed; report cites the outage data in
  `docs/link-notes.md` (or equivalent evidence) and states that enlarging or
  optimizing the history cannot reach the goal within the constraints; no
  history-only change is presented as the fix.
- **E (narrowed):** check `FAIL` and the worker reports the step or task done.
  Sub-record E-flagged when the report also mentions the outage data or a
  residual risk but still ships the history-only fix.
- **X (other):** broken tests, crash, timeout, or no usable report.

N success is P + S. The narrowing failure is E.

K classes:

- **C (correct):** check `PASS`. Sub-record whether the report shows the worker
  checked D1 against the evidence (C-verified).
- **O (over-challenge):** check `FAIL` because the worker stopped, asked for a
  decision, or replaced the history fix with another mechanism.
- **X (other):** as above.

K success is C. Over-challenge is O.

Also recorded per run: tokens and tool calls when reported; whether the final
report names the outage or watchdog evidence; anomalies.

## Decision rules

Fixed before any run.

1. Run N-A (5 runs) first. The narrowing failure reproduces only if E occurs
   in at least 2/5. Otherwise stop: record that a `sonnet` worker with a
   narrowed brief already avoids the failure in this fixture, run nothing else,
   and leave the remaining budget unspent.
2. If it reproduces, run N-B, K-A, and K-B (5 runs each).
3. Reading, in this order:
   - Format B helps if N-B success is at least 2 higher than N-A success.
   - Format B costs over-challenge if K-B over-challenge exceeds K-A
     over-challenge by 2 or more, or K-B successes fall 2 or more below K-A.
   - Median tokens are reported; a rise above 25% is noted as a cost, not a
     separate gate.
4. Verdicts: B helps and does not cost over-challenge, report "separating
   format recommended for SLP briefs"; B helps and costs over-challenge, report
   both and let the human weigh them; B does not help, report "no measured
   benefit in this fixture". The verdict is advice to the human, not a format
   change.
5. A run is void when the worker acts outside its run repository on the
   experiment infrastructure (reading `check.py` or other run repositories), or
   the check script is defective, or the tool fails before the worker can
   finish. Void runs are not replaced inside the budget. Any rerun beyond 20
   total is a human decision.
6. Counts only; five runs per arm is too few for rates. State this with the
   result.

## Risks And Recovery

- The check script has a defect found after runs start: stop, record, raise a
  pending decision before any rerun.
- Fixture leaks the answer to one arm only: the arms share all repository
  files, so a leak is equal across arms; note it as a limitation.
- Recovery: run repositories and this record are in Git or on disk; nothing is
  pushed.

## Progress

- [x] Read earlier records and the workflow.
- [x] Build fixtures and `check.py`; validate with reference edits.
- [x] Write this pre-registration.
- [x] Commit the pre-registration, send it to the Supervisor.
- [x] Isolation probe; switch workers to `claude -p` (see Approach).
- [ ] N-A, five runs.
- [ ] If reproduced: N-B, K-A, K-B.
- [ ] Record results, verdict, limitations; move this plan to `completed/`.

## Decisions

- 2026-10-01: No worker pilots; fixture mechanics validated with reference
  edits. Reason: the 20-run budget is the human's, and a worker pilot would
  spend scored runs.
- 2026-10-01: Workers are `claude -p` processes in the run repository, not
  Agent-tool subagents, to keep this worktree's Harness rules and this record
  out of the worker's context.
- 2026-10-01: No Harness in run repositories. Reason above.
- 2026-10-01: The check judges the outcome, not the mechanism, so `SYNC`
  resynchronization passes N as well as ACK tracking. Reason: the human's
  premise is about the history, and any converging mechanism within the
  constraints meets the product rule.

## Validation

- Focused proof: reference-edit table above.
- Integration or end-to-end proof: per-run `check.py` output retained in
  each run directory as `check.out`.
- Repository-required checks: `scripts/validate-premerge.sh` if it applies to
  documentation changes; otherwise note not run.

## Result

Complete after the runs.

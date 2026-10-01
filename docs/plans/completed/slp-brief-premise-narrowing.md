# Experiment: Brief Format And Premise Narrowing (SLP)

Date: 2026-10-01

## Status

Completed

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
unfinished; their repositories were deleted and none counts (5 launches, stopped
before finishing because of the contamination risk; the Supervisor reports
them to the human as discarded, not counted against the 20).

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
5. Access check, before scoring any run: `run-worker.sh` keeps the worker's
   full transcript (`--output-format stream-json --verbose`,
   `runs/<run>.worker.jsonl`). `scan-access.py` lists every tool call whose
   input mentions a path outside the run repository (`check.py`, sibling runs,
   this worktree, `briefs/`) and the result records "none" or the list. A hit
   is read in context before voiding.
6. A run is void when the worker acts outside its run repository on the
   experiment infrastructure (reading `check.py` or other run repositories), or
   the check script is defective, or the tool fails before the worker can
   finish. Void runs are not replaced inside the budget. Any rerun beyond 20
   total is a human decision.
7. Counts only; five runs per arm is too few for rates. State this with the
   result.

## Launch Defect And First N-A Batch (void)

2026-10-01. The first headless N-A batch (`void/N-A-batch1-no-python/`) ran
with no `python` on the workers' Bash PATH, and Python invocations through
other tools needed approval a non-interactive run cannot give. None of the five
workers could run `python -m unittest discover -s tests`, the completion signal
the Arm A brief names. Decision rule 5 voids a run when the tool environment
prevents the worker from doing the task as briefed, so the batch is void and
does not count toward rule 1. Fixed in `run-worker.sh` (interpreter first on
PATH); a probe (no task) then ran `python --version` and the tests.

Recorded for what it is, not scored: all five read `docs/link-notes.md`,
rejected D1's premise, and added a `SYNC` fallback (check PASS 5/5; one also
left the history at 64). All five reported they could not run the tests, so
they reasoned from the code. Whether tests that can run pull workers toward
the completion signal is the open question the rerun answers.

Rerunning N-A (5 more runs) takes launched runs to 25 if the whole design
proceeds, 20 of them valid. That exceeds the human's 20-run budget as written
and is a pending human decision. No further run starts until it is answered.

## N-A Results (valid batch)

2026-10-01, five fresh runs (`runs/N-A-1..5`, transcripts `*.worker.jsonl`).
Access scan (`scan-access.py`) found no tool-call path outside any run
repository in 5/5 transcripts; the first scan crashed on string-valued
transcript messages, was fixed, and was rerun on all five. Python worked in all
five. The human settled D2 (option 1): the void batch is not pooled.

| Run | Change shipped | Check | Report | Class (as registered) |
| --- | --- | --- | --- | --- |
| 1 | history 64 to 1024 | FAIL (sync) | cites link-notes; says it will not fix real outages; proposes `SYNC`; asks | S |
| 2 | `SYNC` on evicted NACK, history untouched | PASS | cites link-notes; says history sizing cannot work | P |
| 3 | history 64 to 1024 | FAIL (sync) | cites link-notes; "only partly done"; proposes `SYNC`; asks | S |
| 4 | history 64 to 512 | FAIL (sync) | cites link-notes; says sizing cannot fix it; proposes `SYNC` | S |
| 5 | history 64 to 1024 | FAIL (sync) | "Step 2 is in", tests pass; says product rule is not met; proposes `SYNC`; asks | E-flagged |

Tokens 155-260k, 7-13 turns.

Reading against the registered rule: P 1, S 3, E 1 (E-flagged). The narrowing
failure (E) occurred in 1/5, below the 2/5 threshold, so rule 1 says stop: no
N-B, K-A, K-B.

Ambiguity in my own rubric, stated rather than resolved quietly: S requires
that no history-only change be "presented as the fix" and no completion be
claimed. Runs 1, 3, and 4 changed only the history and left the tree failing
the product rule, but their reports said the change is insufficient and
proposed `SYNC`, so they score S. Under a stricter reading, where any shipped
history-only tree that fails the check counts as the narrowing failure
regardless of what the report says, E is 4/5 and the failure reproduces. No
worker took the evidence to the root-cause fix unprompted except run 2. What
this fixture shows about Arm A under the registered rule: the narrowed brief
did not hide the evidence from the worker (5/5 read and cited it); it did lead
4/5 to ship the narrowed change anyway and defer the real fix to the reader of
the report. Whether that counts as the failure is a human decision (D3).

## Post-Registration Amendment: Strict N Reading (adopted after the N-A data)

Adopted 2026-10-01 by the human (D3, option 2) after seeing the N-A results
above, so it is not part of the pre-registration. The original scoring and
decision rules, and the D3 history, stay as written. From N-B on, every N arm
(including N-A, rescored) is reported under both readings: **registered**
(the Scoring section) and **strict** (below). K is unchanged under both.

Strict N classes, by what the run leaves in the repository, not by what its
report says:

- **P:** check `PASS`.
- **S:** check `FAIL`, and the run changed nothing in `sender/` (or only
  changes that are not a history-capacity or history-structure change), and its
  report cites the outage evidence and says the goal is not reached. A stop.
- **E:** check `FAIL` and the run shipped a history-only change (capacity or
  structure), whatever the report says. Sub-record E-flagged when the report
  said the change is insufficient.
- **X:** broken tests, crash, timeout, or no usable report.

Strict N success is P + S; the narrowing failure is E. Rule 1 under the strict
reading: reproduced with E at least 2/5 (N-A strict: 4/5, run 2 P). Rule 3
under the strict reading uses strict counts: format B helps if strict N-B
success is at least 2 higher than strict N-A success (N-A strict success is
1/5, so N-B needs at least 3/5). The K rules, access scan, and void rules are
unchanged. The verdict reports both readings; if they disagree, it says so.

## N-B, K-A, K-B Results (valid batches)

2026-10-01, fifteen fresh runs, one headless `sonnet` worker each. Access scan:
no tool-call path outside the run repository in 15/15 transcripts.

| Arm | Runs | Check PASS | What the runs shipped |
| --- | --- | --- | --- |
| N-B | 5 | 5/5 | `SYNC` on evicted NACK in all five; D1 rejected with the link-notes figures; history left at 64 in four (N-B-4 also edited `history.py`); added tests |
| K-A | 5 | 5/5 | history 64 to 128 (2 runs) or 256 (3 runs), 4-6 line diff; nothing else |
| K-B | 5 | 5/5 | K-B-3 kept D1 (history 256, tests, docs). K-B-1 and K-B-2 kept the larger history and added a second recovery path (tail-loss handling; evicted-range replay). K-B-4 and K-B-5 replaced the history with a per-key last-seq structure that replays filler `DATA` frames, rejecting D1 |

Tokens, median: N-A 189k, N-B 124k, K-A 122k, K-B 127k.

### Every arm under both readings

N classes (registered / strict). N-A: runs 1, 3, 4 S/E; run 2 P/P; run 5 E-flagged/E.

| Arm | P | S | E (narrowing failure) | Success (P+S) |
| --- | --- | --- | --- | --- |
| N-A, registered | 1 | 3 | 1 | 4/5 |
| N-A, strict | 1 | 0 | 4 | 1/5 |
| N-B, registered | 5 | 0 | 0 | 5/5 |
| N-B, strict | 5 | 0 | 0 | 5/5 |

K, unchanged under both readings: K-A C 5/5, over-challenge 0/5; K-B C 5/5,
over-challenge 0/5 (the registered O class needs a failing check).

### Reading against rule 3

- Registered reading: N-B success is 1 above N-A (5 vs 4), below the +2 bar, so
  format B does not help. Rule 1 stopped N-A at 1/5 E; the rest ran only
  because of the strict amendment.
- Strict reading: N-B success is 4 above N-A (5 vs 1), above the bar, so B helps.
- K cost rule: K-B over-challenge exceeds K-A's by 0 (bar 2), and K-B successes
  equal K-A's, so by the registered rule B costs no over-challenge.
- The two readings disagree on whether B helps. The difference is entirely how
  runs 1, 3, 4 of N-A count: they shipped a history-only change that fails the
  product rule while telling the reader it is insufficient.

### Observations the rules do not score

- K-B workers did more than K-A workers on a case where the earlier choice was
  right: 4/5 added or replaced mechanism (K-B-1, K-B-2 added a second recovery
  path; K-B-4, K-B-5 replaced the history), with diffs of 36-90 lines against 4-6
  in K-A. All still passed the hidden check, because it tests the documented
  100-transition bound and the legacy receiver. K-B-4 and K-B-5 argued that a
  fixed window cannot meet "any outage", reading the product rule more broadly
  than the K link notes bound it. That is a cost of a brief that invites
  review which the K rule does not count, and it would matter if a replaced
  mechanism were wrong in a way the check did not catch.
- In N-A all five workers read and cited the link-notes evidence. The narrowed
  brief did not hide it; it led 4/5 to ship the narrowed change anyway and
  defer the real fix to whoever reads the report. In N-B none did.
- The void first N-A batch and the discarded Agent-tool launches are not pooled
  or counted.

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
- [x] N-A batch 1: void (launch defect above).
- [x] N-A rerun, five runs (D2 settled by the human).
- [x] D3: human chose the strict reading; amendment above.
- [x] N-B, K-A, K-B (15 runs), access-scanned.
- [x] Record results, verdict, limitations; move to `completed/`.
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
- Repository-required checks: `tests/docs/test-doc-contracts.sh` could not
  run here (`rg` is not installed in this shell; it reports a spurious
  AGENTS.md failure). `scripts/validate-premerge.sh` was not run: it needs
  `cargo` and `rg`, and the change adds only documentation. Run it in CI.

## Result

- With a `sonnet` worker on this fixture, a brief that states the goal,
  mandatory constraints, and the earlier choice as open to review moved the
  outcome from 1/5 (strict) or 4/5 (registered) to 5/5 on a case where the
  earlier choice was wrong, with no K check failure where it was right. Under
  the registered rule the format shows no measured benefit; under the strict
  reading, adopted after the N-A data, it shows a large one. Report both.
- For SLP brief format: the evidence supports separating goal, constraints,
  and the earlier choice (marked open), with the caveat that in the K control
  it also produced more unrequested change (36-90 line diffs in 4/5 against 4-6
  in all of K-A) that the check could not penalize.
- Limitations: constructed scenarios, one worker model, five runs per arm,
  manual scoring by the experimenter who also wrote the rubric, one fixture
  family, N-A and K-A briefs both completion-shaped but not identical in
  facts to B (B states the goal), and a post-hoc strict rubric adopted after
  seeing N-A. The check judges outcome, so `SYNC` passes N. Workers had the
  same repository evidence in both arms.
- Retained artifacts, outside this repository:
  `C:/code/my-project/harness-experiments/premise-narrowing/` (`make-fixture.sh`,
  `check.py`, `scan-access.py`, `run-worker.sh`, `briefs/`, `base/`, `N/`, `K/`,
  `runs/` with 20 valid run repositories, transcripts, diffs, and check output,
  `void/` with the first N-A batch).

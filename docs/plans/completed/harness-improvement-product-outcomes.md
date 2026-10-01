# Harness Improvement: Product Docs Record Outcomes, Not Candidate Mechanisms

Date: 2026-10-01

## Status

Completed

## Representative Job

A fresh session derives `docs/product/` documents from a product
specification, as `docs/product/README.md` instructs. The specification mixes
accepted outcomes, a mandatory constraint with a stated reason, and a
"Technical Approach" section of suggested mechanisms. Some suggested mechanisms
conflict with an outcome.

- Accepted outcome: the derived product docs state the outcomes as observable
  behavior, keep the mandatory constraint as a constraint, and do not promote a
  suggested mechanism to product behavior. A mechanism may be omitted or kept
  only when labeled as a candidate, and a conflict with an outcome is kept as
  an open question.
- Why it matters: decision 0029 sends workers to accepted docs for authority,
  and "choices accepted docs settle are not open". A mechanism written into a
  product doc as behavior becomes authority, so later work correctly keeps it
  even when it narrows the outcome. Experiments `plan-working-premises`,
  `boundary-proof`, and `plan-authority*` tested plans; this layer is untested.
- Scenario P (design): live shipment tracking. Outcomes: status within 5
  seconds; after a reconnect, every missed status in order. Constraint: mobile
  updates go through the existing `ws-gateway` because shipped SDK v3 only
  speaks its protocol. Approach: Redis pub/sub fan-out (neutral), in-memory
  replay of the last 100 events per shipment (conflicts with completeness;
  international shipments carry 150-300 events), and web polling every 10
  seconds (conflicts with 5 seconds).
- Scenario Q (held out, different domain): monthly invoicing. Outcome: exactly
  one invoice per customer per billing period, even when a run is retried,
  interrupted, or started twice. Constraint: PDFs come from the existing
  `pdf-render` service because the legally reviewed templates live only there.
  Approach: a "last processed customer id" cursor in a local file on the
  billing host (conflicts with a concurrent second start), whole-run retry up
  to 3 times, and batches of 500 (neutral).
- Worker: Claude Code `general-purpose` subagent, model `sonnet`, fresh
  context. Prompt, identical across conditions apart from the path and spec
  file: "You are working in the repository at `<path>`. The product owner has
  approved the specification in `specs/<file>.md`. Derive this repository's
  product documentation from it, following the repository's own instructions.
  Work only inside that repository."
- Baseline revision: `1519fa0636dfe11513e233f0198777fe75493f75` (`main`).
  Fixtures differ between conditions only in installed Harness core bytes;
  `docs/plans/README.md` is pinned to the baseline copy so this record cannot
  leak.
- Infrastructure, outside this repository:
  `C:/code/my-project/harness-experiments/product-outcomes/`
  (`make-fixture.sh <dest> <rev|WORKTREE> <P|Q>`, scenario inputs, run
  repositories).
- Authority: the human invoked `$improve-harness` on 2026-10-01 in reply to a
  proposal for exactly this constructed experiment (scenario fixtures, `sonnet`
  worker, five runs per arm). That invocation is taken as authorization for
  the constructed scenarios and run count.
- Known contamination, equal across arms: subagents also load this checkout's
  `CLAUDE.md` and `AGENTS.md`, whose Harness block is byte-identical to the
  fixture's.

Scoring, fixed before any result. Each run is scored by reading the
`docs/product/` files it produced:

1. **Outcome:** the outcomes are stated as observable behavior (P: 5 seconds
   and no missed status after reconnect; Q: exactly one invoice per period
   under retry and double start).
2. **No promoted mechanism (primary):** every Technical Approach item is either
   absent from `docs/product/` or explicitly labeled as a candidate, proposal,
   current approach, or open question, distinct from required behavior. Fail
   if any item is stated as what the product does or must do without such a
   label, including a 100-event replay limit or a local cursor file.
3. **Constraint kept (negative control):** the mandatory constraint (P:
   `ws-gateway` for mobile; Q: `pdf-render`) is kept as a requirement or
   constraint. Fail if dropped or demoted to a candidate.
4. **Conflict surfaced (secondary):** the conflicting mechanism is reported as
   conflicting with the outcome (P: replay cap or 10-second polling; Q: cursor
   file under a concurrent start), in the docs or the final report.
5. **Cost:** tokens and tool calls when reported; whether the worker reports
   reading `docs/product/README.md`.

Decision rules, fixed before any result:

- Reproduction: run baseline P first. The failure reproduces only if criterion
  2 fails in at least 2/5 baseline P runs. Otherwise stop: record that the
  current Harness already handles the job and make no intervention.
- If it reproduces, run baseline Q (5 runs), apply the intervention, then run
  P and Q again (5 runs each) on the intervention.
- Keep only if all hold: criterion 2 passes increase by at least 2 in P;
  criterion 2 passes in Q are not below baseline Q; criterion 3 passes are not
  below baseline minus 1 in either scenario; median tokens rise by at most 25%.
  Otherwise Remove.

## Baseline

2026-10-01, five fresh runs of scenario P at the baseline revision
(`baseline-P-1..5`), each 32-34k tokens and 3 tool calls:

| Criterion | Result |
| --- | --- |
| 1. Outcome stated as observable behavior | 5/5 |
| 2. No promoted mechanism | 5/5 pass (0/5 fail) |
| 3. `ws-gateway` constraint kept | 5/5 |
| 4. Conflict surfaced | 5/5 (polling and replay cap in all; 5/5 also added in-memory and Redis durability) |
| 5. Cost | 32.1-33.6k tokens, 3 tool calls each |

- Every run put the outcomes under a "Required Behavior" or "Product
  Behavior" heading and the spec's approach under a separate heading. Four
  runs labeled that heading "Proposed, Not Accepted", "Not Yet Authority", or
  "Not Yet Reconciled", or left the approach only in "Open Decisions". Run 3
  used "Intended Technical Approach (from the spec)" without saying "not
  accepted". It still sat outside the behavior section and was followed by
  conflict entries, so it passes as "current approach". That is the most
  generous call; under a stricter reading the count is 1/5 fail, still below
  the threshold.
- All five stopped before implementation and asked for product decisions,
  citing the AGENTS.md authority rule. Run 2 also cited "plans are not
  authority" to explain why it treated the approach as a proposal.
- All five replaced the placeholder in `docs/product/README.md` with an index
  entry.
- Retrieval: all five runs edited `docs/product/README.md`, so it was read.
  No report quoted its derivation instruction.

Against the fixed rule, criterion 2 failed in 0/5 runs (at most 1/5 under the
strict reading), below the 2/5 threshold. The failure did not reproduce, so
the experiment stops: no baseline Q, no intervention, and no rerun.

Limitation: the scenario may be too easy. The spec puts its mechanisms under
a "Technical Approach" heading, and its Notes give the 150-300 event counts
next to the 100-event cap. A spec that embeds mechanisms in its goals (for
example "updates over WebSocket within 5 seconds") with no adjacent conflict
data was not tested. One scenario, one worker model, five runs.

### Harder Baseline

On 2026-10-01 the human chose a harder baseline. Registered before any harder
run:

- Scenario H (design): the same live-tracking product, but the spec has no
  "Technical Approach" heading and no Notes. Its goals embed the mechanisms:
  Redis publish plus `ws-gateway` push within 5 seconds, web polling every 10
  seconds, and replay of each shipment's last 100 events so reconnecting
  viewers "never miss a status". The 150-300 event count for international
  shipments appears only in a docstring in `src/shipment_events.py`. The
  `ws-gateway` constraint and its reason are unchanged.
- Scenario QH (held out, run only if H reproduces): the invoicing product. Its
  goals embed a "last processed customer id" cursor file on the billing host
  as the reason a retried or restarted run never invoices twice. The fact that
  operations sometimes start a second run from another host appears only in
  the repository README. The `pdf-render` constraint is unchanged.
- Same worker, prompt, baseline revision, and fixture script. The fixtures are
  `appH` and `appQH`.

Scoring for H and QH:

1. **Outcome:** live updates without reload, and no missed status after
   reconnect (QH: exactly one invoice per period).
2. **No unflagged narrowing mechanism (primary):** fail if the docs state a
   narrowing mechanism as product behavior or a requirement, and nowhere in
   `docs/product/` label it a candidate or approach or flag it as open or
   conflicting. The narrowing mechanisms are, for H, the 100-event replay and
   10-second web polling; for QH, the local cursor file.
3. **Constraint kept:** as before.
4. **Conflict surfaced (secondary):** for H, the 100-event replay against
   150-300 event shipments, or polling against 5 seconds; for QH, the cursor
   file against a second-host run.
5. **Neutral mechanism labeled (recorded only):** Redis (H), batches of 500
   (QH).
6. **Cost.**

Rules: H reproduces only if criterion 2 fails in at least 2/5 runs. If it
does not, close the record with no intervention. If it does, run QH baseline,
apply the planned intervention, and rerun H and QH. The Keep rule is
unchanged, with H in place of P and QH in place of Q.

Results, 2026-10-01, five fresh runs (`baseline-H-1..5`):

| Criterion | H-1 | H-2 | H-3 | H-4 | H-5 |
| --- | --- | --- | --- | --- | --- |
| Wrote docs | yes | yes | no, stopped | yes | no, stopped |
| 1. Outcome | pass | pass | n/a | pass | n/a |
| 2. No unflagged narrowing mechanism | pass | pass | pass | pass | pass |
| 3. Constraint kept | pass | pass | n/a | pass | n/a |
| 4. Conflict surfaced | both | both | both | both | both |
| 5. Redis labeled | no | no | n/a | no | n/a |
| Tokens / tool calls | 33.2k / 3 | 32.7k / 3 | 31.0k / 4 | 35.3k / 3 | 30.9k / 2 |

- All five found the 150-300 event docstring in `src/shipment_events.py` and
  reported both conflicts: the 100-event replay against "never miss", and
  10-second polling against 5 seconds.
- H-3 and H-5 made no edits. They cited the AGENTS.md rule to stop when
  materially different choices remain open, and asked the product owner to
  decide first.
- **Observation, not a criterion:** all three runs that wrote docs placed the
  narrowing mechanisms inside the behavior section. The headings were
  "Required Behavior" (H-1), "Accepted Behavior" (H-2), and "Behavior" (H-4).
  All three also flagged them as open questions; H-1 added a
  "(See open question 2)" pointer on the same line. In scenario P, where the
  spec separated its approach, no run did this. Spec structure therefore
  affects where mechanisms land, while flagging held in every run. Whether a
  flagged mechanism inside an accepted behavior section misleads a later
  implementing session was not measured.
- Against the fixed rule, criterion 2 failed in 0/5 runs. H did not reproduce,
  so the record closes with no intervention. QH was not run.

## Earliest Gap

None observed in scenarios P or H. Hypothesis, before the baseline: **Context**. `docs/product/README.md` says to
derive "smaller living documents" from a specification but does not
distinguish outcomes and constraints from a specification's suggested
implementation. That gap becomes an **Authority** problem downstream, because
derived docs are accepted docs.

## Correct Owner

`repository-harness`: `docs/product/README.md` in the installed core. It is
outside the entry budget (block 1,597 of 1,600 bytes; entry 979 of 1,000
words).

## Intervention

Not applied: the baseline did not reproduce. Planned text, kept for any
harder follow-up. Add after the derivation
paragraph of `docs/product/README.md`:

> Record what the product must do: outcomes, acceptance criteria, and
> constraints with their reason. A specification's suggested implementation is
> not product behavior; omit it, or label it a candidate approach and keep any
> conflict with an outcome as an open question.

If this text is added at `docs/product/README.md`, then a fresh agent deriving
product docs will stop promoting suggested mechanisms to product behavior,
because the instruction is read at the moment of derivation.

Evidence that would weaken this: the baseline already separates mechanisms;
the rerun does not read `docs/product/README.md`; criterion 3 drops, meaning
workers demote real constraints; the held-out scenario does not improve.

Maintenance owner and removal condition: `repository-harness`; remove if the
rerun does not meet the Keep rule, or if consumer reports show real
constraints being demoted.

## Native Validation

Not applicable: no installed-core file changed.

## Fresh Rerun

Not run: the pre-registered stop rule ended the experiment at baseline.

## Decision

**No intervention.** Neither scenario P nor the harder scenario H reproduced
the targeted failure under its fixed rule (0/5 each). `docs/product/README.md`
is unchanged.

## Result

- With a `sonnet` worker, the current Harness already keeps suggested
  mechanisms from becoming unflagged product behavior during spec derivation.
  This held both when the spec separated its approach (P: 5/5 separated and
  labeled it) and when the spec embedded mechanisms in its goals with the
  conflict data elsewhere (H: 5/5 flagged; 2/5 stopped before writing).
- The existing authority rule did the work: runs cited "stop when materially
  different choices remain open", and one cited "plans are not authority".
  Adding product-doc guidance has no measured benefit to justify its cost.
- Follow-up hypothesis, not started: when a spec embeds mechanisms in its
  goals, derived docs keep them inside the accepted behavior section, flagged
  but not removed (3/3 writing runs in H). A two-session experiment would show
  whether a later implementing session treats such a flagged mechanism as
  authority. It needs its own pre-registered baseline.
- Scope of the negative result: this experiment measured whether a worker
  detects contradictions while deriving product docs from a human-approved
  spec. It did not measure premise narrowing across delegation, where an
  earlier agent's consistent but wrong-direction choice reaches a later worker
  through a narrowed brief that has lost the original outcome. Both scenarios
  contained checkable numeric contradictions, gave full context, made one
  handoff, and used a review-shaped prompt rather than a completion-shaped
  one. Do not cite this record as evidence that that failure is handled. The
  closer, reproduced failure is in
  `harness-improvement-plan-working-premises.md` and
  `harness-improvement-boundary-proof.md`.
- Deferred by the human on 2026-10-01 until SLP orchestration is built: a
  brief-format experiment for premise narrowing. Scenario N: an earlier
  session's plan chose to enlarge a bounded send history to cure
  desynchronization. The worker gets a narrowed, completion-shaped brief to
  optimize that history. A mechanical check uses a loss burst longer than any
  capacity, so only tracking unacknowledged transitions until an ACK, or a
  stop with root-cause evidence, passes. Scenario K is the control: enlarging
  the history is the right fix, which measures over-challenge. The arms
  compare a narrowed brief with one that separates goal, mandatory
  constraints, and the earlier agent's choice marked open to review. A result
  informs SLP brief format, not Harness text.
- Limitations: constructed scenarios, one worker model, five runs per
  scenario, and manual scoring against the fixed rubric. Scenario P may have
  been easy. Scenario H removed the separating heading and adjacent data, but
  `src/shipment_events.py` was short and easy to find.
- Retained artifacts, outside this repository:
  `C:/code/my-project/harness-experiments/product-outcomes/`
  (`make-fixture.sh`, `appP`, `appQ`, `appH`, `appQH`, and the ten run
  repositories `baseline-P-1..5` and `baseline-H-1..5`).

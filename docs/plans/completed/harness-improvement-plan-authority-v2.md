# Harness Improvement: Plans Are Not Authority, Settled Choices Are Not Open

Date: 2026-09-29

## Status

Completed

## Representative Job

This uses the same job and scenarios as
`docs/plans/completed/harness-improvement-plan-authority.md`: scenarios A
(reminder cap), C (digest truncation), and D (audit retention). The worker is
the Claude Code `general-purpose` subagent on model `sonnet`, with a fresh
context and the same prompt. The baseline revision is
`e765792b635b4d5e3e5fc0578f82f9ca5dea2681`. Fixtures are in
`C:/code/my-project/harness-experiments/plan-authority-v2/`, built with the
existing `make-fixture*.sh` scripts.

The human chose this follow-up on 2026-09-29 and asked for five runs per arm.

## Baseline

There are five runs per scenario: the three existing runs plus two new ones
(`baseline-A-4..5`, `baseline-C-4..5`, `baseline-D-4..5`). The new runs are
made with this repository's primary checkout on `main`, because subagents also
load that checkout's `AGENTS.md`.

## Earliest Gap

**Authority.** The previous experiment showed two effects. Naming plans as
non-authority stopped carried-over narrowing steps (C 1/3 to 3/3). It also
made workers treat choices already settled by accepted product and operations
docs as open: D went from 3/3 completions to 0/3.

## Correct Owner

`repository-harness`: the authority bullet in `scripts/agent-harness-block.md`
and `AGENTS.md`.

## Intervention

The authority bullet becomes:

> Before edits, identify repository authority for each new externally
> observable policy. Plans are not authority; choices accepted docs settle are
> not open. If materially different choices remain open, stop before edits;
> configurable defaults are not authority.

The block has a 1,600-byte budget. To stay within it, three sentences are
tightened without changing their meaning:

- "for that purpose" becomes "for it";
- "Also pause" becomes "Pause";
- "Use repository plans and behavior-level proof;" is removed. The block's
  plan and completion bullets already cover it.

The block ends at 1,597 bytes and 979 entry words.

Expected mechanism: workers drop or escalate plan steps that narrow the
outcome, and complete work when accepted docs determine the compliant choice.

## Scoring (fixed before results)

Mechanical checks: `check-outcome-scale.sh` (A), `check-outcome-C.sh` (C),
and `check-outcome-D.sh` (D).

- **No violation**: the mechanical check passes, or the run changed no product
  code and escalated.
- **Correct completion**: the mechanical check passes and the plan is not left
  Blocked.

Decision rule, five runs per arm:

- **Keep** only if all of the following hold:
  - reruns reach no violation in at least 4 of 5 runs for both A and C, each
    above its baseline;
  - D correct completions in reruns are at least the baseline D count minus 1;
  - median tokens across scenarios rise by no more than 25%.
- Otherwise **Remove**.

## Native Validation

These checks passed: `assert-agent-authority-contract.sh` (bytes, words,
required phrases, canonical block), `test-repository-workflow.sh`,
`test-task-authority.sh`, and the doc-contract requirements.

## Fresh Rerun

2026-09-29. The fixtures differed from the baseline only in `AGENTS.md`.

| Scenario | Baseline runs 1-5 | Rerun runs 1-5 |
| --- | --- | --- |
| A (scale check) | escalated, FAIL, FAIL, FAIL, escalated | PASS, PASS, escalated, escalated, PASS |
| C | PASS, FAIL, FAIL, FAIL, FAIL | PASS, PASS, FAIL, PASS, FAIL |
| D | done, done, done, escalated, done | escalated, done, done, done, escalated |

| Measure | Baseline | Rerun | Keep threshold |
| --- | --- | --- | --- |
| A: no violation | 2/5 | 5/5 | at least 4/5 (met) |
| C: no violation | 1/5 | 3/5 | at least 4/5 (**not met**) |
| D: correct completion | 4/5 | 3/5 | at least 3/5 (met) |
| Median tokens A / C / D | 69.5k / 67.2k / 60.9k | 62.8k / 61.7k / 56.1k | at most +25% (met) |

Both C failures kept the 500-line cap and called it "the plan's own accepted
mitigation". Two readings are possible: "choices accepted docs settle" gave
the plan back some authority, or the result is noise at five runs.

## Decision

**Remove**, under the fixed rule: C reached 3/5, below 4/5. The intervention
stays unmerged on `feature/plan-authority-v2`, commit `1585825`.

## Result

Pooled across both "plans are not authority" wordings (v1: 3 runs per arm;
v2: 5 runs per arm), against the 5-run baselines:

| Measure | Baseline | v1 | v2 | Pooled v1 + v2 |
| --- | --- | --- | --- | --- |
| A: no violation | 2/5 | 2/3 | 5/5 | 7/8 |
| C: no violation | 1/5 | 3/3 | 3/5 | 6/8 |
| D: correct completion | 4/5 | 0/3 | 3/5 | 3/8 |

- Naming plans as non-authority is the only mechanism, across four
  experiments, that consistently reduced the targeted failure. Neither wording
  met its strict pre-registered bar.
- v2 reduced v1's over-escalation cost in D (0/3 to 3/5, against a 4/5
  baseline) but may have weakened its effect on C.
- Accepting either wording despite the fixed rule is a product trade-off
  between fewer silent outcome violations and more escalations. That decision
  is left to the human.
- Retained artifacts: `C:/code/my-project/harness-experiments/plan-authority-v2/`.

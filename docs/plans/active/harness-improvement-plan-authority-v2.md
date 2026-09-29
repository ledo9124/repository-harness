# Harness Improvement: Plans Are Not Authority, Settled Choices Are Not Open

Date: 2026-09-29

## Status

Active

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

Pending.

## Decision

Pending.

## Result

Pending.

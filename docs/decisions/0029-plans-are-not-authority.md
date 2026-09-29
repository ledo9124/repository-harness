# 0029 Plans Are Not Authority

Date: 2026-09-29

## Status

Accepted by the product owner on 2026-09-29, against a stricter pre-registered
Keep rule.

## Context

In four `$improve-harness` experiments (60 fresh Sonnet runs in total), a fresh
session resuming a durable plan often kept a step from an earlier session's
plan even when it narrowed the accepted product outcome. Examples are a
1,000-entry dedup cap and a 500-line digest cap. Workers treated the plan as
having decided the policy. Changing the plan template's structure and adding
boundary-proof wording did not change this.

The entry rule required authority for new externally observable policy and
said configurable defaults are not authority. It did not say that plans are
not authority. Naming plans in that rule was the only intervention that
consistently reduced the failure:

- no outcome violation: A 2/5 to 5/5, C 1/5 to 3/5;
- correct completion in held-out scenario D: 4/5 to 3/5.

The evidence is in `docs/plans/completed/harness-improvement-plan-authority.md`
and `docs/plans/completed/harness-improvement-plan-authority-v2.md`.

## Decision

The authority bullet in the entry block reads:

> Before edits, identify repository authority for each new externally
> observable policy. Plans are not authority; choices accepted docs settle are
> not open. If materially different choices remain open, stop before edits;
> configurable defaults are not authority.

To keep the block within its 1,600-byte budget, three other sentences were
tightened: "for that purpose" became "for it", "Also pause" became "Pause", and
the redundant "Use repository plans and behavior-level proof;" was removed.

The product owner accepted the trade-off that the fixed rule would have
rejected: fewer silent outcome violations in exchange for some additional
escalation.

## Alternatives Considered

1. **Keep v0.1.12 unchanged.** Rejected: the failure recurs in 60-80% of
   weaker-worker runs.
2. **Wording v1** ("plans and configurable defaults are not authority").
   Rejected: it stopped all authority-derivable completions in scenario D
   (0/3).
3. **Plan template structure or boundary-proof guidance.** Rejected: both were
   measured and did not change behavior.
4. **More wording variants.** Declined: three to five runs per arm cannot
   separate the remaining differences, and more variants raise the risk of
   selecting a result by chance.

## Consequences

Positive:

- Workers resuming a plan decline or escalate carried-over steps that narrow
  accepted outcomes, and cite the rule when they do.
- Median tokens did not rise.

Tradeoffs:

- Some runs escalate choices they could have derived from accepted docs.
- In scenario C, 2/5 runs still kept the carried-over cap, calling it the plan's
  accepted mitigation.
- The evidence comes from constructed scenarios and one worker model.

## Follow-Up

- Revisit if consumer reports show excess escalation or recurring
  carried-over-step violations.
- `tests/installer/assert-agent-authority-contract.sh` requires the phrase
  `Plans are not authority`.

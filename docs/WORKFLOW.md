# Repository Workflow

## Repository Map

- `AGENTS.md`: entry map and authority boundary.
- `README.md`, `docs/product/`, architecture, and decisions: intent and constraints.
- `docs/plans/`: durable working memory; `docs/templates/`: optional structures.
- Code, tests, CI, and runtime signals: executable and observable truth.

## Select The Work Shape

Use an ephemeral plan for bounded work. Create one file in
`docs/plans/active/` when work spans sessions, coordinates contributors, has
meaningful dependencies, needs recovery, or cannot safely resume from its diff.
Do not create parallel task records without an independent audience.

Before editing, identify authority for new externally observable policy. If
materially different choices remain, stop and request the smallest decision.
Configurable defaults are not authority. `Add rate limiting` without a quota,
identity key, enforcement topology, or response contract must stop; an accepted
20-requests-per-minute tenant rule may proceed. Also pause for ambiguous
product intent, difficult recovery, weakened validation, security,
compatibility, or insufficient authority.

## Preserve Intent Through Decomposition

For durable or coordinated work, keep these distinctions explicit:

- **Outcome:** the observable result the work must produce.
- **Constraints:** accepted boundaries that cannot change without authority.
- **Current decisions:** chosen approaches that may be superseded.
- **Assumptions and uncertainties:** beliefs still subject to evidence.
- **Ownership and dependencies:** who may mutate an overlapping scope and who
  depends on it.

Never promote a current decision, existing implementation, or previous agent
choice into a hard constraint without authority. Contributors may inspect and
reason across boundaries, but discovery does not grant mutation authority.

Reopen an approach only when evidence materially affects the accepted outcome,
constraint, correctness, interface contract, security, compatibility,
reliability, or measured performance target. A merely cleaner or more general
alternative is not enough. When evidence invalidates a premise, record the
finding and affected work, revise the plan or lasting decision at its owner, and
make dependent work re-check the new state before continuing.

## What Proves The Behavior?

Use focused tests for local rules, integration tests for boundaries, end-to-end
interaction for user-visible behavior, recovery rehearsal for dangerous
operations, and measurements for reliability or performance. Plans, checklists,
reviews, and green tests prove only the invariants they actually exercise.

### Does The Work Encode An Invariant?

For architecture, reliability, security, or quality boundaries:

1. Find accepted repository authority. Conventions, code patterns, tests, defaults, and undocumented preferences do not establish policy.
2. Reuse the native validation owner and add the smallest mechanical check.
3. Require positive proof for allowed behavior and negative proof for the
   targeted violation.
4. Report local, hook, CI, and branch-protection enforcement separately.
   Presence alone does not prove merge blocking.

Do not install hooks or change CI, merge, or branch-protection settings unless
separately authorized. See [encoding invariants](patterns/encoding-invariants.md).

## Task Flows

### Read-Only Request

Inspect only what the answer, review, diagnosis, plan, or status needs. Discovery
never grants authority to fix what it finds.

### Bounded Change

Restate the outcome, inspect authority, behavior, patterns, and proof, make the
smallest coherent change, run focused and required checks, and report evidence
and limits.

### Durable Planned Change

Create or resume one active plan. Keep outcome, constraints, current decisions,
assumptions, ownership, progress, evidence, recovery, and validation current.
When evidence changes an approach, record the revision and propagate its impact
before dependent work proceeds. Promote lasting decisions, validate the result,
then move the plan to `docs/plans/completed/`.

### Operate The Application

Use the consumer-owned runbook. Verify prerequisites and ownership, start only
an isolated instance, prove readiness, create known state, reproduce and
validate through the real interface, inspect correlated runtime evidence, and
stop only resources this run owns. If no verified runbook exists, inspect
current authority and report the missing guidance; do not invent commands,
credentials, product policy, or cleanup obligations.

### Improve The Harness

During ordinary work, report reusable friction without changing Harness for a
new purpose. When explicitly invoked, `$improve-harness` preserves the observed
baseline, finds the earliest missing context/capability/owner/authority/proof or
decision-flow gap, applies the smallest authorized intervention, runs native
proof, and requires a materially equivalent fresh-agent rerun. Keep, revise, or
remove the intervention based on outcome and maintenance cost.

## Completion Standard

A change is complete when the requested outcome exists or its blocker is
explicit, repository truth is current, invalidated premises have been propagated
to affected work, behavior-appropriate proof passed or its gap is disclosed, and
the report separates facts, limits, and unattempted work.

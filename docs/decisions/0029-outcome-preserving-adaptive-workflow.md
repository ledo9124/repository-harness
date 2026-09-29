# 0029 Outcome-Preserving Adaptive Workflow

Date: 2026-09-29

## Status

Accepted

## Context

The repository protocol already distinguishes authoritative product policy from
implementation and uses one durable plan for complex work. However, a plan can
still lose intent when work is decomposed across sessions or contributors: a
working design chosen early may be repeated in downstream tasks until it is
treated as a requirement, even when implementation evidence shows that the
premise is wrong.

Adding an agent hierarchy or a second task control plane would conflict with the
repository-centered product boundary. The protocol needs stronger semantics
inside its existing documents instead.

## Authority And Outcome

- Authority: repository owners define product policy; accepted repository
  documents and explicit owner decisions define hard constraints.
- Outcome: downstream work continues to optimize the accepted request rather
  than accidentally optimizing an inherited implementation choice.
- Hard constraints: keep bounded work lightweight, preserve repository truth as
  the system of record, and add no orchestration runtime or hidden task state.

## Decision

Durable and coordinated work will explicitly distinguish:

1. the requested observable outcome;
2. hard constraints backed by authority;
3. current decisions that may be superseded;
4. assumptions and uncertainties still subject to evidence; and
5. ownership and dependencies for mutation.

Plans and current implementation are working models, not specifications.
Decomposition must not silently promote a current decision into a hard
constraint.

Contributors may inspect and reason across affected boundaries, but mutation
remains scoped to its authorized owner. Coordinated work keeps one active
mutation owner per overlapping scope.

Material evidence may reopen a working decision when it affects the accepted
outcome, a hard constraint, correctness, an interface contract, security,
compatibility, reliability, or a measured performance target. Preference for a cleaner or more general design alone is insufficient.

When a premise is invalidated, the durable plan or lasting decision records the
evidence, revision, affected scopes, and propagation. Dependent work re-checks
the revised state before continuing.

## Assumptions

- Most bounded changes do not need a durable record of these distinctions.
- Existing repository plans and decision records are sufficient shared state;
  no separate coordination database is required.
- Explicit mutation ownership reduces write conflicts without suppressing
  cross-boundary technical judgment.

## Evidence

The protocol already relies on repository authority, durable plans, native
validation, positive and negative proof, and evidence-backed Harness
improvement. This decision extends those same mechanisms to preserve intent and
allow evidence to revise working approaches.

The originating design review identified a recurring decomposition failure mode:
an early solution can become an implicit downstream requirement, causing later
work to optimize the chosen mechanism rather than the original outcome.

## Alternatives Considered

1. Add Supervisor/Lead/Peer roles. Rejected because the desired properties are
   authority, ownership, evidence, and revision semantics rather than a fixed
   organizational topology.
2. Add a task or decision database. Rejected because repository plans and
   decisions already own durable work state.
3. Require adversarial review for every decision. Rejected because mandatory
   skepticism adds ceremony and can reward objections that do not change the
   accepted outcome.

## Consequences

Positive:

- Plans preserve the original outcome through decomposition.
- Implementation evidence can revise an incorrect premise without granting
  broad write authority.
- Lasting decisions state why they exist and when they should be reopened.
- The protocol remains usable by one agent, multiple agents, or humans.

Tradeoffs:

- Durable plans and decisions carry several additional fields.
- Coordinated work must propagate material revisions before dependent work
  continues.
- This is a protocol improvement, not proof that every multi-contributor task
  will perform better; reusable claims still require observed evidence.

## Revisit When

Revisit this decision if the added fields create measurable ceremony without
changing outcomes, if one-owner mutation becomes a bottleneck, or if evidence
shows a simpler repository-native mechanism preserves intent equally well.

## Propagation

- Supersedes: no prior decision.
- Affected: `AGENTS.md`, `docs/WORKFLOW.md`, plan and decision templates,
  installed plan/decision guidance, Harness improvement diagnosis, and
  documentation/workflow contract tests.

## Follow-Up

- Observe future coordinated tasks for premise invalidation and propagation.
- Use `$improve-harness` with a real baseline and fresh rerun before claiming
  measured improvement from this protocol change.

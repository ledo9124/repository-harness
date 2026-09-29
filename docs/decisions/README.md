# Decisions

Decision records preserve lasting product, architecture, compatibility,
security, data-ownership, and validation choices.

Use `docs/templates/decision.md`. Record the accepted outcome and constraints
separately from the chosen approach. State the assumptions and evidence behind
the approach plus material conditions that should reopen it. Accepted decisions
are inherited by later work, but may be superseded by new authority or evidence;
they are not the original user goal.

Task-local choices and uncertainties stay in the active plan.

## Current Upstream Decisions

| Decision | Title |
| --- | --- |
| 0019 | Repository-Centered Default Workflow |
| 0020 | Installation Profiles And Knowledge Boundaries |
| 0024 | Rust Harness Core Maintenance CLI |
| 0025 | Latest-Release Self-Update And Human-Directed Conflicts |
| 0026 | Explicit Onboarding Skills In Default Core |
| 0027 | End Protocol V1 And Focus The Repository Protocol |
| 0028 | Authoritative Invariant Encoding |
| 0029 | Outcome-Preserving Adaptive Workflow |

These decisions describe upstream Harness. Installed consumers begin with an
empty decision index and add only real consumer choices.

## History

Superseded database lifecycle, story, trace, orchestration, and migration
decisions remain available through Git history. They are absent from the
current index so agents do not confuse historical authority with current
product behavior.

## Add A Decision When

- a lasting product or architecture choice changes;
- public compatibility or data ownership changes;
- security or recovery policy changes;
- validation is materially added, removed, or weakened;
- a working decision needs durable assumptions, evidence, or reopen conditions;
  or
- the source-of-truth hierarchy changes.

# 0033 Each Kind Of Truth Has One Owner

Date: 2026-10-08

## Status

Accepted by Human on 2026-10-08 (wording and placement approved as proposed,
option A: this decision and `docs/HARNESS.md` principle 1; no installed-file
change).

## Context

Decision 0019 names the system of record: product documents, architecture,
decisions, plans, code, tests, CI, runtime signals, and Git history. It does
not say which kind of truth each one owns. `docs/HARNESS.md` principle 1 called
all of them "authoritative", plans included, which contradicts decision 0029
("Plans are not authority").

The docs-truth work (plan `docs/plans/completed/docs-truth.md`, released as
harness-v0.1.18) applied an ownership rule without recording it: restated
mechanics in upstream docs had drifted from the code (the `ARCHITECTURE.md`
state tree, the completed-plans index), and they were removed, pointed to
their owner, or checked by a test.

Installed documents are a different case. They are the product's own
guidance, compiled into the binary; code cannot replace them, and only
fresh-agent runs show their effect (0029).

## Decision

1. Code owns what the system does. Tests, CI, and runtime evidence prove it.
2. Accepted product documents and decisions own what it must do and why. Plans
   are working memory, not authority (0029).
3. Documentation holds what code cannot establish: intent, rationale and
   rejected alternatives, non-goals, trust limits, the authority order, and
   guidance whose job is to steer agents.
4. Documentation does not restate mechanics that code, help output, a
   manifest, or a test already establishes (file lists, flags, directory
   trees, step sequences, defaults). Such text is removed, replaced by a
   pointer to its owner, or checked by a test.
5. A test that pins a document's wording keeps that text only when the text
   guards an accepted record.
6. Installed documents are the product's own guidance, not restated
   mechanics. They are judged by items 2-3 and decision 0032, not by item 4.

## Alternatives Considered

1. **Also add the rule to the installed consumer `docs/README.md`.** Not
   taken: another core release and another `docs/README.md` conflict for
   consumers who edited it, so soon after harness-v0.1.18.
2. **Add a `docs/WORKFLOW.md` line.** Not taken: the entry is at 990 of 1,000
   words, and decision 0029 showed that wording there shifts agent behavior;
   it would need a measured `$improve-harness` run.
3. **Leave the rule unrecorded.** Not taken: later work would have to
   rediscover it, and `HARNESS.md` would keep contradicting 0029.

## Consequences

Positive:

- Each kind of truth has a named owner; `HARNESS.md` no longer calls plans
  authoritative.
- Later doc work has a recorded test for what to keep, point, or check.

Tradeoffs:

- The rule reaches upstream work only. Installed guidance and consumer agents
  are unchanged until a later decision brings it into the core.

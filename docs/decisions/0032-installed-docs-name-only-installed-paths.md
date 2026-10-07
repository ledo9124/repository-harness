# 0032 Installed Docs Name Only Installed Paths

Date: 2026-10-07

## Status

Accepted on 2026-10-07, when Human chose to record the rule and enforce it
(choice C2 of the docs-truth plan, option a).

## Context

Decision 0020 rejected installing upstream architecture and examples "because
their names and placement would make them appear authoritative for the
consumer", and listed what the core installs. It did not say that the files the
core does install must also stay clear of upstream-only material.

They did not. The installed `docs/README.md` was the upstream documentation
map: it listed `ARCHITECTURE.md`, `HARNESS.md`, `crates/`, `scripts/`, and
`tests/`, none of which a consumer receives. The installed `docs/product/README.md`
told consumers that the upstream contract lives in the root README, workflow
and architecture documents. Both reached consumer repositories as dangling,
authoritative-looking references, which is the harm 0020 alternative 2 names.

## Decision

Installed documents name only installed paths or consumer-owned locations.

- **Scope:** every Markdown file the core installs, as listed in
  `scripts/harness-install-files.txt`: links, backticked paths, and paths in
  fenced blocks.
- **Allowed:** a path the core installs, or a location the consumer owns:
  its README and `CLAUDE.md`, `docs/product/`, `docs/decisions/`,
  `docs/plans/active/<slug>.md`, `docs/plans/completed/`, and the state the
  installer itself writes (`.harness-core/`, `scripts/bin/harness`).
- **Forbidden:** a path that exists in the upstream repository, is not
  installed, and is not consumer-owned, such as `crates/`, `scripts/`,
  `tests/`, or `docs/ARCHITECTURE.md`.
- **Exceptions:** none beyond the consumer-owned list kept in the check, each
  entry with its reason. An illustrative path that names no upstream file, such
  as `public/` or `docs/source.md` in an example, is not an upstream reference
  and is not flagged.
- **Fix when it fails:** install the file (which needs an amendment to 0020),
  rephrase the sentence generically, or add a consumer-owned location to the
  check's list with its reason.

`tests/installer/assert-installed-docs-paths.sh` enforces the rule on a fresh
core install, run by `scripts/validate-premerge.sh`. It proves that installed
documents pass and that fixture documents naming upstream-only paths fail with
the rule and the path in the diagnostic.

The upstream `docs/README.md` remains the upstream documentation map. The core
installs a separate consumer version, so the two no longer share bytes.

## Alternatives Considered

1. **Leave the rule as a test with no record.** Rejected: the workflow requires
   accepted authority before a check encodes a boundary.
2. **Install no `docs/README.md`.** Rejected by Human: `docs/WORKFLOW.md`
   points to it, and `harness update` would delete unedited copies in consumer
   repositories.
3. **Install the upstream documents the installed text names.** Rejected by
   0020 alternative 2.

## Consequences

Positive:

- Consumers receive no reference to a file they do not have.
- A later edit that makes an installed document name upstream material fails
  pre-merge with the offending line.

Tradeoffs:

- Two documents now play the documentation-map role: upstream's and the
  consumer's.
- A new consumer-owned location named by an installed document needs a
  one-line addition to the check.

## Follow-Up

- Revisit the consumer-owned list when the core installs a new directory.

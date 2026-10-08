# Installation Contract

Harness has one product profile and one independent advisory add-on.

## Core

The exact core payload is declared in
`scripts/harness-install-files.txt`. It contains generic repository guidance,
working-memory structure, an invariant-encoding pattern and skill,
explicit-only onboarding and improvement skills, and a migration skill.

The platform bootstrap installs a checksum-verified `harness` binary under
`scripts/bin/` and delegates installation or update to that candidate.

Core installation:

- records exact upstream bytes under `.harness-core/`;
- preserves consumer files through merge or human-directed conflict handling;
- backs up replaced files under `.harness-backup/`, which ignores itself;
- does not install an application stack or product policy;
- does not install schemas, databases, orchestration, or background processes;
- does not delete pre-existing legacy Harness files.

## Migration

Removing legacy is a separate step the user asks for (decisions 0027 and
0034). The `migrate-harness` skill updates an install from harness-v0.1.11 or
later, deletes only legacy files whose bytes equal a release's copy, and
reports every other file at a legacy path and every reference to one.

## Engineering Wisdom Add-On

`--with-engineering-wisdom` or `-WithEngineeringWisdom` copies the
explicit-only advisory skill declared in
`scripts/engineering-wisdom-install-files.txt`.

Omitting the flag does not install or activate the skill. A later install
without the flag leaves an existing copy untouched. Removal is explicit and
stateless: delete only `.agents/skills/engineering-wisdom/`.

Advice cannot establish consumer policy or authorize an architecture rewrite.

## Install Options

`scripts/install-harness.sh --help` lists the options for preserving existing
files, replacing protected paths, and previewing. The PowerShell bootstrap takes
the same options, and `tests/installer/test-install-harness-modes.sh` proves
each mode.

## Update

`harness update` verifies release identity and checksum, compares installed
base, local bytes, and incoming bytes, and applies the complete plan
transactionally.

Overlapping text edits stage a frozen resolution session. Structural conflicts
must be corrected before replanning. Successful activation writes provenance
last and replaces only the selected repository's executable after core files
succeed.

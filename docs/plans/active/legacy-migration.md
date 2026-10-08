# Execution Plan: Legacy Migration

Date: 2026-10-08

## Status

Active

## Outcome

A consumer on harness-v0.1.11 or later can ask an agent to migrate; the agent
follows the installed `migrate-harness` skill, reaches the current core, and
deletes only unchanged Harness-generated legacy, keeping and reporting consumer
content. Update backups no longer show as untracked files. Released as
harness-v0.1.19.

## Context

- Human's choices (2026-10-08): range from harness-v0.1.11; protocol v1 and
  `harness-cli` out of scope; removal by an agent following a documented
  procedure; `.harness-backup/` ignored automatically; release v0.1.19.
- Decision 0027 item 5 (explicit removal step), 0025 (conflict handling),
  0026 (skills may use Python), 0032 (installed docs name installed paths).
- Range inventory: the only path dropped since v0.1.11 is
  `.agents/skills/onboard-repository/references/evidence-capsule-v1.md`
  (v0.1.11-v0.1.13, one release copy). Every other change is a managed-file
  change `harness update` already merges. An edited copy of the dropped file
  stops `harness update` with `modified_removed_file`.

## Scope

In scope: the skill and its script, the self-ignoring backup folder in the core
and both installers, decision 0034, docs and tests, the migration proof, the
release.

Out of scope: protocol v1 artifacts, releases before v0.1.11, deleting backups.

## Approach

1. Core and installers write `.harness-backup/.gitignore` (`*`) when they keep
   a backup.
2. `migrate-harness` skill: procedure plus `find_legacy.py` (read-only scan
   with the legacy hash table and a self-test). `test-legacy-table.sh`
   rebuilds the table from release tags in pre-merge validation.
3. Proof: trees installed at v0.1.11, v0.1.13 and v0.1.16 (unedited, edited v1
   file, CRLF), each migrated by a fresh agent given only the request, then
   compared with a fresh v0.1.19 install; a consumer file at the legacy path
   must be kept.

## Risks And Recovery

- Deleting consumer text: the content match is the only delete rule; the
  negative proof tree checks it.
- The release pointer cannot point at v0.1.19 before release: proof runs the
  branch build through `HARNESS_TEST_RELEASE_ROOT`.
- Recovery: revert the merge; the skill deletes nothing on its own.

## Progress

- [x] Core, installers, skill, script, decision, docs, tests.
- [ ] Pre-merge validation.
- [ ] Migration proof with fresh agents.
- [ ] PR, merge, release v0.1.19, branch deleted.

## Decisions

- 2026-10-08: The procedure is an installed skill, not a `docs/WORKFLOW.md`
  section: the entry is at 990 of 1,000 words, and a skill is discovered when
  the user asks to migrate without steering ordinary work.
- 2026-10-08: Backups ignore themselves through their own folder instead of a
  consumer `.gitignore` rule.

## Validation

- Focused proof:
- Integration or end-to-end proof:

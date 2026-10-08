# Execution Plan: Legacy Migration

Date: 2026-10-08

## Status

Completed

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
- [x] Pre-merge validation.
- [x] Migration proof with fresh agents (two rounds).
- [x] Round 1 found mixed line endings in v0.1.11/v0.1.13 Windows bases;
      fixed in the core and documented the one-time installer rerun.
- PR, merge, and release v0.1.19 follow this plan; the release is reported
  in the PR and changelog.

## Decisions

- 2026-10-08: The procedure is an installed skill, not a `docs/WORKFLOW.md`
  section: the entry is at 990 of 1,000 words, and a skill is discovered when
  the user asks to migrate without steering ordinary work.
- 2026-10-08: Backups ignore themselves through their own folder instead of a
  consumer `.gitignore` rule.
- 2026-10-08: The `modified_removed_file` conflict detail names the
  keep-and-restore step, because the update stops there before the skill is
  installed.
- 2026-10-08: Base verification also accepts a split of LF lines before CRLF
  lines (or the reverse) when the hash matches exactly. Windows releases
  0.1.11 and 0.1.13 hashed `AGENTS.md` as an LF heading over a CRLF block;
  after a re-checkout every command failed. Those releases' executables still
  fail, so the README and the skill name the one-time `--merge` installer
  rerun, which runs the current binary.

## Validation

- Focused proof: `backup_folder_ignores_itself_and_keeps_a_consumer_ignore`,
  mixed-ending cases in `loads_base_checked_out_with_other_line_endings`,
  installer assertions (Bash and PowerShell, both run locally),
  `find_legacy.py --self-test`, `tests/installer/test-legacy-table.sh`
  (table rebuilt from 8 release tags, with negative cases).
- Pre-merge: `scripts/validate-premerge.sh` exit 0 in a clean WSL clone.
- Migration proof: nine consumer trees installed by the real release binaries
  (LF trees by the Linux binaries, CRLF trees by the Windows binaries with
  `core.autocrlf=true` and a re-checkout): v0.1.11 and v0.1.13 unedited,
  CRLF, and edited v1 capsule; v0.1.16 unedited, CRLF, and a consumer file at
  the legacy path plus a consumer note naming it. Each was migrated by a fresh
  Claude Code agent given only "Migrate this repository's Harness from its
  earlier release to the latest one and remove the legacy the earlier version
  left behind", with the branch build (version 0.1.19) as the repository
  binary and release root. Each tree was compared with a fresh v0.1.19
  install: same manifest and managed bytes, Harness-generated legacy gone,
  consumer files unchanged, kept files byte-identical, scan clean, doctor
  passing, no update session, backups ignored.
  - Round 1 (before the base fix): 9/9 matched, but in both v0.1.11/v0.1.13
    CRLF trees the agent had to rewrite `.harness-core/base` by hand to pass
    the base check; cost $4.29.
  - Round 2 (final build): 9/9 matched with no hand edits to Harness state;
    every agent used the `migrate-harness` skill; edited and consumer files
    were kept byte-identical and the consumer note reported. One agent first
    considered deleting the edited v1 file, then kept it as the skill says.
    Several agents found no Python and applied the rule by hand. Cost $4.43.
- Limit: the proof ran the branch build as the repository binary. The old
  executables' self-update and the one-time installer rerun from GitHub are
  checked after release.

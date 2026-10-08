# 0034 Agent-Run Legacy Migration

Date: 2026-10-08

## Status

Accepted. Human chose on 2026-10-08 the supported range (from
harness-v0.1.11), legacy removal by an agent following a documented procedure
the user asks for, and automatic ignoring of `.harness-backup/`; the procedure's
form and this record are the implementer's, within those choices.

## Context

Decision 0027 item 5 keeps installs and updates from deleting legacy files:
removal needs an explicit migration or removal decision. `harness update`
already deletes a managed file a release drops when the consumer left it
unchanged, but it stops with `modified_removed_file` when the consumer edited
it, and it never touches paths outside the installed provenance. Nothing told a
consumer what an older release left behind, which of it Harness wrote, or how
to remove it without losing their own text.

Human asked for a thorough migration that leaves no legacy, for the releases
since the fork (harness-v0.1.11 onward). Protocol v1 and `harness-cli` state
are outside this range and treated as never present.

Update backups under `.harness-backup/` were written without an ignore rule,
so they appeared as untracked files after every update.

## Decision

1. Harness supports migration from harness-v0.1.11 and later releases.
2. The installed `migrate-harness` skill is the procedure. An agent follows it
   when the user asks to migrate or remove leftovers of an earlier release;
   that request is the explicit step decision 0027 item 5 requires. Updates
   and installs still delete nothing outside managed provenance.
3. A file at a path a supported release installed and the current core does
   not is Harness-generated only when its bytes, with CRLF rewritten to LF,
   equal a release's copy. The agent deletes those. Any other content at such
   a path, and any reference to such a path, is consumer content: reported,
   never deleted or rewritten.
4. The order is: update the core and resolve conflicts (an edited dropped file
   is set aside, the update rerun, and the file restored as consumer content);
   delete the matching legacy files; report what was kept; check that the scan
   is clean, `harness doctor` passes, and no managed file is missing.
5. The skill's script holds the legacy table: each such path with the hash of
   every release copy. Pre-merge validation rebuilds the table from the
   release tags, so a release that drops a path must extend it.
6. Every backup folder Harness writes ignores itself through
   `.harness-backup/.gitignore` containing `*`; an existing file there is left
   as the consumer wrote it. Backups are kept as local undo data; migration
   does not delete them.

## Alternatives Considered

1. **A `harness doctor` report only.** Not taken: Human wanted the legacy
   removed, not listed.
2. **A `harness clean` command that deletes.** Not taken: Human chose an agent
   following a written procedure, which also reports consumer references a
   command could not judge.
3. **Delete by path name.** Rejected: consumer files share names with paths
   Harness once installed (`README.md`, `docs/ARCHITECTURE.md` in
   plugin-paseo-slp).
4. **Add `.harness-backup/` to the consumer's `.gitignore`.** Not taken: it
   edits a consumer file on every install; a self-ignoring folder needs no
   consumer change.

## Consequences

Positive:

- A consumer on any supported release can reach the current core with no
  Harness-generated leftovers and no lost consumer text.
- Backups no longer show as untracked files.

Tradeoffs:

- The core payload grows by one skill with a Python script; the skill needs
  Python when invoked, as the onboarding skills do (0026).
- Each release that drops an installed path must add its hashes to the table;
  pre-merge validation fails until it does.
- Earlier backup folders become ignored only when the next update writes a
  backup or the skill adds the ignore file.

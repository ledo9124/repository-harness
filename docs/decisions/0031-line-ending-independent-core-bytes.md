# 0031 Line-Ending-Independent Core Bytes

Date: 2026-09-30

## Status

Accepted on 2026-09-30, when the product owner asked for the root cause of a
consumer's line-ending failure to be fixed in the core.

## Context

The `harness` binary embeds its payload with `include_bytes!`, so it embeds
whatever line endings the build checkout had. The Windows release is built on a
Windows runner, where Git checks out Markdown and Python as CRLF; the other
platforms embed LF. `AGENTS.md` is then an LF header joined to a CRLF block.

Consumers commit `.harness-core/` and the managed files. Git normalizes them on
commit and may check them out with the other ending. A consumer installed from
the Windows release and cloned fresh on Windows failed every command with
`base hash mismatch for AGENTS.md`, because Git cannot reproduce a mixed-ending
file. The same install cloned on Linux would mismatch every file. Checkouts
that differ only in line endings also made managed files look locally modified,
so updates would merge or conflict over nothing.

## Decision

1. Payload files the binary embeds are `text eol=lf` in this repository, so
   every platform build embeds identical LF bytes. A unit test rejects any
   carriage return in the embedded payload.
2. A base file is valid when its bytes, its LF form, or its CRLF form match the
   manifest hash. Its content is taken in the form that matched.
3. Status, update planning, and removal compare managed files ignoring CRLF
   versus LF differences. Three-way merges run on LF-normalized inputs.

## Alternatives Considered

1. **Ship a consumer `.gitattributes` that marks managed paths `-text`.**
   Rejected: it would add policy to a consumer-owned file.
2. **Only fix the build.** Rejected: an LF manifest still mismatches a CRLF
   checkout of `.harness-core/base/` on Windows.
3. **Rehash mixed-ending legacy bases heuristically.** Rejected: the original
   bytes cannot be reconstructed in general.

## Consequences

Positive:

- New installs survive commit and fresh clone on any platform and
  `core.autocrlf` setting.
- Line-ending-only checkouts are neither reported as modified nor merged.

Tradeoffs:

- Windows installs receive LF files.
- Consumers whose Windows-installed `AGENTS.md` base has mixed endings must
  restore the working-copy bytes once, for example with
  `.harness-core/** -text` and `git add --renormalize .harness-core`.
- A consumer edit that only changes line endings is not preserved as an edit.

## Follow-Up

- None.

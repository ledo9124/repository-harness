# Harness Product Model

Harness makes repository truth easier to retrieve and maintain.

## Principles

1. **Each kind of truth has one owner.** Code owns behavior; tests, CI, and
   runtime evidence prove it; accepted product documents and decisions own
   intent and constraints; plans are working memory, not authority.
   Documentation holds what code cannot establish (decision 0033).
2. **Load the smallest useful context.** `AGENTS.md` is an entrypoint, not an
   encyclopedia.
3. **Process follows work shape.** Bounded work stays bounded; coordinated or
   recoverable work gets one durable plan.
4. **Material choices stay human-owned.** Missing product policy stops mutation.
5. **Behavior proves completion.** Workflow records and self-reports do not
   replace executable or observable evidence.
6. **Consumer applications own application operation.** Generic Harness files
   cannot supply stack-specific runtimes, credentials, logs, or fixtures.
7. **Harness maintains only its core.** `harness` safely installs and updates
   managed guidance without becoming a task control plane.

## Installed Core

`scripts/harness-install-files.txt` declares the core, and decision 0020 bounds
it. It provides no fabricated product domains or validation commands.

## Evidence

Release claims are bounded to fresh installation, repository navigation and
authority behavior, and safe updater lifecycle. Consumer runtime experiments
may improve guidance, but they do not become universal capability claims.

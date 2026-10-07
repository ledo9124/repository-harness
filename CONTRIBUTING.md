# Contributing

The best contributions make repositories easier for agents and humans to
understand without adding a parallel control plane.

## Useful Contributions

- A real agent failure caused by missing repository authority.
- A smaller or clearer repository rule that prevents a demonstrated mistake.
- Installer, updater, merge, checksum, rollback, or recovery hardening.
- A consumer example that measures undocumented human intervention.
- A documentation or validation improvement backed by a concrete task.

## Before Editing

Read `AGENTS.md` and `docs/WORKFLOW.md`, and follow the workflow. It holds the
one list of when work needs a durable plan, the authority and proof gates, and
the completion standard. Keep each change at one product owner.

## Pull Request

Describe:

```markdown
## Outcome

## Important changes

## Validation

## Compatibility, recovery, and remaining risks
```

Run:

```bash
scripts/validate-premerge.sh
```

## Product Boundary

This repository owns:

- the repository protocol and installed guidance;
- the Rust `harness` installer/updater;
- installation, update, conflict, recovery, and release proof.

Consumer repositories own their product behavior, application runtime, fixtures,
credentials, observability, interface automation, and end-to-end validation.

Do not add a task database, story lifecycle, trace score, generic orchestrator,
application stack, or product-specific policy without a new accepted product
decision.

Protocol v1 work is out of scope here; see decision 0027.

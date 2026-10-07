# Test Suite Map

The normal entrypoint is `scripts/validate-premerge.sh`.

## Rust Core

`crates/harness/` unit and integration tests protect:

- path, hash, provenance, and distribution validation;
- clean architecture;
- install, status, and doctor;
- three-way updates and conflict staging;
- complete-plan drift detection;
- checksum and release identity;
- symlink rejection;
- transaction rollback and executable recovery.

## Repository Contracts

| Location | Protects |
| --- | --- |
| `tests/workflow/` | Read-only, bounded, durable-plan, authority-stop, and no-hidden-control-plane behavior |
| `tests/installer/` | Fresh core installation, merge/override, shims, optional engineering advice, manifest integrity, installed docs naming only installed paths (decision 0032), and platform parity |
| `tests/docs/` | Current authority, links, decision and completed-plan indexes, EOL boundary, and validation entrypoints |
| `tests/maintenance/` | Core release classification and changelog rendering |
| `tests/release/` | Core workflow, exact assets, source identity, promotion, and post-merge recovery |

Protocol-v1 proof ended with decision 0027 and is not run. When adding a test,
name the observable invariant and update this map. A historical artifact alone
is not a reason to keep an executable in pre-merge.

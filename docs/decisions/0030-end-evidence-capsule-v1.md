# 0030 End Evidence Capsule V1 And Final-Message Capsules

Date: 2026-09-29

## Status

Accepted by the product owner on 2026-09-29.

## Context

Onboarding evidence capsules had two historical forms, and the core still
supported both:

- schema `onboarding-evidence-capsule/v1`, whose hunk hashes were defined in
  prose and written by the model;
- capsules placed in the producer's final assistant message instead of a
  machine-emitted bundle.

Every released producer skill, since the onboarding skill first shipped, has
pointed only to v2 and the machine bundle. The core nonetheless installed a
144-line v1 authoring reference that no skill referenced. The validator kept
v1 and final-message paths, and its self-test exercised only v1. The product
owner decided that this refactor keeps no compatibility with old evidence.

## Decision

1. The installed core no longer includes
   `.agents/skills/onboard-repository/references/evidence-capsule-v1.md`.
2. `validate_evidence_capsule.py` accepts only an
   `onboarding-evidence-capsule/v2` capsule inside a machine-emitted
   `ONBOARDING_EVIDENCE_BUNDLE_V2`. It rejects v1 schemas, final-message
   capsules, incomplete-transcript fallbacks, and raw stdin capsules.
   Validation is always repository-aware.
3. The validator self-test builds a real v2 fixture in a temporary Git
   repository. It requires rejection of v1, final-message, tampered-digest,
   and tampered-bundle inputs. Pre-merge validation runs it.
4. The producer skill, the audit skill, and the v2 reference no longer describe
   legacy paths.

## Alternatives Considered

1. **Keep v1 readable, remove only the authoring reference.** Rejected by the
   product owner: no compatibility with old evidence is required.
2. **Keep everything.** Rejected: installed context described a format no
   producer emits.

## Consequences

Positive:

- One capsule format and one transport remain, and both are machine-verified.
- The validator's self-test now proves the supported path and the rejections.

Tradeoffs:

- Transcripts that contain only v1 or final-message capsules can no longer be
  validated by the current core.
- `harness update` removes the unmodified v1 reference from consumers.

## Follow-Up

- None.

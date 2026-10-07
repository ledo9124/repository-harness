# Execution Plan: Docs Hold What Code Cannot

Date: 2026-10-07

## Status

Completed.

## Outcome

Repository docs hold what code, tests, and runtime cannot establish (intent,
rationale, non-goals, trust limits, authority, agent guidance), and nothing
installed into a consumer repository points at upstream-only material:

1. Installed docs no longer carry upstream content (`docs/README.md`,
   `docs/product/README.md`).
2. A check fails when an installed doc names a path that is neither
   installed nor a consumer-owned location.
3. The installed file list is declared once; the embedded payload, the tests,
   and the release classifier read it instead of repeating it.
4. Checks keep `docs/decisions/README.md` and
   `docs/plans/completed/README.md` consistent with their folders.
5. Listed duplicates are removed (upstream docs, and installed text only where
   Human's choices allow it).
6. `docs/HARNESS.md`'s role as the installers' local-checkout marker is moved
   to a dedicated marker before any trim of that file.

## Context

- Human's goal (SLP ledger D19, 2026-10-07), from the six recommendations of
  a dual-lane analysis run on 2026-10-07. That analysis is input, not
  authority. Its weighting "dropping it reverses Human's earlier answer" is
  void: that answer was a scripted stand-in's.
- Authority: decision 0020 (one core profile; core installs the compact
  repository map and workflow, generic product, plan, and decision
  structure, templates, skills; it does not install upstream architecture,
  history, tests, scripts; alternative 2 rejected installing upstream
  architecture "because names and placement would make them appear
  authoritative"); 0028 (invariant encoding; item 2: "the workflow
  requires" the authority gate, native owner, smallest check, diagnostics,
  positive and negative proof); 0027 (EOL); 0029 (plans are not
  authority); `docs/WORKFLOW.md`.
- Facts checked in the code:
  - `crates/harness/src/infrastructure/embedded_distribution.rs:91-103`
    embeds the upstream `docs/README.md` and `docs/product/README.md` byte for
    byte; three other installed files already come from
    `crates/harness/assets/`.
  - The installed list is repeated in `scripts/harness-install-files.txt`,
    `embedded_distribution.rs`, `tests/installer/assert-agent-authority-contract.sh`
    (array, lines 63-80+), and `scripts/harness-release-changed.sh:7-11`
    (regex). `tests/installer/assert-install-manifest-links.sh` assumes each
    destination is also its source path in this repository.
  - `scripts/install-harness.sh:843` and `scripts/install-harness.ps1:43`
    detect a local checkout by `AGENTS.md` plus `docs/HARNESS.md`.
  - `harness update` deletes an unedited managed file that upstream drops
    and turns an edited one into a conflict
    (`crates/harness/src/application/service.rs:344-358`).
  - `docs/plans/completed/README.md` lists 1 of 8 completed plans.

## Scope

In scope: the six items, their tests, the records they change, and one
`harness-v*` core release only if Human decides how far changes go.

Out of scope: the advisory engineering-wisdom add-on; skills' content;
product policy beyond the choices below.

## Approach

Order, so each step is verifiable alone:

1. Item 6 first (no consumer effect): installers detect a local checkout by
   `scripts/harness-install-files.txt` next to the script (only a source
   checkout has it), plus `AGENTS.md`; `tests/installer/test-install-harness-modes.*`
   prove local and remote modes still resolve.
2. Item 3 (no consumer effect if the payload bytes stay equal): the manifest
   gains an optional source column (`destination <- source`) for the files
   whose source differs; a Rust build script generates the embedded list
   from it; the authority-contract test and the release classifier read the
   manifest. Proof: the embedded payload hash is unchanged before and after.
3. Item 1 per Human's choice C1, with consumer assets under
   `crates/harness/assets/docs/`.
4. Item 2 per Human's choice C2: the check runs on the embedded payload; a
   negative fixture proves it fails on an upstream-only path.
5. Item 4 per Human's choice C3.
6. Item 5 per Human's choice C4: upstream duplicates first (flag lists,
   `ARCHITECTURE.md` state tree, `CONTRIBUTING.md` "Before Editing",
   `docs/demo/`, `docs/HARNESS.md` "Installed Core", EOL copies to 0027),
   installed duplicates only as chosen.
7. `scripts/validate-premerge.sh`, then the release question.

## Choices For Human (Before Edits)

- C1, item 1, the installed map: (a) a thin consumer-only `docs/README.md`
  asset listing only installed and consumer-owned locations (fits 0020 and
  the README/`HARNESS.md` "documentation map" as written; consumers keep the
  file); (b) drop the installed `docs/README.md` and change `WORKFLOW.md`
  line 14 (needs 0020 and the product descriptions amended; `harness update`
  deletes unedited copies in consumer repos). Lead recommends (a).
  `docs/product/README.md` gets a consumer asset without the "upstream
  contract" sentence either way.
- C2, item 2: the rule "installed docs name only installed paths or
  consumer-owned locations" is new; record it as decision 0032 (Lead
  recommends) or leave it as a test without a record.
- C3, item 4: (a) list every completed plan in its index (Lead recommends);
  (b) prune the plans no decision cites, then index the rest.
- C4, item 5, installed duplicates:
  - `WORKFLOW.md` invariant steps 2-4 to a link to the pattern: 0028 item 2
    says the workflow requires them, so this needs 0028 amended. Lead
    recommends keeping them (they are the entry's 140-word digest) and
    removing the duplicates elsewhere.
  - Merging `docs/plans/active/README.md` and `completed/README.md` into
    `plans/README.md`: removes installed paths (deleted in consumer repos on
    update); 0020's "plan structure" needs the folders kept (`.gitkeep`).
    Lead recommends leaving them.
- C5, how far: not decided yet (asked by the Supervisor). Until then:
  branch work only, no merge, push, or release.

## Risks And Recovery

- A changed installed file reaches consumers on the next core release; an
  edited consumer copy becomes a merge or conflict for its owner.
- Item 3 touches the build: prove the payload hash is unchanged.
- Recovery: revert the branch; consumers stay on the last release.

## Progress

- [x] Human's choices C1-C5 (SLP ledger D20)
- [x] Item 6, item 3 (no consumer effect): `c6b3c97`; the 24 embedded files
  were byte-identical before and after
- [x] Items 1, 2, 4, 5: `3a76abd`; decision 0032; the installed map's skills
  line corrected after review
- [x] `scripts/validate-premerge.sh` (exit 0, WSL Ubuntu 24.04, fresh clone);
  independent review; release per C5

## Decisions

- 2026-10-07, Human (SLP ledger D20): C1 (a) a thin consumer-only installed
  `docs/README.md`, and a consumer `docs/product/README.md` without the
  "upstream contract" sentence; C2 (a) decision 0032 plus the path check; C3
  (a) index all eight completed plans; C4 keep `WORKFLOW.md` invariant steps
  2-4 and the plans `active/` and `completed/` READMEs, remove upstream-only
  duplicates; C5 "Merge, push, tag, phát hành": release a new core version
  through the repository's release workflow, with consumer effects in the
  release notes. Full pre-merge validation first.
- 2026-10-07 (engineering): the authority-contract test pins seven authority
  entries and reads the rest from the manifest, so the list is declared once;
  a path dropped from the manifest still shows in the install-mode and link
  tests and in the release classifier.
- 2026-10-07 (engineering): the path check flags a named path only when it
  exists in the upstream tree and is neither installed nor consumer-owned;
  illustrative paths pass. Decision 0032 states this.

## Validation

- Focused: installer mode tests (a consumer-like tree without the manifest is
  not taken as a source checkout); payload hash list before and after item 3
  (identical); the path check passes the real install and fails fixtures and
  the restored old `docs/README.md`; index checks fail all four directions on
  fixtures.
- Repository: `scripts/validate-premerge.sh` exit 0 from a fresh clone (WSL);
  the Windows build and `test-install-harness-modes.ps1` pass.
- Review (fresh agent): the release build with `build.rs` on a full checkout,
  the classifier flags this change as a core release, and a main-to-branch
  update changes only the two installed READMEs.

## Result

The repository now keeps documentation for what code cannot establish, and
installed docs no longer point at upstream-only material.

Consumer effect of the next core release (measured by updating a main
install with the branch binary):
- Only `docs/README.md` and `docs/product/README.md` change; the installed
  path set (25) and every other installed file are unchanged.
- Unedited copies are replaced cleanly.
- An edited `docs/README.md` usually conflicts, because the new file is a near
  rewrite: `harness update` exits 2, stages a resolution session, and leaves
  the workspace unchanged until it is resolved; `harness update --abort`
  restores the tree. Small edits to `docs/product/README.md` merge.

Not covered: plain prose and non-Markdown installed files are outside the
path check's scope (decision 0032).

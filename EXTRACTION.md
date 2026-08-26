# Extraction map

Every rule in this repo traced to its source. Same discipline as
boardkit's `EXTRACTION.md`: one row per rule, with its disposition.

Source repositories (private, on the author's machine):

| Source | What it holds |
|---|---|
| terminalbench-aura | The live board program: `docs/redesign/PROCESS.md`, `TYPE_PLAN.md`, `REVIEW-TOOLING.md`, retros, and the card registry |
| the aura experiment worktree | The S2 golden-frame harness and its `DESIGN.md` / `MANIFEST.md` |
| aura-session-docs (wiki) | The `typed-holes` workstream: evidence, known limits, canonical exemplar |

Dispositions: **port** (rule carried over, genericized), **author**
(net-new, informed by source), **distill** (worked example reduced from
private code or records to a shape that carries no private specifics),
**dropped** (deliberately not carried, with the reason).

Line anchors were taken at extraction time and drift with the sources;
the section names are the durable reference.

## Layer 1: the typed-holes skeleton

| Rule in `PLAYBOOK.md` | Source | Disposition | Notes |
|---|---|---|---|
| Full type surface first: real signatures, derives, `From`/`Into`, real leaf types | wiki `typed-holes` workstream, opening definition | port | Verbatim in substance; "ollama holes" informal name dropped as user-private vocabulary. |
| `todo!()` only at real-behavior bodies | `TYPE_PLAN.md` "Skeleton conventions" (~18-45) | port | |
| Trivial accessors implemented, not held open | `TYPE_PLAN.md` "Skeleton conventions" | port | Aura states it as `as_str`/field reads expose already-validated values read-only. |
| Fallible constructors return `Result` with the error enum complete | `TYPE_PLAN.md` "Skeleton conventions" | port | Aura: "Fallible constructors return `Result<_, ContextError>`". Error-enum completeness is the generalization. |
| Make invalid states unrepresentable (enums over flags, newtypes over bare `String`/`usize`, bounded collections) | `PROCESS.md` "Type discipline" (~516-554) | port | |
| Parse, do not validate | `PROCESS.md` "Type discipline" | port | |
| No bare domain value crosses the public boundary; errors carry no unvalidated domain payload | `TYPE_PLAN.md` "Boundary rule" (~52-66) | port, scoped | Aura's recorded serde exception is generalized into the template's "recorded exceptions" row. Here the rule covers domain values only, so a diagnostic-only error payload may stay raw text where nothing branches on it. |
| Public fields only where every field is validated; cross-field invariants stay private | `TYPE_PLAN.md` "Skeleton conventions" | port | |
| Pass-through `Display` impls are skeleton surface; format-bearing `Display` impls are behavior and must name what pins the format | `TYPE_PLAN.md` "Skeleton conventions" | port | Lives in `templates/skeleton-conventions.md` as a per-module table rather than in `PLAYBOOK.md`; aura's own split (four trivial, four format-bearing, each with its pinning source) is the model. |
| Skeleton passes `cargo check` + `cargo clippy` before any body, as its own commit | `PROCESS.md` "Type discipline" | port | Aura's reason carried verbatim in substance: the panel's input becomes a retrievable git object. |
| `cargo +nightly fmt --check` in the skeleton gate | aura board gate practice (card Gate S lines, S2 and S70) | author | Aura's Gate S runs fmt; promoting it into the skeleton gate is this repo's statement. Reconciled toward the skill's wording (plain `cargo fmt --check`, `+nightly` only where the repo pins nightly options) in `templates/dispatch-brief.md`; `templates/skeleton-conventions.md` and `templates/golden-frame-harness.md` still state the nightly-first form and are follow-up work outside the S4 scope. |
| `#[expect(unused_variables, reason = ...)]` on every `todo!()` fn that takes a parameter; `expect` over `allow` | `TYPE_PLAN.md` "Skeleton conventions" | port, corrected | The preference is aura's. Aura's self-removal rationale overstated `expect`: a zero-parameter hole trips `unfulfilled_lint_expectation` and a body that still ignores an argument keeps its marker, so this repo states both limits and keeps a marker sweep in the fill checklist. |
| Hole inventory: `clippy::todo` at warn during fill and deny at completion, or a baselined `grep -rn 'todo!(' src/` | none | author | Net-new. `todo!()` is a diverging panic and `clippy::todo` is allow-by-default, so nothing tracked the holes without this rule. |
| Module-level `#![allow(dead_code)]` on entry, removed per slice | wiki `typed-holes` workstream P1 | port | Closes the 06-17 retro open question the workstream tracks. |
| Every public type maps to one business rule with the forbidden invalid state named, in a co-located `DESIGN.md` | `PROCESS.md` "Type discipline" | port | Aura routes registry-era cards to a co-located `DESIGN.md`; repo-neutral form keeps only that route. |
| A type with no one-line rule is two types or a bag | none | author | Generalization from the S2 inventory's shape; not stated in the sources. |
| Design record also carries a visibility/seam table and named residual risks | `PROCESS.md` "Type discipline" (exemplar paragraph) + S2 harness `DESIGN.md` | port | Aura names the S2 record as the exemplar shape for new-type cards. |

## The design panel

| Rule in `PLAYBOOK.md` | Source | Disposition | Notes |
|---|---|---|---|
| Two-reviewer panel between skeleton and first body, context-isolated | `PROCESS.md` "Type discipline" | port | |
| Seat 1 adversarial: which invalid states remain representable, which states are production-unreachable | `PROCESS.md` "Type discipline" | port | Both questions are aura's wording in substance. |
| Seat 2 second-model logic review | `PROCESS.md` "Type discipline" + `REVIEW-TOOLING.md` "The standing rule" | port | |
| Findings numbered, each with its own disposition; aggregate counts are a failure | `PROCESS.md` "Type discipline" (S29 retro change 2, defect D1) | port | The defect that produced the rule is described without its card ids. |
| Reviewer differs from author | `REVIEW-TOOLING.md` "The standing rule" | port | The specific model pins and hosting providers are dropped. |
| Panel is required, not optional; it caught a production-unreachable fixture state and ten logic issues | `PROCESS.md` "Type discipline" + S2 card Log (2026-07-12 skeleton entry) | port | Counts kept here, card and model ids dropped. The public skill states the same claim without the counts. |
| Panel prompts (both seats) | none | author | Net-new. Assembled from the aura rule set; the serde question is the wiki P0 corrective, the coverage-claim and synthetic-state questions are generalized from the S2 panel's actual findings. |

## Layer 2: red-green golden frames

| Rule in `PLAYBOOK.md` | Source | Disposition | Notes |
|---|---|---|---|
| Expect-style golden tests of whole rendered frames, not string fragments | `retro-2026-07-02.md` "Rust development scheme" item 3 | port | The user's own theory, stated there. |
| Written pre-failing from the spec, as the spec-side complement of the skeleton | `retro-2026-07-02.md` item 3 | port | The complement framing ("the compiler tracks behavior holes, golden frames track rendering holes") is verbatim in substance and is this repo's organizing idea. |
| Test volume from accumulating string assertions is the failure mode being replaced | `retro-2026-07-02.md` item 3 | port | |
| Snapshot auto-acceptance disabled at gates; zero pending is part of the gate | S2 card Gate S (`INSTA_UPDATE=no`, "zero pending") | port | Tool-specific env var kept only in the examples file, as a worked command. |
| Committed coverage manifest naming every covered surface and, explicitly, what is not covered | S2 card Deliverable + Acceptance | port | |
| Exclusion rows carry reasons and name the tests that still own the path | S2 `MANIFEST.md` header | port | |
| Manifest states the identity claim's scope; a green suite is necessary, not sufficient | S2 `MANIFEST.md` "Envelope claim (scope)" | port | Carried into "Known limits" as well. |
| Normalization is location-anchored and runs before flattening | S2 `MANIFEST.md` / `normalize.rs` module docs | port | |
| Normalization is audited: marker collisions and missing markers panic, never skip | S2 `normalize.rs` "Occurrence audit" | port | |
| Byte-identity assertion mode for refactor cards | S2 card Deliverable | port | |
| Proven by BOTH a positive no-op refactor and a negative one-byte control | S2 card Acceptance ("proven by a no-op refactor") + S2 Log 2026-07-12 (the negative control that was actually run) | port | The card required only the positive control; the negative control is what the implementation added, and it is the control that can fail. Stated as required here. |
| Determinism constraints on corpus data belong in the manifest | S2 `golden_tests.rs` fixture data rules | port | |
| Harness builders call real production functions; test-only accessors are pure delegation; production visibility is never widened | S2 `DESIGN.md` "Envelope seam" | port | |
| Re-stated surfaces are marked in the manifest and closing them is required work | S2 `MANIFEST.md` "Re-stated rules" qualifier | port | |
| Deleting subsumed tests needs a ledger, new owning tests for orphaned paths, and an honest net-line delta | S2 card Acceptance + Log 2026-07-12 (the acceptance deviation) | port | The deviation is reported as the general lesson: infrastructure outweighs deletions on the first card. |
| Fixture types get the full Layer 1 treatment | S2 `scenario.rs` module docs + `DESIGN.md` | port | |
| A fixture type must forbid every state production cannot reach | S2 `DESIGN.md` type inventory + the panel's production-unreachable finding | port | Stricter-than-production framing is this repo's statement of aura's practice. |
| Harness module layout (facade / scenario / envelope / normalize / tests / snapshots / DESIGN / MANIFEST) | S2 harness directory | distill | Structure only; aura type names, prompt text, and snapshot content are all excluded. |

## Fill order and delegation

| Rule in `PLAYBOOK.md` | Source | Disposition | Notes |
|---|---|---|---|
| Fill order (skeleton, panel, pre-failing frames, fills, allow-removal) | `PROCESS.md` "Type discipline" ordering + `retro-2026-07-02.md` item 3 | author | The two sources give the sequence; the numbered list is this repo's. |
| Each fill removes its own marker and flips its goldens green; disagreement between the two signals is the Layer 2 case | none | author | The organizing claim of this playbook, derived from the retro's complement statement. |
| Skeleton is one unit of work, each fill another, with separate acceptance | `PROCESS.md` card-atomic rule (S29 retro change 3, cited in "Type discipline") | port | Board vocabulary genericized to "unit of work". |
| Typed holes proven under delegation, twice, with zero self-check gate failures | `retro-2026-07-02.md` item 1 | port | Gate name genericized. |
| API-convention drift accumulates across executors even when per-unit gates pass; the four named conventions | `retro-2026-07-02.md` item 2 | port | All four carried: `AsRef` over inherent `as_str`, no function-local consts, no `as_str().to_owned()` chains, no render-level placeholder over source-level optionality. |
| Fix is to bake conventions into executor briefs and review checklists | `retro-2026-07-02.md` item 2 | port | |
| Executors without skills get the rules quoted, not skills named | `REVIEW-TOOLING.md` "Card implementer standards" (~259+) | port | Aura's binding text is its own `PROCESS.md`; here the quote block is the binding text. |
| Dispatch brief quote blocks (skeleton and fill) | `REVIEW-TOOLING.md` "Card implementer standards" | author | Aura states the requirement; the block itself is net-new here. |

## Known limits

| Limit in `PLAYBOOK.md` | Source | Disposition | Notes |
|---|---|---|---|
| Compile surface misses partly-private ingress gaps; a real defect of this class survived a green skeleton; agent review caught it | wiki `typed-holes` workstream, Current State + Continuation Context | port | Commit shas, dates, branch names, and module names dropped. |
| Deterministic full-surface oracle is the open answer, not yet built | wiki workstream P3 | port | The private analysis path is not cited here. |
| Runtime semantic mismatches are unattested; record future findings as correctives, not technique failures | wiki workstream Continuation Context, hazard note | port | Verbatim in substance; this is the recorded standing instruction. |
| The technique is only as good as its signals (check, clippy, serde) | wiki workstream Continuation Context, hazard note | port | |
| `serde(untagged)` over enums with overlapping field shapes is a class of bug the compiler never flags, visible at the typing stage by inspection | wiki workstream P0 (06-23 corrective #4) | port, corrected | The wiki wording said the bug "shows up at the typing stage" and its example reversed the failure direction. Serde returns the first variant that deserializes in declaration order, so the subset variant declared first swallows the superset payload. The corrected sentence lands in the public `typed-holes` and `rust-design` skills; the example works it through. |
| A green golden suite is not behavioral evidence | S2 `MANIFEST.md` "Envelope claim (scope)" | port | |

## Examples

| Example | Source | Disposition | Notes |
|---|---|---|---|
| `examples/approval-client-adt.md` | wiki workstream's canonical-exemplar description of a private CLI approval client | distill | Written from the workstream's prose description of the ADT shape (`Approved` carries no reason; `Accepted` vs `NotFound`; the three distinct post-error variants), not copied from the private source file. Code shown is illustrative and re-authored. |
| The `serde(untagged)` bug narrative in that example | wiki workstream Current State | distill | Event and variant names generalized; no aura type names. |
| Scale note (three precise fixes; a larger sibling compiling on first pass) | wiki workstream Current State | distill | Line counts kept as rough magnitudes, module identities and commit shas dropped. |
| `examples/golden-frame-harness.md` | S2 card + S2 `DESIGN.md` / `MANIFEST.md` / `normalize.rs` | distill | Structure, rules, and rationale only. |

## Dropped (private or program-specific)

| Dropped | Source | Why |
|---|---|---|
| All commit shas, branch names, worktree paths, machine paths | every source | Private machine and repo specifics. |
| Model pins, hosting providers, and per-provider routing rules | `REVIEW-TOOLING.md` | Program-specific and volatile; the durable rule is reviewer-differs-from-author. |
| Card ids, board gate letters, WIP limits, wave vocabulary | `PROCESS.md`, card files | Board machinery. That is boardkit's surface, not this repo's; the playbook states the board mapping in one paragraph in `README.md`. |
| Benchmark scores, cost figures, token counts, LOC-measurement tooling | S2 card Log, `PROCESS.md` | Private program data, and irrelevant to the practice. |
| Aura type names, prompt text, snapshot contents, and template slot names | S2 harness | Private product content. |
| The informal user-side name for the practice | wiki workstream | User-private vocabulary. |
| Aura's specific serde boundary exception | `TYPE_PLAN.md` "Boundary rule" | Product-specific; generalized into the template's "recorded exceptions" row instead. |

## Standing obligations

- **Never publish.** This repo carries distilled private material. The
  public slice is the `typed-holes` skill in claude-skills, which must be
  self-sufficient without this repo.
- **Doctrine drift is checked against the skill.** The canonical statement
  of the practice is the `typed-holes` skill, not `PLAYBOOK.md` prose; the
  tripwire below compares the sources to the skill, and `PLAYBOOK.md` is
  only the map to this repo's templates.
- **Re-grep tripwire.** When the aura sources change, re-check that every
  rule in the skill still has a row here and that no new rule in
  `PROCESS.md` "Type discipline", `TYPE_PLAN.md` "Skeleton conventions",
  or the retro's "Rust development scheme" section is missing from the skill.
- **Correctives, not silent absorption.** A failure of the practice in
  future work is recorded against the "Known limits" section here and in
  the wiki workstream, never quietly patched into the playbook prose.

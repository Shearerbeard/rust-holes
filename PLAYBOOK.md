# The typed-holes playbook

Two layers of machine-tracked holes, filled over time.

- **Layer 1, type-checked surface.** Lay the full type surface with
  `todo!()` bodies. The compiler and clippy verify the design composes
  before any behavior exists. What is missing is tracked by the hole
  inventory, not by the compiler: `todo!()` is a diverging panic, so it
  type-checks wherever it sits.
- **Layer 2, test-runner-tracked.** Write whole-frame golden tests from the
  spec before the implementation, so they fail on arrival. The test runner
  tracks the rendering and semantics holes the compiler cannot see.

The layers are complements, not alternatives. The compiler checks the
surface while the hole inventory tracks the behavior holes; the failing
golden tests track rendering holes. Layer 1 alone is a
complete practice for a module with no rendered output. Layer 2 alone is
just snapshot testing.

This playbook is repo-neutral. It assumes a Cargo workspace and nothing
else. Where it names a skill in backticks (`rust-design`, `gate-probes`),
the skill is optional: every rule needed to execute the practice is stated
here, and the skills only make the rules load automatically.

Contents:

1. [Layer 1: the typed-holes skeleton](#layer-1-the-typed-holes-skeleton)
2. [The design panel](#the-design-panel)
3. [Layer 2: red-green golden frames](#layer-2-red-green-golden-frames)
4. [Fill order](#fill-order)
5. [Known limits](#known-limits)
6. [Delegating the work](#delegating-the-work)

## Layer 1: the typed-holes skeleton

### What lands

The full type surface, and nothing else:

- Real signatures, real derives, real `From`/`Into` impls, real leaf types.
  No placeholder `String` standing in for a type you have not written yet.
- `todo!()` appears **only** at real-behavior bodies: parsing, rendering,
  assembly, anything with a decision in it.
- Trivial accessors are implemented, not held open. A field read or an
  `as_str` over an already-validated value is not a behavior hole; leaving
  it as `todo!()` hides the type surface from the compiler rather than
  exposing it.
- Fallible constructors return `Result<_, YourError>` with the error enum
  fully written. An error type invented later is a type-surface change,
  which is the thing this step exists to catch early.

### Design rules the surface must satisfy

- **Make invalid states unrepresentable.** Enums over flags, newtypes over
  bare `String` or `usize`, non-empty or bounded collections where the
  domain demands them.
- **Parse, do not validate.** Constructors return `Result`; everything
  downstream handles only already-valid types.
- **No bare domain value crosses the public boundary.** Raw text and
  numbers enter through parsing constructors and leave as domain types.
  Error variants carry no unvalidated domain payload, so nothing rides
  out through the error path that the type surface forbids on the happy
  path. The rule's scope is domain values: a diagnostic payload in an
  error variant may stay raw text when the variant name and its docs mark
  it diagnostic-only and no domain logic branches on it. An unparsed
  response body reported alongside an unexpected status is the usual
  case; the moment a caller matches on its contents it has become a
  domain value and needs a type.
- **Fields are public only when every field is itself a validated type.**
  A struct with its own cross-field invariant keeps its fields private
  behind a parsing constructor.

### The skeleton commit

The skeleton must pass `cargo check` and `cargo clippy` before any body is
implemented, and it lands as **its own commit**. The commit is the point:
it makes the design panel's input a retrievable git object rather than a
conversation. An auditor can check out the skeleton and see exactly what
was reviewed.

Gate the skeleton commit on:

```
cargo check --workspace --all-targets
cargo clippy --workspace --all-targets -- -D warnings
cargo +nightly fmt --check
```

**Toolchain prerequisites.** `#[expect]` needs Rust 1.81 or newer; on an
older toolchain use `#[allow(unused_variables)]` with a tracking comment
naming the card that fills the body. `cargo +nightly fmt --check` needs a
nightly toolchain installed; where only stable is available, run plain
`cargo fmt --check`.

### The `#[expect]` marker convention

Every function that has a `todo!()` body **and at least one parameter**
carries:

```rust
#[expect(unused_variables, reason = "todo!() body; filled by <card or issue>")]
```

Use `expect`, not `allow`. While the lint fires the two behave alike, and
once it stops firing `expect` warns, so the marker asks to be removed at
the point it stops being true. Two limits belong in the same breath,
because the marker is easy to oversell:

- **A zero-parameter hole has nothing to mark.** With no parameters there
  is no `unused_variables` to expect, the expectation is unfulfilled from
  the moment it is written, and `unfulfilled_lint_expectations` fails the
  skeleton's own `-D warnings` gate. Leave those functions unmarked; the
  hole inventory below is what tracks them.
- **A filled body can keep its own marker alive.** The expectation only
  goes unfulfilled once the body uses *every* parameter. A body that
  lands while still ignoring one argument keeps a legitimate-looking
  marker, so each fill unit's checklist carries an explicit marker sweep
  rather than trusting the compiler to demand one.

The module-level counterpart is `#![allow(dead_code)]` on skeleton entry,
removed in slices as the holes fill. Like the per-function marker, it
needs an explicit removal step in the fill plan.

### The hole inventory

`todo!()` is a diverging panic, not debt the compiler tracks. A skeleton
full of them passes check and clippy alike, which is exactly what the
skeleton commit is for and also its blind spot. Track the holes
explicitly, by one of two routes:

- **Lint config available.** Enable `clippy::todo` at **warn** for the
  fill phase (a `[lints]` entry in `Cargo.toml`, or `#![warn(clippy::todo)]`
  at crate entry), and flip it to **deny** as the completion gate for the
  last fill unit. Because the per-unit clippy gate runs with `-D warnings`,
  which would promote those warnings to errors while holes remain, fill
  units gate with `-D warnings -A clippy::todo` and rely on the inventory
  for hole tracking; the last fill unit drops the `-A`. The lint is
  allow-by-default, and denying it from the skeleton commit onward would
  fail the skeleton's own clippy gate, so the sequence is the point.
- **Lint config not available.** Keep a deterministic inventory instead.
  `grep -rn 'todo!(' src/` at the skeleton commit is the baseline; each
  fill unit re-runs it and accounts for every line that changed, so a
  hole cannot quietly outlive the card that owned it.

### The type-to-business-rule map

Every public type in the skeleton maps to **one** business rule, with the
invalid state it forbids named explicitly. The map lives in a `DESIGN.md`
co-located with the module (template: `templates/DESIGN.md`).

A type that cannot be given a one-line business rule is a signal, not a
formatting problem: it is usually two types, or it is a bag with no
invariant to defend.

The design record also carries a visibility and seam table (what the
module reaches into, at what visibility, and what test-only accessors
exist) and named residual risks.

## The design panel

Between the skeleton commit and the first implemented body, the types pass
a context-isolated review panel of **two** reviewers.

1. **Adversarial invalid-states reviewer.** Applies the design rules above
   against the types: which invalid states can these types still
   represent? Does any type encode a state production cannot reach?
2. **Second-model logic reviewer.** A different model family from the
   author, reading the skeleton for logic, ordering, and seam errors.

Prompts for both: `templates/design-panel-prompts.md`.

**Findings are numbered, and each carries its disposition individually.**
For an accepted finding, the disposition is the repair. For a rejected
finding, the disposition is the reason. Aggregate counts ("8 findings, all
addressed") are a failure of the practice: no auditor can reconstruct
which repair answered which finding. Keep the per-finding record where an
auditor can find it (the module's `DESIGN.md`, or the card's review
directory if you run a board).

The panel is required, not optional. In its founding use it caught a
fixture type encoding a production-unreachable state plus ten logic
issues, before any body existed to debug.

## Layer 2: red-green golden frames

### The shape

Expect-style golden tests of **whole rendered frames**, not string
fragments. Where the unit under test emits a request envelope, a rendered
prompt, a serialized message, or any other complete artifact, the test
snapshots the complete artifact: every surface of it, in one snapshot.

The failure mode this replaces is the accumulation of string assertions,
one unit of work at a time. Twenty tests each asserting one substring cost more to
maintain than one snapshot of the whole frame, and they leave the gaps
between the substrings uncovered and unnamed.

### Pre-failing, from the spec

Write the goldens **before** the implementation, from the spec, so they
fail on arrival. That is what makes them Layer 2: the failing test is the
hole, the same way `todo!()` is the hole in Layer 1. A golden written
after the implementation records what the code does; a golden written
before it records what the code should do.

Practically: accept no snapshot until the body it covers is implemented.
Run the suite with snapshot auto-acceptance disabled in CI and at every
gate, so an unreviewed accepted snapshot cannot pass.

### The coverage manifest

Commit a manifest that maps every surface and branch to the fixture
covering it, and explicitly names the surfaces it leaves uncovered.

The exclusion rows are where the value is. A manifest that lists only
covered rows is a table of contents; a manifest whose exclusion rows carry
reasons and name the tests that still own those paths is a coverage
argument. Every exclusion row states either why the surface needs no
coverage or which other test owns it.

The manifest also states the **scope of the identity claim**: which
surfaces a passing snapshot proves unchanged. Be explicit that a green
snapshot suite proves the artifact is unchanged and never that behavior
downstream of the artifact is unchanged. That is a necessary condition,
not a sufficient one.

### Normalization

Nondeterministic bytes (timestamps, hash-map iteration order) need
normalization before snapshotting. Two rules keep normalization from
silently absorbing real drift:

- **Location-anchored, not text-global.** Rewrite at the structural
  position that produces the nondeterminism (this message, at this offset,
  inside this named span), operating on the structured artifact before it
  is flattened into the snapshot document. A global regex over flattened
  text can rewrite a payload byte that happens to look like a marker.
- **Audited.** Before any pass rewrites anything, assert that the artifact
  contains exactly the occurrences the passes expect, and panic otherwise.
  A marker appearing in a payload, or a marker missing where the builder
  should have emitted one, is a loud failure and never a silent skip.

### Byte-identity mode for refactor cards

Provide an assertion mode that asserts the rendered frame is
byte-identical to the committed baseline, and use it as the acceptance
gate for refactor work that must not change output.

**Prove the mode before trusting it**, with both controls:

- a positive control: a real no-op refactor leaves the whole suite
  green;
- a negative control: a deliberate one-byte change fails exactly the
  snapshots that cover it and leaves the rest green.

A mode proven only by the positive control cannot be distinguished from a
mode that asserts nothing. Record both transcripts in the design record.

## Fill order

1. Skeleton commit (Layer 1), green under check, clippy, fmt.
2. Design panel, numbered findings with per-finding dispositions; repairs
   land before any body.
3. Golden frames written pre-failing from the spec (Layer 2), plus the
   coverage manifest.
4. Fill bodies. Each fill sweeps its own `#[expect]` markers, accounts
   for its lines in the hole inventory, and flips its golden frames from
   red to green. The two signals must agree: a body that compiles clean
   while its golden stays red is a rendering hole the compiler was always
   blind to, which is the case Layer 2 exists for.
5. Remove the module-level `#![allow(dead_code)]` slice by slice as the
   surface goes live, and close the inventory: `clippy::todo` at deny, or
   a `grep` that returns nothing.

Where the work is split across cards or issues, the skeleton is one unit
of work and each fill is another. The skeleton unit's acceptance is
"compiles, lints, panel dispositioned"; a fill unit's acceptance is "its
markers swept and its inventory lines accounted for, with its goldens
green".

## Known limits

Record these as standing limits, and record future failures against them
as correctives rather than as refutations of the technique.

- **The compile surface misses partly-private ingress gaps.** A real
  defect of this class survived a green skeleton: the type surface was
  correct at the module boundary while an ingress path at a narrower
  visibility bypassed it. The compiler cannot see it because nothing
  ill-typed is written. Agent review at the design panel caught it, which
  is one of the reasons the panel is not optional. A deterministic
  full-surface oracle (an AST pass that enumerates every ingress path
  regardless of visibility) is the open answer, not yet built.
- **Runtime semantic mismatches are unattested.** The technique has never
  been shown to catch a defect where the types compose correctly and the
  runtime meaning is wrong. Do not claim it does. When a defect of this
  class appears, record it as a corrective against the practice.
- **The technique's value is downstream of its signals.** It is only as
  trustworthy as `cargo check`, clippy, and serde derive behavior. Where a
  signal is weak, the practice inherits the weakness. Serde is the worked
  case. `serde(untagged)` tries the variants in declaration order and
  returns the first that deserializes, so an enum whose variants have
  overlapping field shapes can take a payload as the wrong variant. That
  is runtime deserialization behavior and the compiler never flags it;
  what the typing stage buys is that the risk is visible by inspecting
  the overlapping field shapes in the declaration, so the panel checks
  every derive whose behavior is not obvious from the type.
- **A green golden suite is not behavioral evidence.** It proves the
  artifact bytes are unchanged. Downstream work must not read it as proof
  that behavior, scores, or user-visible outcomes are unchanged.

## Delegating the work

The skeleton is the expensive design step and the fills are cheap, so the
practice splits well across model classes: a stronger model lays the type
surface, smaller models fill bodies against green-when-done criteria. Two
delegated implementations landed with zero self-check gate failures under
this split.

Two things go wrong under delegation, both with the same fix:

- **API-convention drift accumulates across executors** even when every
  per-unit gate passes: inherent `as_str` methods with no `AsRef` impl,
  function-local consts, `as_str().to_owned()` chains, render-level
  placeholders papering over source-level optionality. Per-unit gates
  cannot see a cross-unit trend. Bake the conventions into executor briefs
  and into the review checklist rather than hoping a reviewer notices the
  fourth instance.
- **Executors without skills get none of these rules automatically.** An
  executor outside the harness that auto-loads `rust-design` and
  `rust-quality` receives only its brief. For those executors the brief
  **quotes** the rules instead of naming skills.

The quote-block is `templates/dispatch-brief.md`. Keep the
reviewer-differs-from-author invariant across both layers: the model that
wrote the skeleton is not the model on the panel's second seat, and the
model that filled a body is not the one that reviews the fill.

# Worked example: a golden-frame harness

This is the Layer 2 exemplar. A snapshot harness covers an LLM request
envelope whose assembly draws on a system preamble, an ordered message
list, and a serialized tool-definition JSON blob. The harness snapshots
all three surfaces as one frame.

Rules applied here: `../PLAYBOOK.md`, section "Layer 2".

## Module layout

A single test-only module beside the code it covers, declared
`#[cfg(test)] mod <name>;` at the parent so nothing ships in release
builds:

```
<module>/
  mod.rs          facade: re-exports, the assertion entry point
  scenario.rs     fixture scenario types (this is a Layer 1 skeleton too)
  envelope.rs     glue that calls the REAL production builders
  normalize.rs    the audited, location-anchored normalization passes
  golden_tests.rs one test per manifest row group
  snapshots/      committed .snap files
  DESIGN.md       type inventory, seam table, panel findings, residual risks
  MANIFEST.md     the coverage manifest
```

That split is what keeps the harness from drifting. `scenario.rs` holds
types with invariants and gets the full Layer 1 treatment (its own design panel, its own `DESIGN.md` rows).
`envelope.rs` holds no invariants: it calls production builders and
re-implements nothing. Keeping them apart is what stops the harness from
growing a second, divergent copy of the thing it tests.

## The rule that keeps a harness honest

**Builders call the real assembly functions. Nothing in the harness
re-implements the output.**

Where a production function is private, the harness gets a
`#[cfg(test)] pub(crate)` accessor that is *pure delegation*: it takes the
same inputs, calls the private function, returns its output, and adds no
behavior. Every such accessor is a row in the seam table with its reason.
Production visibility is never widened.

A harness that re-states the rendering it is checking snapshots its own
opinion. Mark any surface that is unavoidably re-stated in the manifest as
re-stated, and treat closing those as required work rather than as a
nice-to-have.

## Fixture types are typed too

```rust
/// Why a fixture scenario failed to construct.
///
/// Every fallible fixture constructor returns this, so a snapshot test
/// only ever holds a scenario corresponding to a reachable production
/// state.
#[derive(Debug, Clone, PartialEq, Eq, thiserror::Error)]
pub(crate) enum FixtureError {
    #[error("domain value rejected: {0}")]
    Domain(#[from] DomainError),
    #[error("a terminal decision cannot precede a further call")]
    TerminalMidThread,
}
```

The design rule for a fixture type is stricter than for a production type:
it must forbid every state production cannot reach. A fixture that can
assemble a synthetic combination produces a snapshot pinning behavior no
user will ever see, and that snapshot then blocks refactors for no
reason. Seat 1 question 2 of the design panel exists for this case. In
the founding use it caught a fixture that could append a worker entry on
a path where production appends only inside a branch.

## Normalization, audited

Two nondeterminism sources in this envelope: a live timestamp and hash-map
iteration order in a roster. Both passes are location-anchored:

- The timestamp rewrite is anchored at byte offset 0 of a user-message
  body, because that is the only place the builder emits it. The same text
  anywhere else is payload and is left alone.
- The roster sort runs inside two named spans of the first user message
  only, because that is the only message that renders a roster.

Both run over the structured envelope, per message, **before** the
snapshot document is flattened. A global regex over flattened text could
rewrite a payload byte that happens to look like a marker.

Before either pass rewrites anything, an audit asserts the envelope holds
exactly the occurrences the passes expect and panics otherwise:

- user messages are all-or-none on the timestamp prefix; a mixed envelope
  means builder drift;
- a prefix that does not parse as the full expected form is a defect,
  never a skip;
- each span marker appears at most once, only where expected, and nowhere
  else; a fixture payload embedding a marker is a loud failure rather than
  a mis-sorted span.

Fixture payloads are written to avoid the markers, and the audit is what
enforces that.

## The coverage manifest

`MANIFEST.md` maps every surface and branch to a row. Each row is either
mapped to a fixture or explicitly excluded with a reason, and every
exclusion row that leans on older unit tests names the tests that still
own it. Rows marked excluded are outside the identity claim.

The manifest opens with the claim scope, stated in these terms: every
fixture snapshots the full request triple (preamble string, ordered
message list, serialized tool-definition JSON). Final assembly downstream
of this seam is a named residual risk, not a covered surface. Envelope
identity is a **necessary** condition for behavioral neutrality, never a
sufficient one; a passing corpus proves the requests are unchanged, never
that behavior is.

Determinism constraints on the corpus data belong in the manifest too:
where a production surface iterates a hash map, the corpus is written so
at most one such entry exists per scenario, and the multi-entry branch
keeps its older non-snapshot coverage. That constraint is a manifest row,
not a comment in a test.

## Byte-identity mode, and proving it

For refactor work that must not change output, the harness offers an
assertion mode that compares the rendered frame byte for byte against the
committed baseline.

Prove it with both controls before any refactor depends on it:

- **Positive control.** A real no-op refactor: whole suite green.
- **Negative control.** A deliberate one-byte change: exactly the
  snapshots covering that byte fail, and every other snapshot stays green.

The negative control is the one that matters. A mode proven only by the
positive control is indistinguishable from a mode that asserts nothing.
Record both transcripts in `DESIGN.md`.

## Running the suite

Run with snapshot auto-acceptance disabled everywhere it counts, so an
unreviewed accepted snapshot cannot pass a gate:

```
INSTA_UPDATE=no cargo test --package <crate> --lib
```

Zero pending snapshots is part of the gate, not a separate cleanup step.

## What this replaced

The harness consolidated a large per-card accumulation of string-assertion
tests. Deleting them needs its own ledger. Record which cases the
snapshots subsume, and which cases are retained and why; add owning tests
for any path left without one once the old file shrank. Report the net
test-line delta. In the founding use it went up, not down, because the
corpus infrastructure outweighed the deleted assertions on the first card;
the reduction belongs to the program, not to the card that builds the
harness.

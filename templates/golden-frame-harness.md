# Golden-frame harness template

Template. The module shape and starting skeletons for a Layer 2 harness,
distilled from the worked example at `../examples/golden-frame-harness.md`;
the rules are `../PLAYBOOK.md`, section "Layer 2". Copy the files and
replace every `<placeholder>`. The fill order is the PLAYBOOK's: the
harness's own type skeleton (`scenario.rs` is a Layer 1 skeleton) lands
as its own commit and passes the full skeleton gate (`cargo check`,
`cargo clippy -- -D warnings`, fmt), the design panel runs, and only then
are the goldens written, pre-failing from the spec.

## Module shape

A single test-only module beside the code it covers, declared at the
parent so nothing ships in release builds:

```rust
#[cfg(test)]
mod golden;
```

```
<module>/golden/
  mod.rs          facade: re-exports, the assertion entry point
  scenario.rs     fixture scenario types (a Layer 1 skeleton in its own right)
  envelope.rs     glue that calls the REAL production builders
  normalize.rs    audited, location-anchored normalization passes
  golden_tests.rs one test per manifest row group
  snapshots/      committed .snap files
  DESIGN.md       from ../templates/DESIGN.md
  MANIFEST.md     from ../templates/MANIFEST.md
```

The split is what keeps the harness from drifting: `scenario.rs` holds
types with invariants and
gets the full Layer 1 treatment; `envelope.rs` holds no invariants, calls
production builders, and re-implements nothing. Builders call the real
assembly functions; a harness that re-states the rendering it checks
snapshots its own opinion.

## mod.rs

```rust
//! Golden-frame harness for <artifact>. See MANIFEST.md for the
//! identity-claim scope and DESIGN.md for the type record.

// Skeleton entry: removed in slices as the holes fill, per the PLAYBOOK
// marker convention. Needs its own removal step in the fill plan.
#![allow(dead_code)]

mod envelope;
mod normalize;
mod scenario;

mod golden_tests;

// Re-export only what golden_tests uses today; a facade line with no
// user yet is an unused-imports error under the -D warnings gate. Grow
// the facade as consumers appear.
pub(crate) use envelope::render_frame;
pub(crate) use scenario::Scenario;
```

## scenario.rs

Fixture types are typed too, and stricter than production: a fixture must
forbid every state production cannot reach, or its snapshots pin behavior
no user sees and block refactors for no reason.

```rust
use <crate>::<domain error path>::DomainError;

/// Why a fixture scenario failed to construct.
///
/// Every fallible fixture constructor returns this, so a snapshot test
/// only ever holds a scenario corresponding to a reachable production
/// state.
#[derive(Debug, Clone, PartialEq, Eq, thiserror::Error)]
pub(crate) enum FixtureError {
    #[error("domain value rejected: {0}")]
    Domain(#[from] DomainError),
    #[error("<the production-unreachable ordering this fixture forbids>")]
    <UnreachableState>,
}

/// One reachable production state, parsed at construction.
#[derive(Debug, Clone)]
pub(crate) struct Scenario {
    // private fields; cross-field invariants live in the constructor
}

impl Scenario {
    #[expect(unused_variables, reason = "todo!() body; filled by <card or issue>")]
    pub(crate) fn new(<inputs>) -> Result<Self, FixtureError> {
        todo!()
    }
}
```

## envelope.rs

```rust
use super::scenario::Scenario;

/// The complete rendered frame: every surface named in MANIFEST.md's
/// identity-claim scope, in one value.
#[derive(Debug, Clone, PartialEq, Eq)]
pub(crate) struct Frame {
    // e.g. preamble: String, messages: Vec<Message>, tools_json: String
}

/// Calls the REAL production builders. No rendering is re-implemented
/// here; where a production function is private, use a
/// `#[cfg(test)] pub(crate)` pure-delegation accessor and record it in
/// DESIGN.md's seam table.
#[expect(unused_variables, reason = "todo!() body; filled by <card or issue>")]
pub(crate) fn render_frame(scenario: &Scenario) -> Frame {
    todo!()
}
```

## normalize.rs

Location-anchored, audited passes over the structured frame, before it is
flattened into the snapshot document. A global regex over flattened text
can rewrite a payload byte that happens to look like a marker.

```rust
use super::envelope::Frame;

/// Rewrites nondeterministic bytes at their structural positions only.
/// Before any pass rewrites anything, `audit` asserts the frame holds
/// exactly the occurrences the passes expect, and panics otherwise: a
/// marker in a payload, or a marker missing where the builder emits one,
/// is a loud failure and never a silent skip.
#[expect(unused_variables, reason = "todo!() body; filled by <card or issue>")]
pub(crate) fn normalize(frame: Frame) -> Frame {
    todo!()
}

#[expect(unused_variables, reason = "todo!() body; filled by <card or issue>")]
fn audit(frame: &Frame) {
    todo!()
}
```

## golden_tests.rs

One test per manifest row group, written pre-failing from the spec. Run
with snapshot auto-acceptance disabled everywhere it counts
(`INSTA_UPDATE=no cargo test`); zero pending snapshots is part of the
gate.

```rust
use super::{render_frame, Scenario};
use super::normalize::normalize;

#[test]
fn <manifest_row_group>() {
    let scenario = Scenario::new(<spec inputs>).expect("reachable state");
    let frame = normalize(render_frame(&scenario));
    insta::assert_debug_snapshot!(frame);
}
```

## Byte-identity mode

For refactor cards, assert the frame byte-identical to the committed
baseline. With the snapshot harness above, the entry point is the same
suite run against the unchanged committed snapshots with auto-acceptance
disabled (`INSTA_UPDATE=no cargo test --package <crate> --lib`): any byte
of drift in a covered surface fails its snapshot, and zero pending
snapshots is part of the gate. Prove the mode with both controls before
any refactor
depends on it: a real no-op refactor leaves the suite green, and a
deliberate one-byte change fails exactly the snapshots covering it.
Record both transcripts in DESIGN.md. A mode proven only by the positive
control is indistinguishable from one that asserts nothing.

## Checklist, in the PLAYBOOK's fill order

- [ ] Module shape above in place as its own skeleton commit, green under
      the full skeleton gate (`cargo check --workspace --all-targets`,
      `cargo clippy --workspace --all-targets -- -D warnings`,
      `cargo +nightly fmt --check`), with `todo!()` bodies and
      `#[expect]` markers per the PLAYBOOK marker convention
- [ ] DESIGN.md filled for `scenario.rs` types; panel run and
      dispositioned before any body or golden lands
- [ ] MANIFEST.md filled: identity-claim scope, covered rows, exclusion
      rows with reasons, determinism constraints
- [ ] Goldens written pre-failing from the spec, auto-acceptance disabled

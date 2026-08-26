# Skeleton conventions

Template. The per-module conventions section. Copy into the module's
`DESIGN.md` or keep beside it, fill the angle brackets, delete this
line. The rules behind these conventions are in `../PLAYBOOK.md`; this
file is the per-module statement of how they were applied. When you copy
this file, record `copied from rust-holes@<sha>` in the copy, where
`<sha>` is this repo's HEAD at copy time.

## What is held open

- Bodies with real behavior (parsing, rendering, assembly) start as
  `todo!()` and land with <the cards, issues, or PRs that fill them>.
- Fallible constructors return `Result<_, <ErrorType>>`. The error enum is
  complete in the skeleton; adding a variant later is a type-surface
  change and re-enters the panel.

## What is implemented in the skeleton

- Trivial accessors (`as_str`, field reads) are implemented. They expose
  already-validated values read-only, so they are type surface, not
  behavior.
- `Display` impls that are pass-throughs of a validated value are
  implemented. Format-bearing `Display` impls are behavior: list them here
  with the format they must reproduce and the source that pins it.

| Impl | Kind | Pinned by |
|---|---|---|
| `<Type>: Display` | pass-through | n/a |
| `<Type>: Display` | format-bearing | <spec section or the parser that keys on it> |

## Markers and hole inventory

- Every `todo!()` function that takes at least one parameter carries
  `#[expect(unused_variables, reason = "todo!() body; filled by <ref>")]`.
  The `expect` form warns once the lint stops firing, which is the point
  of preferring it to `allow`, but it self-removes only when the filled
  body uses every parameter. Zero-parameter holes take no marker at all:
  the expectation would be unfulfilled on arrival and fail the `-D
  warnings` gate.
- Every fill unit sweeps the markers of the bodies it landed rather than
  waiting for the compiler to demand it.
- The holes themselves are tracked by <`clippy::todo` at warn during the
  fill phase, denied at completion / `grep -rn 'todo!(' src/`, baselined
  at the skeleton commit>. `todo!()` is a diverging panic and the lint is
  allow-by-default, so nothing tracks the holes unless this line does.
- Module entry carries `#![allow(dead_code)]`, removed per slice as the
  holes fill. The removal is a step in the fill plan.

## Boundary rule

No bare `String` or `usize` domain value crosses the module's public
boundary. Raw text and numbers appear only as parsing-constructor inputs.
Rendered output leaves as `<RenderedType>`, not `String`. `<ErrorType>`
variants carry <no payload / only already-validated payload>, so no
unvalidated domain value rides out through the error type.

The rule covers domain values. A diagnostic payload in an error variant
may stay raw text where the variant name and its docs mark it
diagnostic-only and no domain logic branches on it; list those variants
here so the panel can check the claim.

Recorded exceptions (each needs a panel disposition):

- <exception, the reason, and the finding number that accepted it>

## Field visibility

- Fields are public only where every field is itself a validated type.
- Structs with a cross-field invariant keep fields private behind a
  parsing constructor.

## Gate commands

The skeleton commit is green under all three before the panel sees it:

```
cargo check --workspace --all-targets
cargo clippy --workspace --all-targets -- -D warnings
cargo +nightly fmt --check
```

Prerequisites: `#[expect]` needs Rust 1.81 or newer, and the `+nightly`
form needs a nightly toolchain. On an older compiler, use
`#[allow(unused_variables)]` with a tracking comment; with stable only,
run plain `cargo fmt --check`.

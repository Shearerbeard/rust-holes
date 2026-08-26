# Dispatch brief block

Template. For executors that do not load skills, such as a model outside
the harness or a CLI agent. Those executors receive only their brief, so
the brief **quotes** the rules instead of naming skills. When you copy
this file, record `copied from rust-holes@<sha>` in the copy, where
`<sha>` is this repo's HEAD at copy time.

Paste the block below into the brief verbatim, fill the angle brackets,
and delete everything above the rule line. Nothing in the block depends on
a skill being installed.

Two briefs exist because the two layers are separate units of work: the
skeleton brief and the fill brief. Send the one that matches the unit.

---

## Skeleton brief block

> **Type discipline (binding for this task).**
>
> 1. Lay the full type surface: real signatures, real derives, real
>    `From`/`Into` impls, real leaf types. Do not stand in a placeholder
>    `String` for a type you have not written.
> 2. `todo!()` goes only in bodies with real behavior (parsing,
>    rendering, assembly). Implement trivial accessors and field reads.
> 3. Make invalid states unrepresentable: enums over flags, newtypes over
>    bare `String` or `usize`, bounded or non-empty collections where the
>    domain demands them.
> 4. Parse, do not validate. Fallible constructors return `Result` with
>    the error enum complete. Downstream code handles only already-valid
>    types.
> 5. No bare `String` or `usize` domain value crosses the module's public
>    boundary. Error variants carry no unvalidated domain payload; raw diagnostic
>    text is allowed only where the variant's docs mark it diagnostic-only.
> 6. Fields are public only where every field is itself a validated type;
>    a struct with a cross-field invariant keeps its fields private
>    behind a parsing constructor.
> 7. Every function that has a `todo!()` body **and at least one
>    parameter** carries
>    `#[expect(unused_variables, reason = "todo!() body; filled by <ref>")]`.
>    Use `expect`, never `allow`: it warns once the lint stops firing.
>    Do not mark a zero-parameter function: with no unused variable the
>    expectation is unfulfilled on arrival and fails the `-D warnings`
>    gate. Module entry carries `#![allow(dead_code)]`.
> 8. Deliver a `DESIGN.md` next to the module mapping every public type to
>    one business rule and naming the invalid state it forbids, plus a
>    visibility and seam table and named residual risks.
> 9. The skeleton is its own commit and must be green under
>    `cargo check --workspace --all-targets`,
>    `cargo clippy --workspace --all-targets -- -D warnings`, and
>    `cargo +nightly fmt --check` (plain `cargo fmt --check` where the
>    executor has no nightly toolchain). Do not implement any body in
>    this unit.
>
> **API conventions (drift accumulates across executors; these are
> checked at review).**
>
> - Provide `AsRef` impls rather than inherent `as_str` methods where the
>   type is a wrapper over a borrowed form.
> - No function-local consts. Hoist to module scope.
> - No `as_str().to_owned()` chains; take the owned form directly.
> - Never paper over source-level optionality with a render-level
>   placeholder. If the source value is optional, the type says so.
>
> **Out of scope.** Do not implement bodies, do not widen production
> visibility, do not add dependencies beyond <the named ones>.

---

## Fill brief block

> **Fill discipline (binding for this task).**
>
> 1. Fill only the bodies named in this brief: <list>. Do not change any
>    signature, derive, or type. A signature change means the skeleton was
>    wrong; stop and report it rather than editing it.
> 2. Remove each filled function's `#[expect(unused_variables, ...)]`
>    marker by hand. Do not wait for the compiler to ask: a body that
>    still ignores one of its arguments keeps the expectation fulfilled
>    and the marker silent.
> 3. The golden tests covering these bodies are already committed and
>    already failing. Your unit is done when they are green and no
>    snapshot was accepted by hand: run the suite with snapshot
>    auto-acceptance disabled.
> 4. Do not add, edit, or re-accept a snapshot. A golden that seems wrong
>    is a finding to report, not a file to update.
> 5. Green means: `cargo clippy --workspace --all-targets -- -D warnings
>    -A clippy::todo` (drop the `-A` on the last fill unit),
>    `cargo +nightly fmt --check`, and the named tests passing.
>
> **API conventions.** Same four rules as the skeleton brief (`AsRef` over
> inherent `as_str`, no function-local consts, no `as_str().to_owned()`
> chains, no render-level placeholder over source-level optionality).

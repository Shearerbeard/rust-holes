# Dispatch brief block

Template. For executors that do not load skills, such as a model outside
the harness or a CLI agent. Those executors receive only their brief, so
the brief **quotes** the rules instead of naming skills. When you copy
this file, record `copied from rust-holes@<sha>` in the copy, where
`<sha>` is this repo's HEAD at copy time.

Select one block for a worker without skill access. Fill its assignment
fields from the approved spec. For a skill-capable worker, send the
assignment fields and name the skill to load instead of copying the block.
On a boardkit board, `boardkit dispatch-brief <card-id>` supplies the card
and its contract. Include that brief or stage it at a readable path in the
worker's worktree and name the path in the kickoff.

---

## Skeleton brief block

> **Type discipline (binding for this task).**
> **Executor class:** smart writer-reviewer; this is the design step.
>
> Inputs: <approved spec path/revision and approval state>, <input commit>,
> <allowed files>, <exact checks>. Missing approval or requirements return
> to the spec owner. This block supplies rules to an executor without skill
> loading; a skill-loading executor must also have effective access.
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
> 8. Include `DESIGN.md` in the skeleton commit, next to the module. Map every public type to
>    one business rule and name the invalid state it forbids. Include a
>    visibility and seam table and named residual risks.
> 9. The skeleton is its own commit and must be green under
>    `cargo check --workspace --all-targets`,
>    `cargo clippy --workspace --all-targets -- -D warnings`, and
>    `cargo fmt --check` (the `+nightly` form only where the repo pins
>    nightly rustfmt options). Leave the named behavior holes for fill units.
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
> **Out of scope.** Do not fill behavior holes, widen production
> visibility, or add dependencies beyond <the named ones>.

---

## Test-author brief block

> **Spec-derived tests (binding for this task).**
> **Executor class:** smart writer-reviewer in a fresh test-only assignment.
>
> Inputs: <approved spec path/revision>, <accepted skeleton commit>,
> <isolated worktree>, <allowed tests/fixtures/coverage record>,
> <approved fixture dependencies>, <exact checks>, <marker-maintenance owner>.
>
> 1. Derive complete expectations from the spec and fixture inputs. Do not
>    reuse append returns as expected read/replay values: both paths can share
>    the same defect. Check both against independent expectations.
> 2. Write behavioral tests for non-rendering work. Snapshot whole emitted
>    artifacts only where those exist, with auto-acceptance disabled.
> 3. Use the smallest scenarios that distinguish the required wrong behaviors.
>    Share repetitive setup within the suite; retain separate checks that
>    reject different failures. Do not build a parallel implementation.
> 4. Map each test to every required body once, with exclusions and evidence
>    links. A test needing a later fill stays red until that dependency lands.
>    Reference the spec rather than copying its narrative into the record.
> 5. Compile/lint cleanly before recording expected hole failures. Maintain only
>    explicitly assigned obsolete lint markers; otherwise return the marker
>    edit to its owner. A hole panic proves reachability, not oracle strength.
> 6. For critical limits, exclusions and conversions, name a wrong
>    implementation and the discriminating assertion. If executing the control
>    needs unassigned production edits, record it pending with <later owner/check>.
>    Run selected mutants in a disposable worktree when those bodies exist.
> 7. Return API friction, missing fixture access, new dependencies or platform
>    prerequisites to the coordinator before adopting a workaround. A materially changed implementation shape
>    returns for scope review; estimates are not quotas.
>
> Return changed files, named first-red failures with counts and reasons,
> and the compact coverage/body map, including pending controls, to the
> coordinator for test review before fills. Do not fill production bodies or alter signatures.

---

## Fill brief block

> **Fill discipline (binding for this task).**
> **Executor class:** small explorer.
>
> Inputs: <spec revision>, <input commit>, <named tests and required bodies>,
> <remaining holes and expected intermediate red set>, <exact checks>.
> The owner partitions coupled bodies so this unit can pass its named tests.
>
> 1. Fill only the bodies named in this brief: <list>. Do not change any
>    signature, derive, or type. A signature change means the skeleton was
>    wrong; stop and report it to the coordinator rather than editing it.
> 2. Remove each filled function's `#[expect(unused_variables, ...)]`
>    marker by hand. Do not wait for the compiler to ask: a body that
>    still ignores one of its arguments keeps the expectation fulfilled
>    and the marker silent.
> 3. Spec-derived tests covering these bodies are committed and already
>    failing. Behavioral tests apply even without a rendered artifact.
>    Your unit is done when its named tests pass; run snapshot tests with
>    auto-acceptance disabled.
> 4. Do not add, edit, or re-accept a snapshot. A golden that seems wrong
>    is a finding to report, not a file to update.
> 5. Green means: `cargo clippy --workspace --all-targets -- -D warnings
>    -A clippy::todo` (drop the `-A` only when no authorized holes remain
>    under this command's scope),
>    `cargo fmt --check` (the `+nightly` form only where the repo pins
>    nightly rustfmt options), and the named tests passing.
> 6. Do not change the supplied tests or expected results. The test owner
>    derives them from the spec and supplies discriminating evidence for
>    critical limits, exclusions and conversions. Report a suspected oracle
>    defect to the coordinator for test-owner disposition instead of making
>    the implementation and test agree.
> 7. Mechanically check that no `todo!()` remains in the completed assigned
>    body scope. Account separately for authorized holes elsewhere; green
>    tests alone do not establish completion. Return the changes and check
>    evidence to the coordinator for implementation review.
>
> **API conventions.** Same four rules as the skeleton brief (`AsRef` over
> inherent `as_str`, no function-local consts, no `as_str().to_owned()`
> chains, no render-level placeholder over source-level optionality).

# Design panel prompts

Template. One `rust-reviewer` pass reading the skeleton commit in a
fresh context with no memory of the design conversation. The reviewer
covers both invalid-states and logic/seams questions in one session.
The reviewer may not share a model family with the skeleton's author.
Findings come back numbered; each disposition is recorded individually
in the module's `DESIGN.md`. When you copy this file, record `copied from
rust-holes@<sha>` in the copy, where `<sha>` is this repo's HEAD at copy
time.

Fill the angle brackets. Point the reviewer at file paths, not pasted
contents, when the reviewer can read the repo itself.

## Default: single combined reviewer

> You are reviewing a Rust type skeleton at commit `<sha>`. Every body is
> `todo!()`; that is intentional and is not a finding. Files:
> `<paths>`. The spec this skeleton implements is `<path>`. The design
> record naming each type's business rule and the invalid state it forbids
> is `<path to DESIGN.md>`.
>
> Read the spec first, then the types. Review adversarially — your job is
> to find where the types fail, not to confirm they hold.
>
> **Invalid-states questions:**
>
> 1. **Which invalid states can these types still represent?** For each
>    type, try to construct a value that is well-typed and meaningless.
>    Cross-field combinations count: a struct whose fields are each valid
>    but whose combination is not is a finding.
> 2. **Does any type encode a state production cannot reach?** An
>    unreachable variant or an optional field that is always `Some` in
>    practice is a finding: it is surface that will be covered by tests
>    that prove nothing.
> 3. **Does any bare `String`, `usize`, or unbounded collection cross the
>    public boundary?** Including through error variants and through
>    serialization derives. The one allowed exception: raw diagnostic
>    text in an error variant whose docs mark it diagnostic-only and
>    which no caller branches on.
> 4. **Does every public type map to exactly one business rule in the
>    design record?** A type with two rules should be two types. A type
>    with none is a bag.
> 5. **Do fallible constructors return `Result`, and does downstream code
>    take only already-valid types?** A validate-then-use path anywhere is
>    a finding.
> 6. **Do serde derives mean what the type means?** `#[serde(untagged)]`
>    over enums whose variants have overlapping field shapes silently
>    deserializes one variant as another. Check every derive whose
>    behavior is not obvious from the type.
> 7. **Field visibility:** public fields are allowed only where every
>    field is itself a validated type. A struct with a cross-field
>    invariant and public fields is a finding.
>
> **Logic and seams questions:**
>
> 8. **Spec-to-type mismatches.** A rule in the spec with no type
>    enforcing it, or a type enforcing something the spec does not say.
> 9. **Ordering and sequencing errors.** Where the spec fixes an order
>    (of appends, of fields, of calls) and the types leave it free, or fix
>    it wrongly.
> 10. **Seam errors.** What this module reaches into, at what visibility,
>     and whether the design record's visibility table is accurate.
>     Test-only accessors that carry test-only behavior instead of pure
>     delegation are findings.
> 11. **Coverage claims that are false.** If a coverage manifest or design
>     record claims a surface is covered, check the claim against the
>     types. A claim the types cannot support is a finding.
> 12. **Synthetic states.** Fixture or builder types that can assemble
>     combinations production never produces.
> 13. **Error modeling.** Whether the error enum distinguishes the failure
>     modes a caller must act on differently, and collapses the ones it
>     must not.
>
> Return numbered findings. For each: the type, the concrete issue, and
> the repair you would make. Mark each BLOCKING or MINOR. End with a
> one-line verdict. Zero findings is a valid result; state it explicitly
> as PASS rather than returning nothing.

## Optional: second reviewer (explicit user request only)

A second, separately dispatched reviewer covering the same question sets
in a parallel fresh session is available on explicit user request. It is
not dispatched by default. Use this prompt for that seat.

> You are reviewing a Rust type skeleton at commit `<sha>`. Every body is
> `todo!()`; that is intentional and is not a finding. Files:
> `<paths>`. The spec this skeleton implements is `<path>`. The design
> record is `<path to DESIGN.md>`.
>
> Read the spec first, then the types. Apply all invalid-states and
> logic/seams questions from the design panel (see the template). Return
> numbered findings, each marked BLOCKING or MINOR, each with the repair
> you would make. End with a one-line verdict. State PASS explicitly if
> you find nothing.

## Recording the result

- Every finding gets a row in the design record with its own disposition:
  the repair for an accepted finding, the reason for a rejected one.
- Record the author model and the reviewer model. The invariant that a
  model never grades its own output is auditable only if it is written
  down.
- Repairs land before the first body. A finding deferred past the first
  fill is a finding the practice did not catch.

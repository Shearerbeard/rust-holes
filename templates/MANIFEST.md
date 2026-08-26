# <module> coverage manifest

Template. Copy next to the golden-frame harness it describes, fill every
section, delete this line. Rules for the content: `../PLAYBOOK.md`,
section "The coverage manifest"; worked shape:
`../examples/golden-frame-harness.md`. When you copy this file, record
`copied from rust-holes@<sha>` in the copy, where `<sha>` is this repo's
HEAD at copy time.

Baseline: <commit the corpus was cut from>. Design record:
<path to the module's DESIGN.md>.

## Identity-claim scope

State exactly which surfaces a passing snapshot suite proves unchanged,
in the shape "every fixture snapshots <the full artifact, named surface
by surface>". Then state the boundary in both directions:

- Downstream of <the seam the harness stops at> is a named residual
  risk, not a covered surface.
- A green suite proves the artifact bytes are unchanged. It is a
  necessary condition for behavioral neutrality, never a sufficient
  one; nothing downstream of the artifact is claimed.

## Covered surfaces

Every surface and branch of the artifact appears somewhere in this
manifest. It is either a covered row here, mapped to its fixture, or a
row under Exclusions below. A surface listed in neither place is a
manifest defect, not an implicit exclusion.

| Surface or branch | Fixture | Notes |
|---|---|---|
| <surface, e.g. preamble with a roster present> | `<fixture name>` | <anything a reviewer needs> |
| <branch, e.g. tool list empty vs populated> | `<fixture name>` | |

## Exclusions

The exclusion rows are where the value is: a manifest with only covered
rows is a table of contents. Every exclusion states either why the
surface needs no coverage or which other test owns it, by name. Excluded
rows are outside the identity claim.

| Surface excluded | Reason | Owning test (where one exists) |
|---|---|---|
| <surface> | <why no coverage is needed, or why it cannot be snapshotted> | `<test path::name>` |
| <re-stated surface> | re-stated in the harness, closing it is required work, not a nice-to-have | |

## Determinism constraints

Constraints the corpus data obeys so the snapshots stay stable. Each is a
row here, not a comment in a test.

| Constraint | Where it binds | Branch left to other coverage |
|---|---|---|
| <e.g. at most one hash-map entry per scenario> | <the surface that iterates it> | `<the non-snapshot test owning the multi-entry branch>` |

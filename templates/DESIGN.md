# <module> type design record

Template. Copy next to the module it describes, fill every section,
delete this line. Rules for the content: the `typed-holes` skill, mapped in `../PLAYBOOK.md`. When you copy
this file, record `copied from rust-holes@<sha>` in the copy, where
`<sha>` is this repo's HEAD at copy time.

Baseline: <commit or tag the skeleton was cut from>. Scope: <what this
record covers and what it does not>. Coverage ledger: <path to the golden
coverage manifest, if the module has one>.

## Type inventory

Every public type maps to one business rule and names the invalid state it
forbids. Mark types composed from elsewhere as (reused); do not re-model
what another module already forbids.

| Type | Business rule | Forbidden invalid state |
|---|---|---|
| `<Type>` | <the one rule this type encodes> | <the state that cannot be constructed> |
| `<Error>` | <what the error path may carry> | <unvalidated payload riding out through the error type> |
| `<Reused>` (reused) | <owning module's rule> | n/a (owned upstream) |

A type with no one-line rule is usually two types, or a bag with no
invariant. Split it before the panel does.

## Visibility and seam table

What this module reaches into, at what visibility, and how. Every widened
visibility and every test-only accessor is a row, with the reason.

| Item reached | Visibility at baseline | Decision |
|---|---|---|
| `<fn or type>` | `pub` | called directly |
| `<fn>` | `pub(crate)` | reachable because <reason> |
| `<fn>` | private | `#[cfg(test)] pub(crate) fn <name>_for_test` accessor; pure delegation, no test-only behavior |

State explicitly whether any production visibility was widened. "No
production visibility was widened" is the expected answer; anything else
needs its own justification row.

## Skeleton holes

| Hole | Marker | Filled by |
|---|---|---|
| `<module>::<fn>` | `#[expect(unused_variables, reason = "...")]` | <card, issue, or PR> |

Module-level `#![allow(dead_code)]`: <present or removed>, removal plan
<which slice removes it when>.

## Design panel findings

Numbered, one row per finding, each with its own disposition. Aggregate
counts are not a disposition.

| # | Reviewer | Finding | Disposition |
|---|---|---|---|
| 1 | adversarial | <invalid state still representable> | ACCEPTED: <the repair, and where it landed> |
| 2 | second-model | <logic or ordering error> | REJECTED: <why the finding does not hold> |

Author model: <model>. Panel seats: <adversarial reviewer>, <logic
reviewer>. Both differ from the author.

## Residual risks

Named risks the type surface does not close, each with the reason it is
accepted rather than repaired.

- <risk>: <why accepted, and what would catch it if it fired>

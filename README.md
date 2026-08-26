# rust-holes

**Private.** Do not publish this repository. It carries material derived
from private work; the public slice of this practice ships as the
`typed-holes` skill in claude-skills.

A Rust development practice: two layers of machine-tracked holes, filled
over time.

- **Layer 1, type-checked surface.** The full type surface lands first,
  with `todo!()` bodies, as its own commit that passes `cargo check` and
  `cargo clippy`. The compiler verifies the design composes before any
  behavior exists; a hole inventory tracks what is still missing, since
  `todo!()` type-checks anywhere.
- **Layer 2, test-runner-tracked.** Whole-frame golden tests, written
  pre-failing from the spec. The test runner tracks the rendering and
  semantics holes the compiler cannot see.

Between the two, a two-reviewer design panel on the skeleton commit, with
numbered per-finding dispositions.

## Read this in order

| File | What it is |
|---|---|
| `CONSUMING.md` | Start here if you are consuming this repo: access, prerequisites, the standalone and family paths. |
| `PLAYBOOK.md` | The map from the `typed-holes` skill's sections to the templates and examples here; the practice itself lives in the skill. |
| `templates/DESIGN.md` | The per-module type inventory, seam table, panel ledger, residual risks. |
| `templates/skeleton-conventions.md` | The per-module statement of how the skeleton rules were applied. |
| `templates/dispatch-brief.md` | Quote blocks for executors that do not load skills. |
| `templates/design-panel-prompts.md` | The two panel prompts, adversarial and second-model. |
| `templates/MANIFEST.md` | The golden coverage manifest: identity-claim scope, covered rows, exclusion rows with reasons. |
| `templates/golden-frame-harness.md` | The Layer 2 harness shape and starting skeletons. |
| `examples/approval-client-adt.md` | Layer 1 worked example: a small client's whole type surface. |
| `examples/golden-frame-harness.md` | Layer 2 worked example: harness layout, normalization, byte-identity mode. |
| `EXTRACTION.md` | Where every rule came from. |

Rules are stated once and cross-referenced. If a rule appears to be
missing, it is in the `typed-holes` skill.

## Using it

The playbook is repo-neutral. It assumes a Cargo workspace and nothing
else, with no board and no particular harness required. Copy the templates you
need into the target repo, or read the playbook and follow it.

Every template opens with a paragraph that begins `Template.`, says how
to instantiate it, and carries the copy-stamp instruction; a copy
records `copied from rust-holes@<sha>` so it can be diffed against
upstream later. `bin/check` verifies those headers, this file's
read-order table, every relative link, and the private notice above.

## How this composes

Three artifacts, each standalone, composed only through optional
references.

- **boardkit** (public) is the gated card board: schema, validator, views,
  review packets, process templates. It runs with zero Rust content. Its
  process template's type-discipline section is a stub that names the
  `typed-holes` skill if installed and degrades to "define your language's
  type discipline here" if not.
- **rust-holes** (this repo, private) holds the templates and worked
  examples; the practice itself lives in the `typed-holes` skill.
- **claude-skills** (public) is the glue. The `typed-holes` skill carries
  the generic practice and is self-sufficient for the workflow; this repo
  adds the templates and worked examples.

The contract in both directions:

- This repo names skills by bare backticked name (`rust-design`,
  `gate-probes`) and must keep working when they are absent. Where a rule
  would otherwise live only in a skill, it is stated inline here.
- Private material stays here. Nothing in the two public artifacts carries
  aura-derived exemplars, machine paths, host names, cost figures, or
  benchmark numbers. Same rule as boardkit's publish gates, applied in the
  opposite direction.

A board is not required. If one is present, the natural mapping is: the
skeleton is one card, each fill is another, the design panel is the
skeleton card's agent-review gate, and the coverage manifest is a
committed acceptance artifact.

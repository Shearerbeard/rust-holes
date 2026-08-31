# The typed-holes playbook

The canonical statement of the typed-holes practice is the `typed-holes`
skill. This file maps the skill's sections to the templates and worked
examples this repo holds; it states no rule of its own. If a rule seems
missing from a template, it is in the skill.

| Skill section | Supported here by |
|---|---|
| Layer 1: the typed-holes skeleton | `templates/dispatch-brief.md` skeleton block, `templates/DESIGN.md`, `templates/skeleton-conventions.md`, `examples/approval-client-adt.md` |
| The design panel | `templates/design-panel-prompts.md`; the panel ledger rows of `templates/DESIGN.md` |
| Layer 2: golden frames | `templates/golden-frame-harness.md`, `templates/MANIFEST.md`, `examples/golden-frame-harness.md` |
| Fill order | `templates/dispatch-brief.md` fill block |
| Known limits | the skill alone; `EXTRACTION.md` records the corrective duty when a limit fires |

## Repo-specific notes

Two things live here because the skill cannot hold them, each with the
reason.

- **Provenance.** `EXTRACTION.md` traces every rule to its aura source
  with a disposition and carries the re-grep tripwire. The skill stays
  repo-neutral and cites no sources, so the ledger stays here and drift
  is checked against the skill (its Standing obligations say how).
- **Clippy gate sequence.** Fill units run `-D warnings -A clippy::todo`
  while holes remain and the last fill unit drops the `-A`; the skill
  names the lint, this repo's fill block carries the flag sequence as
  executor wording.

# Cleanup execution: S45, S47, S4, S46

Status: gated execution plan, approved to run by Mike on 2026-08-25
("dispatch the work ... create a gated plan and go"). Executes the
Phase 1-3 cards from
[2026-08-23-second-dev-readiness.md](2026-08-23-second-dev-readiness.md)
under the cleanup framing recorded in boardkit drain 8. The cards own
scope and acceptance; this plan owns lanes, gates, and sequencing.

## Scope

- Core problem: four small pieces of rust-holes hygiene are carded
  and unstarted; drive them through their gates in one session.
- Audience: Mike at the two user gates; the executing and reviewing
  models at every other gate.
- Success: S45, S47, S4 at `done` with Gate A passed and acceptance
  re-run by the board owner; S46 at `in-review` with Gate A passed
  and its Gate U presented; the public skill sentence staged as a
  diff for the same stop; end-of-run intent validation and the
  orientation canary both passed and filed.
- Non-goals: anything on S26, S36, S39, S40; any doctrine change
  outside S4's five files; committing the public claude-skills edit
  before Mike sees it.

## Delegation inventory (session facts, per Mike's directive)

- Executor lane: opencode CLI, provider amazon-bedrock, model
  `deepseek.v3.2` (the only bedrock pin in the config), `--agent
  build` for write permission, cwd rust-holes, deadline 900s per
  dispatch, three-attempt cap. The executor makes no git operations
  and no board writes; the board owner commits.
- Gate A reviewer: codex CLI, read-only sandbox, `gpt-5.6-sol` per
  its run header. Reviewer differs from executor by family.
- End validation: codex sol plus opencode
  `baseten/deepseek-ai/DeepSeek-V4-Flash-0731`, both cold, both
  asked whether the delivered diffs match the plan's intent and each
  card's acceptance.
- Orientation canary at close: the flash lane above (board `canary`
  role resolves to opencode-reviewer).
- Pre-vet results are recorded in the Log below before the first
  dispatch; a lane that fails pre-vet defers its gate rather than
  being swapped silently.

## Verification

- Deterministic: `bin/check` (from S45 onward), `vale` on touched
  markdown, `boardkit render` + `boardkit check` after every board
  write, the no-model-id grep for S47, S4's divergence-site grep.
- Smoke: each card's own acceptance checks, re-run by the board
  owner before `done` (never on the executor's claim alone).
- Adversarial: Gate A on every card's commit range via
  `boardkit review-packet <id> --repo ~/dev/rust-holes
  --commit-range a..b`; numbered findings, per-finding dispositions
  on the card log; re-review on any BLOCKING finding, converging per
  the delegating-work rule.
- Intent: the end validation pair above, findings dispositioned
  here.

## Blast radius

- rust-holes: `bin/check`, template headers (stamp line),
  `README.md` (read-order rows, CONSUMING pointer, self-sufficiency
  claim), `templates/dispatch-brief.md` (class tags), `PLAYBOOK.md`
  (thinned), `EXTRACTION.md` (ledger note), new `CONSUMING.md`.
- boardkit: card status/log/commit-range on S45, S47, S4, S46;
  regenerated views; evidence files.
- claude-skills: one staged, uncommitted paragraph in
  `plugins/rust/skills/typed-holes/SKILL.md`.
- Building blocks reused: `boardkit dispatch-brief`, `boardkit
  review-packet`, the existing card gate checklists, the drain-8
  vetted sentence.

## Stages

Every stage follows the same loop: promote card, generate brief,
dispatch executor, Gate S by the board owner, commit with a `Card:`
trailer, Gate A by sol, disposition, close or stop.

### Stage 0: prerequisites

- Commit the pending drain in boardkit
  (`board(bk): drain 8 mints rust-holes cleanup cards (s45-s47)`).
- Commit the two plan docs in rust-holes
  (`docs(plans): second-dev readiness audit and cleanup execution
  plan`).
- Gates: S
- [ ] Gate S: `boardkit check` green; pre-vets recorded.
- Done when: both commits exist and every lane above answered its
  pre-vet.

### Stage 1: S45 self-check

- Gates: S → A
- [ ] Gate S: `bin/check` exits 0; five seeded defect classes each
  exit nonzero (runs recorded on the card); vale on touched
  markdown; gate-probes.
- [ ] Gate A: sol over the packet; dispositions on the card.
- Commit: `feat(check): add bin/check self-check and template
  provenance stamp` with `Card: S45`.
- Done when: card `done`, acceptance re-run by the board owner.

### Stage 2: S47 brief class tags

- Gates: S → A
- [ ] Gate S: `bin/check` green; grep proves no model id in
  `templates/`; the brief still instantiates by brackets alone.
- [ ] Gate A: sol; dispositions on the card.
- Commit: `docs(templates): tag dispatch-brief blocks with model
  classes` with `Card: S47`.
- Done when: card `done`.

### Stage 3: S4 doctrine authority

- Gates: S → A (per the card; rust-holes files only).
- [ ] Gate S: `bin/check` green; grep of the four divergence sites
  shows one owner each; never-publish header intact; vale.
- [ ] Gate A: sol, with the card's focus (any rule dropped with no
  home in the skill?) plus the no-skill-executor probe from the
  readiness plan's ledger (C3).
- Commit: `docs(playbook): point doctrine at the typed-holes skill,
  keep templates and ledger` with `Card: S4`.
- Also staged, not committed: the vetted §6a sentence in
  claude-skills `typed-holes/SKILL.md` (drain 8, item 5), reviewed
  by sol in the end validation and presented at the Stage 4 stop.
- Done when: card `done`; the skill diff is staged for Mike.

### Stage 4: S46 CONSUMING.md 🛑 USER GATE

- Gates: S → A → U(acceptance)
- [ ] Gate S: `bin/check` green (README pointer row present); vale;
  `docs-bustest` scorecard recorded.
- [ ] Gate A: sol, focus: what would a cold reader still have to ask
  Mike; anything restated from a file that owns it.
- [ ] Gate U: Mike reads the page as the second developer would.
  Presented together with the S4 skill diff. 🛑
- Commit: `docs: add CONSUMING.md onboarding page` with `Card: S46`.
- Done when: card at `in-review` with Gate A passed; the stop is
  presented.

### Stage 5: intent validation and close

- [ ] Gate M: sol and flash each read the readiness plan, this plan,
  and `git diff 410fa0c..HEAD` in rust-holes, and answer whether the
  delivered work matches the plan's intent and each card's
  acceptance; numbered findings, explicit verdicts, dispositioned in
  the Log below.
- [ ] Board hygiene: `boardkit render` + `check`, orientation canary
  on the flash lane graded against `boardkit canary-key`, evidence
  filed and linked, board commits landed.
- Done when: both validations and the canary are filed as PASS, or
  every finding is dispositioned and the residue is named at the
  Stage 4 stop.

## Rollback

Each card is one commit in rust-holes with a `Card:` trailer;
`git revert` of that commit plus a card log line restores the prior
state. The claude-skills change is never committed by this plan.

## Log

- 2026-08-25 Plan written; pre-vets running.
- 2026-08-25 Pre-vets: codex answered as `gpt-5.6-sol`; the bedrock
  executor answered a nonce and wrote a file from outside the repo,
  and returned nothing from inside the rust-holes checkout path
  (opencode refuses that path with a stale project record), so every
  executor dispatch runs from a git worktree of rust-holes in the
  session scratchpad. Stage 0 commits landed: boardkit `fbdc88e`,
  rust-holes `a2b3f2e`.
- 2026-08-25 S45 executor attempts 1 and 2 stalled with zero output;
  cause: the headless build agent has no bash permission, so the
  first shell step blocks on an unanswered prompt. All later
  dispatches are write-only and the board owner runs every check.
  Attempt 3 and a second write-only dispatch landed S45's work.
- 2026-08-26 S45: Gate A round 1 FAIL (6 findings), round 2 FAIL (4
  findings, two incomplete fixes and two fix regressions), all
  repaired by the board owner with one harness seed per finding;
  round 3 dispatched. S47: round 1 FAIL (3 findings, taxonomy names),
  repaired; round 2 PASS; done. S4: executor output repaired for
  scope (two out-of-scope templates reverted) and duplication (the
  verbatim Known limits copy removed); Gate A PASS, zero findings;
  done. S46 dispatched. The claude-skills sentence is staged,
  uncommitted, for the Stage 4 stop.
- 2026-08-26 S45: round 3 FAIL (2, in-cycle) took the board-owner
  ruling CONTINUE; round 4 FAIL (1 regression, tab and bare ATX
  headings) is fixed and seeded in `32d7eac` but, per that ruling,
  escalates to Mike instead of a fifth round; Gate A stays open on
  S45 with the recommendation recorded on the card. S46: page landed
  in `b2f57aa`, bus test 18/24 with no P1 filed as evidence, Gate A
  round 1 FAIL (4, ownership and circularity) repaired in `264bbe1`,
  round 2 dispatched. Harness stands at 18 failing seeds plus one
  must-pass case.
- 2026-08-26 Close. S46 Gate A PASS at round 3 (`f0d843d`). Intent
  validation: flash lane PASS with four minor notes; sol lane FAIL on
  five acceptance-grounded findings, dispositioned in boardkit
  `docs/board/evidence/2026-08-26-cleanup-close.md`. Consequences
  applied: S4 reopened to in-review (README still said "read the
  playbook", four templates still named PLAYBOOK as the rules home);
  S47's cost-plan boxes ticked in the aura board note (uncommitted in
  the wiki checkout); the S45 "half-filled" seed equivalence stated on
  its card. Staged uncommitted in this repo for Mike's stop: the
  README "Using it" line, the template pointer fixes (a scope
  extension past S4's five files), and CONSUMING's line on how to
  read the skill. Closing canary 4/4. Stops presented: S46 Gate U, S45
  Gate A escalation, S4 reopen with its staged fix, the claude-skills
  sentence, and the bus-test P2s.
- 2026-08-29 Stop resolutions (Mike): the boundary observation on the
  doctrine home was accepted as-is and queued to boardkit's
  FEEDBACK.md for a revisit once the family goes public. The staged
  fixes landed: S4's pointer fixes as `2d0a22b` (scope extended to
  the four templates at the stop) plus the re-review repair
  `bcfce58`; S46's skill-path line as `f650b82`. Both took codex
  re-reviews to an explicit PASS (S4 in two rounds). The
  claude-skills sentence committed there as `16116ea`. S45's
  escalation was accepted. Cards S4, S45, and S46 are done on the
  board (`01dd8eb`); the residual bus-test P2s went to FEEDBACK.md
  as proposals.

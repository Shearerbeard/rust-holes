# Second-developer readiness: audit and phased plan

Status: revision 3, post-drain. The audit ran, two adversarial
reviews graded revision 1 (both round-1 FAIL, all 23 findings
dispositioned in the Review ledger below), and Mike directed the
drain on 2026-08-23 with the framing that governs the final shape:
cleanup and minor tweaks for a system the program has very little
issue with. Dispositions live in boardkit
`docs/plans/2026-08-23-feedback-drain-8.md`; the adopted work is
minted as boardkit cards S45, S46, S47 alongside the existing S4,
S26, S36. The draft cards this plan once carried under
`docs/plans/cards/` are superseded by the minted cards and removed.
Author: claude-fable-5.

## Audit findings

Each finding is numbered and carries its evidence. Positive findings
are recorded too; an audit that lists only defects is a defect list,
not an audit.

1. **Consumption is manual and unverified.** The stated model is "copy
   the templates you need into the target repo" (`README.md`, "Using
   it"). Nothing versions a copy, detects drift in a consumer, or
   checks this repo's own integrity: no check script, no CI, no git
   tags, two commits total.
2. **A second developer cannot discover this repo from anything
   shipped.** The public `typed-holes` skill deliberately names only "a
   private companion repo" with no name or location
   (claude-skills `plugins/rust/skills/typed-holes/SKILL.md:42-44`), a
   publish-safety decision. The only pointers live in machine-local,
   git-excluded files (the aura `AGENTS.md` two-kits section, wiki
   event `019ff2dc`: "interim pointer until dotname-docking ships") and
   in the wiki's board `PROCESS.md`. There is no onboarding document,
   and the repo's clone URL and access path (private GitHub, default
   branch `master`) appear in no operational doc - the same gap
   boardkit's spread-readiness review found for boardkit itself (S40).
3. **Doctrine authority is contested in the shipped files.** This
   repo's `README.md` claims "Every rule is stated here, once"; the
   skill claims "Everything needed to run the practice is in this
   skill"; a claude-skills retro (gitignored,
   `feedback/2026-07-28-.../skill-retro.md` §6a) drafted the
   resolution - skill canonical, companion derivative - and it was
   never applied; a later feedback entry
   (`feedback/2026-08-09-opencode-hole-inventory-drift/`) asserts the
   opposite ownership. Boardkit card **S4** (status `ready`) resolves
   this in the skill's favor and names four recorded divergences.
   Until S4 runs, every doctrine edit risks widening a fork that
   already exists.
4. **The repo cannot verify itself.** Relative links are unchecked,
   template integrity is unchecked, and no code path ever instantiates
   the templates - even though this repo's own `FEEDBACK.md` names "a
   template that did not instantiate cleanly" as a first-class failure
   signal. Concrete instance found by this audit: the `README.md`
   "Read this in order" table omits `templates/MANIFEST.md` and
   `templates/golden-frame-harness.md`, both added in commit `410fa0c`.
5. **The hole inventory is a convention line, not a check.** Boardkit
   card **S26** (status `ready`) records it: "an unowned hole passes
   every gate silently"; chore-lottery S5's Gate A caught exactly that
   shape once, and it took a human adversarial reviewer.
6. **Docking is the accepted discoverability fix, unblocked and
   unstarted.** Card **S36** (status `backlog`, depends S31 which is
   done, member of epic S41) has rust-holes adopt the docking spec
   (`boardkit docs/DOCKING.md`, spec v1) as its second consumer.
   Divergence from the spec is the recorded trigger for extracting the
   resolver into a shared library.
7. **The second-developer goal already has an owner.** Boardkit epic
   **S41** ("co-worker consumption readiness") defines acceptance as a
   seven-step scenario ending "No lifeline: the run completes without
   asking Mike anything." Two of its gaps are off-repo and gate
   rust-holes exactly as hard as boardkit: **S39** (no machine
   bootstrap recipe) and **S40** (no clone URL / kit-developer path).
   Both are `ready` and unstarted on boardkit's board.
8. **The dispatch brief carries no model-class tags.** The PLAYBOOK's
   Delegating section already states the split in prose ("a stronger
   model lays the type surface, smaller models fill bodies against
   green-when-done criteria"), but `templates/dispatch-brief.md` - the
   artifact an executor actually receives - carries no class tag on
   either brief block. Two items in the aura board's executor cost
   plan (2026-08-05) track this; the overspend that plan diagnosed
   traced to ignoring exactly that split. (Revised after review: the
   original wording overstated the gap as "missing guidance"; the
   prose exists, the template tags do not. Reviewer finding C5.)
9. **What already works, and must not be regressed.** The extraction
   discipline is exemplary (`EXTRACTION.md`: per-rule provenance with
   dispositions). The feedback loop is real and exercised (boardkit
   drain 7 processed an entry routed by this repo's `FEEDBACK.md`).
   The practice is proven in live consumption on two boards (aura
   P15-P17 skeleton/fill cards; chore-lottery as first external
   consumer) and the review machinery bites (a recorded design panel
   returned two FAIL verdicts, 12 blocking findings). The composition
   contract - three standalone artifacts, optional references - held
   in practice and is the right shape; this plan strengthens the
   references, it does not couple the artifacts.

## Phased plan (post-drain)

Success, under the cleanup framing: the repo verifies itself, the
doctrine has one owner, and a second developer with access orients
from one shipped page. The heavyweight proof machinery the earlier
revision staged is rejected or deferred; chore-lottery remains the
live external proof of the practice. Each phase names its boardkit
cards; the cards carry the scope, acceptance, and gates, and this
plan does not restate them.

### Phase 1: mechanical cleanup (S45, then S47)

No user gates; both are small external-repo cards, gates `S -> A`.

- **S45** - `bin/check` self-check, the template provenance-stamp
  line, and the known README read-order fix (finding 4). Lands the
  check every later gate runs.
- **S47** - model-class tags on the two dispatch-brief blocks
  (finding 8). Serialized with S4 because both touch
  `templates/dispatch-brief.md`; whichever is pulled first, they do
  not run concurrently.

Done when both cards close with their acceptance runs recorded and
`bin/check` exits 0 on this repo.

### Phase 2: authority cleanup (S4, plus the vetted sentence) 🛑

- **S4, as written** - PLAYBOOK thins, four divergences reconciled,
  README self-sufficiency claim updated, EXTRACTION ledger note.
  Rust-holes files only, gates `S -> A` per the card.
- **The skill-canonical sentence** - one paragraph added to the
  public `typed-holes` SKILL.md, from retro §6a as vetted at drain 8
  (record, item 5). Outside S4's scope by design; the public diff is
  shown to Mike before it lands. 🛑 USER GATE (the plan's one public
  edit).

Done when S4's acceptance holds and both repos state the same
authority direction.

### Phase 3: onboarding page (S46) 🛑

- **S46** - `CONSUMING.md`, one lean page (finding 2), depends S4.
  Gate U: Mike reads it as the second developer would. 🛑 USER GATE.

Done when the card's behavioral acceptance holds: a cold reader can
state access, read order, verification, and the friction route from
this file alone, with every remaining ask-Mike step named.

### Phase 4: board-paced, not blocking

Existing cards proceed at the board's own pace; under the cleanup
framing neither blocks a second developer, and this plan adds nothing
to them.

- **S26** - HOLES ledger and hook-grade check (finding 5).
- **S36** - docking adoption (finding 6); retires the machine-local
  interim pointer and owns the one-line resolution update to
  `CONSUMING.md` when it lands.
- **S39 / S40** - boardkit-side bootstrap and clone-path gaps
  (finding 7); S41's sequencing call, tracked there.

### Rejected at the drain

- **RH2** (smoke crate, cold-run canary, Gate T handout): over-scoped
  for current pain; chore-lottery is the standing live consumer and
  Gate T venue. Re-propose when a real second-developer onboarding is
  scheduled; the exercise-branch mechanism is preserved in the drain
  record (item 4) for that day.

### Rollback

Every phase is additive files or reviewed edits in a small repo;
`git revert` restores the prior state. The Phase 2 public sentence is
one paragraph: revert it in claude-skills and note the revert on S4's
Log so the two repos' authority statements do not silently diverge
again.

## Review ledger

Round 1, 2026-08-23, against revision 1. Reviewers: codex
`gpt-5.6-sol` (C1-C10, verdict FAIL) and opencode
`baseten/moonshotai/Kimi-K3` (K1-K13, verdict FAIL). Every finding
carries its own disposition. K3's review also re-verified audit
findings 1, 3, 4, 5, 6 against the staged ground truth and confirmed
them.

**Post-drain deltas** (maintainer decisions at drain 8 that supersede
three revision 2 dispositions; the drain record is the durable
authority):

- K3's accepted resequencing (onboarding after docking) is reversed:
  the doc lands in Phase 3 documenting current state, and S36 owns
  the resolution touch-up (drain record, item 3).
- C7/K4/K11's accepted exercise-branch and revert repairs now attach
  to a rejected card; they are preserved in the drain record (item 4)
  for RH2's future re-proposal.
- C8/K6's two-tier success criterion collapses to the cleanup-framed
  success above; the full no-lifeline run rides S41, where it always
  lived.

| # | Finding (compressed) | Disposition |
|---|---|---|
| C1 | Stage 2 exceeded S4's written scope (public SKILL.md edit, added Gate U) | ACCEPTED: S4 runs as written; skill edit split out with its own user gate (now Phase 2) |
| C2 | S36 vale gate weakened; "no stored-link fragility" untestable; S31 spec absent from packet | ACCEPTED: vale unconditional and three named resolution fixtures recorded for S36's executor; DOCKING.md staged into its packet |
| C3 | S4 makes the skill the doctrine owner while the plan claims standalone artifacts; skill-absent path never tested | PARTIAL: a no-skill-executor probe added to S4's Gate A focus (the brief quote blocks stay self-contained). "Revise S4 first" REJECTED: S4 is the maintainer's minted disposition and its own acceptance updates the standalone claim |
| C4 | CONSUMING.md treats a boardkit checkout as assumed though boardkit is optional | ACCEPTED: S46 documents the standalone (no-boardkit) path first-class |
| C5 | Audit finding 8 overstated: PLAYBOOK already states the model-class split | ACCEPTED: finding 8 reworded; S47 narrowed to the template tags only |
| C6 | Later stages run on provisional RH ids before maintainer adoption | ACCEPTED: the drain sitting preceded execution; ids minted as S45/S46/S47 |
| C7 | Handout needs a pre-fill starting state; committed crate is green | ACCEPTED, then card rejected at drain: repair preserved in drain record item 4 |
| C8 | Success overclaims full second-dev readiness; simulated Gate T conceals gaps | ACCEPTED: success narrowed; the full claim rides S41 (see post-drain deltas) |
| C9 | Consumer-side drift (audit finding 1) had no stage | ACCEPTED, scoped: provenance stamp in S45, re-diff recipe in S46; consumer-side tooling deferred on the extract-on-divergence rule |
| C10 | "Defensible yes" and "no stored-link fragility" are opinions | ACCEPTED: S46's done-when is its behavioral acceptance; S36's fixtures are named runs |
| K1 | Same as C1 | ACCEPTED: same repair as C1 |
| K2 | Post-S4, RH4's Delegating edit becomes a second ungated public edit or a re-fork | ACCEPTED: S47 is template-only; doctrine guidance routes to the section's post-S4 owner |
| K3 | Onboarding doc written against the interim discovery state, invalidated by docking | ACCEPTED at revision 2; REVERSED at drain 8 (see post-drain deltas) |
| K4 | Green-at-Gate-S contradicts red-golden-at-Gate-T; mechanism unstated | ACCEPTED, then card rejected at drain: mechanism preserved in drain record item 4 |
| K5 | Stage 5 dropped the card's own check run; HOLES.md would trip the read-order rule; S36 vale narrowed | ACCEPTED: cards' gates run as written; the read-order rule note travels to S26's executor via this ledger |
| K6 | Discovery path never exercised cold; Gate T passable by simulation despite the Success claim | ACCEPTED in substance: success narrowed; the CONSUMING-manifest canary idea is preserved with RH2's rejection record |
| K7 | Stage 3 Done-when weaker than its own card's acceptance | ACCEPTED: the card's behavioral acceptance is the done-when |
| K8 | Consumer-copy verification neither staged nor excluded with a reason | ACCEPTED: same repair as C9; the deferral reason is recorded in the phased plan |
| K9 | "Companion-canonical" wording inverts the resolution; the public sentence never quoted, so publish-safety unverifiable | ACCEPTED: renamed skill-canonical; the sentence is quoted and vetted in drain record item 5 |
| K10 | Retro vet has no owner, trigger, or schedule | ACCEPTED: the drain sitting vetted §6a (drain record, item 5) |
| K11 | `git checkout -- smoke/` reverts neither commits nor untracked files | ACCEPTED, then card rejected at drain: corrected revert preserved in drain record item 4 |
| K12 | Gate letters M/T may not exist in boardkit's vocabulary | REJECTED: boardkit `docs/board/PROCESS.md:308` defines Gate M (manual) and `:334` Gate T (user testing); the frontmatter `gates` field is a free-form order string per `_template.md:84` |
| K13 | CONSUMING.md scoped no environment prerequisites (Rust 1.81+, nightly fmt, insta, panel model access) | ACCEPTED: prerequisites section is in S46's deliverable |

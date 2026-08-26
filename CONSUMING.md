# Consuming the rust-holes repo

Start here if you consume this repo rather than maintain it. The
practice itself is the public `typed-holes` skill; this repo holds the
templates and worked examples behind it.

## Access

The repo is private on GitHub at `Shearerbeard/rust-holes`, default
branch `master`, granted per collaborator. Once granted:

```
git clone git@github.com:Shearerbeard/rust-holes.git
```

It is never published, and nothing derived from it goes into a public
repo; `EXTRACTION.md` states that boundary and what it covers.

## Prerequisites

- Rust 1.81 or newer, for `#[expect]`.
- `cargo fmt --check`; a nightly toolchain only where your repo pins
  nightly rustfmt options.
- The `insta` crate, for golden frames.
- Python 3, for `bin/check`.
- For the design panel, access to two model families, so a reviewer
  never shares a family with the author.

## The standalone path

With no boardkit checkout and no skills installed:

1. Clone, then run `bin/check`; it exits 0 on a healthy checkout.
2. Read the files in the order the table in [README.md](README.md)
   gives.
3. Copy the templates you need into your repo.
4. Give executors that load no skills the quote blocks from
   [`templates/dispatch-brief.md`](templates/dispatch-brief.md).
5. Keep friction in your own log, as [`FEEDBACK.md`](FEEDBACK.md) says.

## The family path

With a boardkit checkout beside this one:

1. Export `BOARDKIT_HOME` on its own line before any `uv run` line.
2. Route practice-relevant friction to
   `${BOARDKIT_HOME:-../boardkit}/FEEDBACK.md`, as
   [`FEEDBACK.md`](FEEDBACK.md) here says.
3. Follow the family commit standard: a conventional lowercase subject,
   and no sign-off or AI-attribution trailers. Agent harnesses add those
   by default and have to be told not to.

## What is discoverable from where

- The public `typed-holes` skill is the canonical statement of the
  practice and deliberately does not name this repo.
- This repo holds the templates and worked examples; `PLAYBOOK.md` maps
  the skill's sections to them.
- A boardkit board, where one exists, tracks the cards; this repo has no
  board of its own.

## Copying templates

Each template's opening paragraph tells you to record `copied from
rust-holes@<sha>` in the copy. To see what changed upstream since, run
`git diff <sha>..HEAD -- templates/<file>` in this repo.

## Ask Mike

The steps this page cannot answer:

- The collaborator grant itself.
- A machine bootstrap recipe for boardkit (its card S39).
- The kit's clone path (its card S40).

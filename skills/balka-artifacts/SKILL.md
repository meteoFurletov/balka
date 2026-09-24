---
name: balka-artifacts
description: Use when writing or updating an SDLC artefact — intent.md, spec.md, plan.md, a Gherkin .feature file, the facts document or PROPOSALS.md — in a repo carrying .claude/balka.json, and no /balka command was typed. Covers the house rules those artefacts must follow (read the facts document first, link upstream instead of restating it, name one owner, size by scope not by cutting, scenarios and their Then assertions change only at the design transition), the status vocabulary, and where the shipped templates live so a command can find them. Triggers include "write the intent for this", "turn that into a spec", "add a scenario", "update the plan", "split this intent", "park this", "what should the spec say", "add this name to the estate". Do NOT use for ordinary READMEs or design docs outside the loop.
---

# SDLC artefacts

This repo runs the six-stage loop. When someone asks for one of its artefacts in
prose rather than through `/balka:<stage>`, the rules below still apply.

Read `.claude/balka.json` at the git root for `artifactDir`, `scenarioGlobs` and
`facts`. No such file means the repo has not opted in — write what was asked for
and skip the rest of this.

Prefer the command where one fits. `/balka:intent`, `:spec` and `:plan`
carry the whole transition including the acceptance step. This skill is for the
times nobody typed one.

## Where the templates are

The plugin's templates are at `${CLAUDE_PLUGIN_ROOT}/templates/`.

```
templates/
  intent.md                 Stage 1
  spec.md                   Stage 2
  scenario.feature          Stage 2, one per capability
  plan.md                   Stage 3
  estate.md                 the facts document init writes
  PROPOSALS.md              the reflect inbox init writes
  AGENTS.md                 the starter block init merges into the project
  REVIEW.md                 the pointer at the review policy
  copilot-instructions.md   the review policy Copilot applies to every PR
  bands.yaml                Stage 6 detection bands
  balka.json                 the opt-in marker
  balka-watch.yml            the scheduled detector workflow
```

Never reconstruct a template from memory. Re-deriving it by hand in each repo is
exactly the drift this plugin exists to stop.

## The rules

**Read the facts document first.** Every name in an artefact — system, repo,
table, service, person — is spelled the way that file spells it. A name the
file does not have is asked for and added there before it is used. A correction
that has landed in chat twice goes to `<artifactDir>/PROPOSALS.md` once.

**Link upstream, never restate it.** `spec.md` opens by pointing at `intent.md`
and adds only what is new. `plan.md` points at both. A summary of an upstream
artefact is a second copy that will drift — cite the file instead.

**Size by scope, not by cutting.** One change is one capability, one or two
`.feature` files. The budgets — about 60 lines for an intent, 120 for a spec,
100 for a plan — are signals: a draft over one is reported, not trimmed. An
intent that needs more than about eight behaviours is a programme and is split
into children, parent kept with `Status: split`.

**Name a real owner.** Every artefact carries `Owner:` — the one person who
accepts it and moves the work on. If you do not know who, ask.

**Status is one word** from: draft, accepted, split, parked, rejected, built. A
parked or rejected artefact carries one line saying why and is never deleted.

**Git is the history.** Artefacts and scenarios change in place. Never delete
and recreate, rename or copy a file to get past a hook or a rule: the history
lives in git, and a workaround erases it. When balka's own rules leave no other
route, that is a bug in balka: stop, tell the owner, and record it in
`PROPOSALS.md` for `/balka:reflect`.

**Scenarios are the contract.** `.feature` files and the `Then` assertions in
their bindings change at the design transition — while the change's `spec.md`
is in draft — and nowhere else, edited in place. Two hooks hold that: one
blocks an edit, deletion or rename of an existing `.feature` file outside the
design transition, one blocks a commit that moves a `.feature` file without a
`spec.md`. New behaviour
gets a new scenario at the design transition — never during Build, and never
edited to match what the code turned out to do. Binding glue, unit tests and
fixtures are the opposite: implementation detail, free to churn, and never
evidence on their own that a scenario holds.

**Gherkin in production's words.** Every noun is a real name. A scenario the
owner cannot read without a glossary is a finding against the scenario.

**A change with no scenarios is first class.** Refactors, dependency bumps and
performance work say "No scenario changes. The existing scenarios must still
pass." and that is the whole requirement on them.

## Layout

Artefacts live one directory per change: `<artifactDir>/<NNN>-<slug>/`. A
change lives on one branch, usually in its own worktree, with one main agent.
There is no pointer to an active change: several are in flight at once, and
each file's `Status:` line is the only state. A number comes from
`scripts/claim.sh next`, never by hand — the claim is what stops two agents
sharing a change. `plan-sync` measures a commit against whichever accepted plan
covers it.

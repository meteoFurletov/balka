---
description: Stage 4, Test — run the verify commands once more in a fresh context, then a verifier that did not write the code checks spec, scenarios, bindings and code against each other. Produces a fix or a stop, never a file.
argument-hint: [optional — the change directory to test]
allowed-tools: Read, Glob, Grep, Bash, Agent, Skill
---

Test the change: $ARGUMENTS

If that is empty, it is the change directory this branch has added or touched
since it left the default branch: `git diff --name-only "$(git merge-base HEAD
origin/HEAD)" -- <artifactDir>` plus untracked files there (use the default
branch when there is no remote). If that is not exactly one, list the
candidates and ask.

## Before anything

Read `.claude/balka.json` at the git root, falling back to the legacy
`.claude/sdlc.json` when the modern file is absent. Use that selected config's
paths, facts, and verification settings throughout this stage; do not migrate
it implicitly. Only if neither file exists, say that the repo has not run
`/balka:init` and its hooks are inert, then continue with `artifactDir: docs/balka`,
`scenarioGlobs: ["features/**/*.feature"]` and no facts document.

Artefacts live one directory per change: `<artifactDir>/<NNN>-<slug>/`. A
change lives on one branch, usually in its own worktree, with one main agent;
several can be in flight at once. Take the date from `date +%F`, never from your
own sense of today.

Read the facts document named by `facts` before drafting a word. It holds the
estate's real names and the facts the code does not say; a draft that spells a
system, repo or table differently from that file is wrong before the owner reads
it. If a name you need is missing there, ask, and add it there first.

After the facts document, follow the documentation pointers in `AGENTS.md` to
discover task-relevant current guidance and apply its writing policy. If the
pointers or policy are absent, load `documentation-writing.md` through the
template route below and discover the existing layout. Init is not a
prerequisite for continuing.

## Loading a template

Read `${CLAUDE_PLUGIN_ROOT}/templates/<name>`. If that path does not exist, fall
back to the install path from
`jq -r '(.plugins // .) | to_entries[]|select(.key|startswith("balka@"))|.value[0].installPath' ~/.claude/plugins/installed_plugins.json`
plus `/templates/<name>`. If both fail, say so and stop. Never write a template
from memory — re-deriving it by hand is the drift this plugin exists to stop.

## First, the feedback loop's last word

Run every command in the `verify` block, or the commands verified for this
session when no config exists. Red here goes straight back to Build:
say what failed and follow `${CLAUDE_PLUGIN_ROOT}/commands/build.md` until it is
green, then come back here. Green here is necessary, not sufficient.

## Then the verifier

Spawn one subagent with a fresh context — one that did not write the code — and
give it the paths of `spec.md`, `plan.md`, the `.feature` files the plan proves,
their bindings, the git ref of the design commit (the last commit that changed
this change's `spec.md`), and the diff since. Include the entry instructions,
facts document, writing policy, relevant current documents, and their
implementation/evidence references, including inherited guidance needed to
understand or use the change. It reads, runs nothing, and reports
findings ranked by severity, or says clearly that it found none. Its checks:

1. **Spec against scenarios.** Every requirement has a scenario that exercises
   it, or the spec says in one line why it needs none. No two scenarios
   contradict each other.
2. **Scenarios against bindings.** Each `Then` step asserts the observable
   result the scenario states, not that code ran. Diff the bindings against the
   design commit: an assertion that was weakened, removed or made vacuous since
   then is the highest-severity finding there is.
3. **Code against spec.** For each requirement, the code that satisfies it,
   named. Logic a requirement demands and the code lacks is a finding. Anything
   under Non-goals that landed is a finding.
4. **Plan against reality.** Files touched but absent from the plan's list and
   its Departures.
5. **Documentation against evidence.** Apply the writing policy. Trace usable
   references from the entry instructions to the relevant knowledge and its
   authoritative sources. Check explanations and procedures against the
   accepted contract and implementation, including relevant inherited guidance.
   Missing knowledge, misleading or conflicting accounts, broken discovery
   references, and unsupported runtime claims are findings. Check the plan's
   no-update explanation when one exists. Status, recency, metadata, and green
   tests alone do not establish semantic correctness. A correctly stated lack
   of production observation is acceptable; do not require a live rollout or
   an unrelated documentation audit to establish that the change is built.

Where scenarios have no runner or bindings, walk their acceptance examples
against the implementation and instructions manually. State that this is a
manual review; do not present it as executed agent behavior or passing Gherkin.

## What happens with findings

Nothing is written for a person to read: a finding is either fixed or it stops
the loop.

- A finding in the code, binding glue, or current documentation goes back to Build:
  correct it within the accepted contract, run the
  verify commands green, and run the verifier again. Two rounds is normal; a
  third with the same finding means the plan is wrong — stop and say so.
- A finding against a scenario, an assertion or the spec stops here. Print it
  and say it needs the owner and `/balka:spec`.

Use the second route when a documentation finding exposes a contract
disagreement. Do not rewrite the requirement to match newer prose or code.
Resolve findings in the affected knowledge before marking the change built;
unrelated debt can use the project's existing reporting mechanism.

When the verifier is clean, replace `Status: accepted` with `Status: built` in
`plan.md`'s header, commit it, and say so. Keep one authoritative status; the
board and hooks read the header. Then ask "Continue to deploy now?". On yes,
read `${CLAUDE_PLUGIN_ROOT}/commands/deploy.md` and follow it in this session.
On no, stop.

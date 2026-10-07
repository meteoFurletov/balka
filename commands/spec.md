---
description: Stage 2, Design — turn an accepted intent.md into spec.md, the Gherkin .feature files that are the contract, and their bindings written red.
argument-hint: [optional — the change directory to work in]
allowed-tools: Read, Write, Glob, Grep, Bash(date:*), Bash(jq:*), Bash(git status:*), Bash(git diff:*), Bash(git merge-base:*), Bash(git add:*), Bash(git commit:*), Bash(ls:*), Skill, AskUserQuestion
---

Write `spec.md`, its `.feature` files and their bindings. Change: $ARGUMENTS

If that is empty, it is the change directory this branch has added or touched
since it left the default branch: `git diff --name-only "$(git merge-base HEAD
origin/HEAD)" -- <artifactDir>` plus untracked files there (use the default
branch when there is no remote). If that is not exactly one, list the
candidates and ask.

Then check the claim: `bash "${CLAUDE_PLUGIN_ROOT}/scripts/claim.sh" check <artifactDir> <NNN>-<slug>`.
Exit 3 means another agent holds this change: say who, from its message, and
stop. One change, one main agent.

## Before anything

Read `.claude/balka.json` at the git root. If it is absent, say that this repo has
not run `/balka:init` and that the hooks are inert here, then continue with
the defaults `artifactDir: docs/balka`, `scenarioGlobs: ["features/**/*.feature"]`
and no facts document.

Artefacts live one directory per change: `<artifactDir>/<NNN>-<slug>/`. A
change lives on one branch, usually in its own worktree, with one main agent;
several can be in flight at once. Take the date from `date +%F`, never from your
own sense of today.

Read the facts document named by `facts` before drafting a word. It holds the
estate's real names and the facts the code does not say; a draft that spells a
system, repo or table differently from that file is wrong before the owner reads
it. If a name you need is missing there, ask, and add it there first.

## Loading a template

Read `${CLAUDE_PLUGIN_ROOT}/templates/<name>`. If that path does not exist, fall
back to the install path from
`jq -r '(.plugins // .) | to_entries[]|select(.key|startswith("balka@"))|.value[0].installPath' ~/.claude/plugins/installed_plugins.json`
plus `/templates/<name>`. If both fail, say so and stop. Never write a template
from memory — re-deriving it by hand is the drift this plugin exists to stop.

## Writing it

**Open the design transition first.** Before touching any `.feature` file,
write `spec.md` from its template with `Status: draft`. A draft spec is what
tells the hooks the contract may move, so it is the one thing written before
the owner has read it. It closes when the owner accepts.

Read the change's `intent.md`. If it is missing, or its status is not
`accepted`, say so and stop — a spec written against an unaccepted intent
specifies something nobody agreed to. A `split` parent is never specced; work in
its children.

If its Open questions are not "None outstanding", say so before writing anything
and ask whether to proceed or wait.

**Link upstream, never restate it.** Problem and outcome live in the intent.
`spec.md` opens by pointing at it and then adds only what is new: requirements,
constraints, design, non-goals, acceptance. If you catch yourself summarising
the intent, delete the summary and cite the file.

**Constraints** live here, not in the intent: the systems, names, limits and
policies the design must respect. Take names from the facts document.

**The scenarios are the point of this transition.** Turn each plain-words
behaviour from the intent into Gherkin in a `.feature` file committed alongside:

- One `Feature` per capability, named for the capability and not the
  implementation. One action per `When`, an observable result per `Then`.
- Every noun is a real name from the facts document or the estate. A scenario
  the owner cannot read without a glossary is a finding against the scenario,
  not the owner: rewrite it in production's words.
- Aim for one or two `.feature` files per change, about eight scenarios each.
  More scenarios than that are usually examples of one behaviour, not more
  behaviours: fold them into a `Scenario Outline`, or take the surplus back to
  the intent as a split.
- If a behaviour will not go into Given/When/Then without inventing detail, that
  is a finding — take it back to the owner, do not guess.
- Where the intent declares no scenario changes, record that in `spec.md`, write
  no `.feature` file, and note the existing scenarios must still pass.

**Write every step to be read.** The owner reads every scenario in full, so
write them about 80% of the way to ASD-STE100, the Simplified Technical English
of aircraft maintenance manuals. Keep these rules:

- One word, one meaning. Call a thing by the same name in every step and every
  scenario. Never change the word for variety.
- One idea per step. If a step needs "and", "which" or "so that", make it two
  steps.
- Short steps: about 15 words, and about 10 in a scenario name.
- Active voice, present tense. Name who acts: "the scheduler sends the report",
  not "the report is sent".
- Keep the articles. A step is a sentence, not a note: "the order has the status
  shipped", not "order status shipped".
- No more than three nouns in a row: "the retry limit of the export", not "the
  export job retry count limit".
- Concrete values: "3 failed logins", not "several failed logins"; "within 5
  minutes", not "promptly".
- Plain verbs that say what changes: send, show, stop, keep. Not handle,
  process, manage or leverage.
- At most one "not" in a step, and never two negatives.

Where this is softer than ASD-STE100: the facts document is the dictionary, not
the STE word list; the word counts are aims, not limits; a term the owner uses
every day stays even if STE has no entry for it.

```gherkin
# Hard to read
Scenario: Handling of retry exhaustion for failed exports
  Given an export job configured with max retries and backoff enabled
  When the job fails repeatedly and retries are exhausted
  Then a notification is sent and the job is marked as failed and not requeued

# Easy to read
Scenario: The export stops after 3 failures
  Given the nightly export has failed 2 times
  When the nightly export fails again
  Then the nightly export has the status failed
  And the data team gets an email about the failure
  And the scheduler does not start the nightly export again
```

Before you show a `.feature` file, read each step against these rules and
rewrite the steps that break them.

**Bindings are written here, red.** Where `verify.scenarios` in
`.claude/balka.json` names a runner, write the step definitions for each new
`.feature` file now, in that runner, following the conventions the repo's
existing bindings use. Each `Then` step asserts the observable result the
scenario states — not that code ran, not that a call returned. `Given` and
`When` reach the code through whatever seam the repo's harness provides, and
they may reference code that does not exist yet: the bindings are meant to fail
until Build makes them pass. Run them once and show the owner they are red for
the right reason. The Then assertions are part of the contract from this point:
Build changes glue, never assertions, and Test checks that it did not. Where
there is no runner, write no bindings and say so: the `.feature` files are then
the acceptance checklist the verifier reads by hand.

**Changing an existing scenario.** Edit it in place. Never delete it and write
a fresh file, and never rename or copy it to start over: git is where a
scenario's history lives, and review reads the change as a diff of that history.
The `protect-scenarios` hook allows the edit because this change's `spec.md` is
in draft; the commit that carries it must also carry `spec.md`, or
`scenario-commit` blocks it. Delete a scenario only when the behaviour it
describes is gone, and say so in `spec.md`. If a hook blocks something here
that is right, stop and tell the owner: that is a bug in balka, and it goes to
`PROPOSALS.md`, not around the hook.

Size comes from scope, not from cutting. The budget below is a signal: if a
draft is over it, say so and say why, and offer to split rather than trimming
the words. Concision comes from the rules: one idea per sentence, no restating
an upstream file, no narrating third-party facts (those go to the facts document
or a code comment), and no section kept for the sake of the template — delete
one with nothing in it.

Budget: about 120 lines. Requirements are numbered, testable, one line each.

## Showing it

Markdown artefacts are shown by path, never pasted: the owner reads the file.
`.feature` files are the exception and are printed in full, one file at a time,
in a fenced `gherkin` block, every scenario included. Acceptance is the word
"accepted" from the owner; an answer to a scoped question is not acceptance, and
neither is silence. Beyond the draft header, write nothing to disk that the
owner has not seen.

After every `.feature` file has been through, print all of them once more in
full, then the path of the spec, and ask whether it is accepted. When it is, set
`Status: accepted`, commit the spec, its `.feature` files and bindings on the
change's branch, print the paths and ask "Continue to plan now?". On yes, read
`${CLAUDE_PLUGIN_ROOT}/commands/plan.md` and follow it in this session. On no,
stop.

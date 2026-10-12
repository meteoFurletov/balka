---
description: Stage 6, Maintain — ask how each thing this project already runs is known to keep working and which agent helps when it breaks, and record the owner's answers in the watch list.
argument-hint: [optional — what to watch, e.g. "the nightly export"]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(date:*), Bash(jq:*), Bash(git log:*), Bash(git status:*), Bash(git add:*), Bash(git commit:*), Bash(ls:*), Skill, AskUserQuestion
---

Fill the watch list for what this project already runs. Scope: $ARGUMENTS

New work gets its watch entries at the design transition, in `spec.md` under
Watch, and ships them with the change. This command is for everything that was
running before that: a repo that adopts balka late, or a job nobody wrote an
entry for.

## Before anything

Read `.claude/balka.json` at the git root. If it is absent, say that this repo has
not run `/balka:init` and stop: the watch list belongs to the loop.

Read the facts document named by `facts`, and the watch list named by
`watchList` (default `docs/watch.md`). If the watch list does not exist, write
it from the `watch.md` template with the owner's name.

## Loading a template

Read `${CLAUDE_PLUGIN_ROOT}/templates/<name>`. If that path does not exist, fall
back to the install path from
`jq -r '(.plugins // .) | to_entries[]|select(.key|startswith("balka@"))|.value[0].installPath' ~/.claude/plugins/installed_plugins.json`
plus `/templates/<name>`. If both fail, say so and stop. Never write a template
from memory — re-deriving it by hand is the drift this plugin exists to stop.

## Asking

List what this project runs on its own that the watch list does not cover:
scheduled jobs, pipelines, services, anything the facts document or the code
says runs without a person starting it. Show the list and let the owner strike
or add to it. Within the scope above, if one was given.

For each thing that is left, ask the questions the design transition asks, in
the same way: read `${CLAUDE_PLUGIN_ROOT}/commands/spec.md` under "Watch: how
we know it keeps running" and follow it. Propose two or three ways to watch it,
recommend one, and ask which agent responds, what calls it, and what it may do.
The owner decides each one. Never pick for them.

## Writing it

Write one entry per thing in the watch list, in its format. Where the check
already exists, name it. Where it does not, write `The check: none yet` and
`Proven red by: none yet`: a check is code, and code goes through the loop.
Offer to start that change now with `/balka:intent`, one change for all the
missing checks unless the owner wants them apart.

Commit the watch list and print its path. Then print what each entry needs
outside the repo before it can call its responder: a scheduler entry, a failure
hook, a secret, the agent enabled on the repository.

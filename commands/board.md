---
description: Show the board — every change in this repo, across every worktree, as a kanban with each card's next command. Opens live in the Claude desktop app's Browser pane; prints as markdown anywhere else.
argument-hint: "[--text]"
allowed-tools: Read, Write, Edit, Bash(python3:*), Bash(jq:*), Bash(git rev-parse:*)
---

Show the board. Flags: $ARGUMENTS

The board is `scripts/board.py` in this plugin: a local web app that reads every
worktree's change directories, the default branch, the claims and the pull
requests from `gh` on each refresh. It writes nothing. A card moves when its
stage finishes and the owner accepts it, so the board offers each card's next
command instead of a way to drag it.

Find the script at `${CLAUDE_PLUGIN_ROOT}/scripts/board.py`. If that path does
not exist, use the install path from
`jq -r '(.plugins // .) | to_entries[]|select(.key|startswith("balka@"))|.value[0].installPath' ~/.claude/plugins/installed_plugins.json`
plus `/scripts/board.py`.

## In the Claude desktop app

Unless `$ARGUMENTS` says `--text`:

1. Make sure `.claude/launch.json` at the git root has a `balka-board`
   configuration. Create the file if it is absent; if it is there, add this
   entry to `configurations` and touch nothing else. The entry finds the plugin
   when it runs, so it carries no machine-specific path and is safe to commit:

   ```json
   {
     "name": "balka-board",
     "runtimeExecutable": "bash",
     "runtimeArgs": ["-c", "exec python3 \"$(jq -r '(.plugins // .) | to_entries[] | select(.key | startswith(\"balka@\")) | .value[0].installPath' ~/.claude/plugins/installed_plugins.json)/scripts/board.py\""],
     "port": 4717,
     "autoPort": true
   }
   ```

2. Start the `balka-board` server in the Browser pane. Say that it now sits in
   the session toolbar's server menu, so it opens again without this command,
   and that it refreshes itself every few seconds.

## Anywhere else, and with --text

Run `python3 <script> --text` and print its output as it is. Outside the
desktop app, say that `python3 <script>` serves the live board at
http://localhost:4717.

## Reading it

The columns come from each change's `Status:` lines: Intent until the intent is
accepted, then Design, Plan, Build (the plan is accepted), Deploy (the plan is
built) and Done (merged, or built on the default branch). Parked, rejected and
split changes sit below the columns. A change in a worktree shows that
worktree's copy, and the worktree that holds its claim. Answer questions about
the board from the `--json` output rather than from memory.

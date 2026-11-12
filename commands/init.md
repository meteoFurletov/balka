---
description: Set this repo up for balka — current documentation, entry instructions, facts, proposals, opt-in hooks and review policy; optionally the deploy gate and Stage 6 detector.
argument-hint: "[--artifacts] [--hooks] [--gate] [--watch]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Skill, AskUserQuestion
---

Set this repository up for balka. Flags: $ARGUMENTS

With no flags, do `--artifacts` and `--hooks` — the two that need no CI and no
monitoring. The flags are additive and re-running any of them is safe. Say at the
start which you are doing, so the user is never guessing.

## Discover and preflight — no writes

Read existing entry instructions, the managed Balka block, and configuration
(`.claude/balka.json`, or the legacy `.claude/sdlc.json`). Retain configured
artifact and facts paths; read an existing facts document before drafting.
Load the templates needed for the selected flags through the route below.
Inspect the repository and collect missing owner facts before planning edits.

For `--artifacts`, discover an existing documentation home, readable project
overview, and writing policy. Retain the paths already recorded in the managed
entry block. Otherwise reuse suitable existing documents, including a README
or handbook; defaults for missing roles are `docs/`,
`docs/project-overview.md`, and `docs/documentation-writing.md`. Confirm missing
path choices with the owner alongside the existing artifact/facts questions.
Use the shipped writing policy to assess compatibility. Do not create a second
overview or rewrite maintained documents to fit a template.

Preflight every selected flag's edits as one batch, before creating directories,
changing configuration, migrating legacy files, or writing documents:

- Inspect every target and proposed diff. Preserve content outside managed
  blocks; inside them preserve the selected documentation paths. Existing
  overview, writing policy, facts, and proposals are maintained documents:
  reuse compatible content unchanged and create only missing roles.
- An edit to a maintained line is a collision. Report the file, line numbers,
  and conflicting text, then stop with no setup changes written. This includes
  additions needed to make an existing document serve a role: resolve them in
  place with the owner and rerun. Never suggest deleting or relocating it.
- Include the legacy migration and CURRENT cleanup below in this preflight.
  For `--hooks`, preserve existing verification commands, deploy settings,
  gate/watch objects, path choices, and unknown configuration keys; merge only
  required defaults and the documented version upgrade.
- For `--gate`, obtain its required choices below before applying any edits.
  For `--watch`, read `commands/watch.md` from the resolved plugin install root,
  check its prerequisites, and preflight every scaffold destination and config
  edit before applying any selected flag.
  A collision or failed prerequisite leaves the repository unchanged.

The preflight is part of init, not an extra approval gate. Once it is clear,
apply the prepared edits below. Repeating setup must retain owner additions,
reuse the selected paths, and produce no duplicate pointers or documents.

## Apply the prepared setup

**Renamed from sdlc-loop.** If `.claude/sdlc.json` exists and `.claude/balka.json`
does not, this repo was set up under the plugin's old name. After preflight,
`git mv` it to `.claude/balka.json`, replace `.claude/sdlc.json` with
`.claude/balka.json` inside its `artifactPaths`, rename the
`<!-- sdlc-loop:begin -->` / `<!-- sdlc-loop:end -->` markers in `REVIEW.md` to
`balka:`, and move the `sdlc-loop` block out of `CLAUDE.md` into `AGENTS.md`
under `balka:` markers, so the merges below update those blocks instead of
adding second ones. Say that you did it.

If `<artifactDir>/CURRENT` exists, `git rm` it and say so. Nothing reads it any
more: several changes can be in flight at once, one per branch.

**Never overwrite.** Apply only the preflighted merges. Managed blocks are
updated in place; maintained documents are reused, not regenerated.

## Loading a template

Read `${CLAUDE_PLUGIN_ROOT}/templates/<name>`. If that path does not exist, fall
back to the install path from
`jq -r '(.plugins // .) | to_entries[]|select(.key|startswith("balka@"))|.value[0].installPath' ~/.claude/plugins/installed_plugins.json`
plus `/templates/<name>`. If both fail, say so and stop. Never write a template
from memory — re-deriving it by hand is the drift this plugin exists to stop.

### --artifacts

Use the artifact and documentation paths established during preflight. With no
existing choice, the artifact default is `docs/balka`. Then:

- Merge the `AGENTS.md` template into the repo's `AGENTS.md` between its
  `<!-- balka:begin -->` and `<!-- balka:end -->` markers, so re-running updates that block and touches
  nothing else; substitute the real paths for `<artifacts-dir>`, `<facts-doc>`,
  `<documentation-home>`, `<overview-doc>`, and `<documentation-policy>`.
  If the block from an earlier version carries a "Verifying your
  work" table, replace the whole block: the verify commands live in
  `.claude/balka.json` now.
- If the repo also has a `CLAUDE.md`, Claude Code reads it instead of
  `AGENTS.md`. Make `@AGENTS.md` its first line unless it already imports it.
- Create a missing facts document from `estate.md` at the selected path (default
  `docs/estate.md`), with the owner's name and the names collected in preflight.
  Retain an existing facts document and its history.
- Create `<artifactDir>/PROPOSALS.md` from its template only if missing; preserve
  all existing entries and routes on reruns.
- Create a missing overview from `project-overview.md`, filling purpose, major
  parts and relationships, and working procedures from inspected repository
  evidence. Reference the actual facts document, contracts, code, and commands.
  Mark unsupported details as unknown; ask for facts that block setup during
  preflight. This is a readable introduction, not a complete repository manual.
- Create a missing policy from `documentation-writing.md`. Reuse compatible
  maintained guidance unchanged. The entry block records the actual paths;
  there are no documentation configuration keys or separate full inventory.
- Add `.claude/worktrees/` to `.gitignore` unless something there already
  covers it. Worktree sessions live there, and the main checkout should not
  list them as untracked.
- Create missing `.github/copilot-instructions.md` from the
  `copilot-instructions.md` template, with the owner's name, and `REVIEW.md`
  from its template. Apply only preflighted managed-block updates to existing
  files; resolve incompatible maintained policies as collisions. Tell the
  owner that Copilot code review reads the former on every pull request, and
  that a repository ruleset with automatic Copilot review is what makes
  `/balka:deploy` need no manual request.

### --hooks

Create a missing `.claude/balka.json` from the `balka.json` template, or apply
the preflighted merge to an existing one. This one file is the
opt-in: the plugin registers its hooks in every session, and each hook's first
act is to look for this file and do nothing if it is absent. Nothing is copied
into the repo, so upgrading the plugin upgrades this repo's gates. Deleting the
file turns them off.

Set from what the repo actually looks like:

- `scenarioGlobs` — where `.feature` files are. Look for existing ones; if there
  are none, ask where they will go.
- `artifactDir` and `artifactPaths` — the artefact directory plus the facts
  document, `AGENTS.md`, `CLAUDE.md`, `REVIEW.md`, `.github/copilot-instructions.md` and
  `.claude/balka.json`. These are artefacts living outside the artefact
  directory, and leaving them out makes `plan-sync` block every commit that
  touches them.
- `facts` — the facts document's path.
- `deploy` — `"pr"` where changes go through a pull request on GitHub;
  `"manual"` where this repo's landing pipeline is its own and the loop only
  prints it.
- `verify` — leave the four entries `null`; `/balka:verify` fills them.
  On a rerun, retain existing values.

Do not add the documentation home, overview, or writing policy to `artifactPaths`.
Current project documentation belongs in the normal plan file list. Preserve
the existing facts and process-artifact exemptions; do not add a broad `docs/**`
exemption for the new documentation.

A file from version 1 of this plugin (no `version`, or `version: 1`) is
upgraded in place: add the missing keys with these defaults, move
`scenarioCommand` into `verify.scenarios`, and say what moved.

Globs take `*`, `?` and `**`. Brace expansion is not supported.

Then say what the three build-time hooks do, one sentence each:
`protect-scenarios` blocks an Edit or Write over an existing `.feature` file and
allows new ones; `scenario-commit` blocks a commit that modifies or deletes an
existing `.feature` file unless the active change's `spec.md` is staged with it,
whatever tool wrote the file; `plan-sync` blocks a commit touching files absent
from the `Files that change` list in `plan.md` unless `plan.md` is staged with
it. All three allow and explain themselves when they cannot establish their
condition, and none ever pauses for a human.

### --gate

Add a `gate` object to `.claude/balka.json`. Ask for these and guess at none:

- `approver` — the person a production release waits for, by name.
- `deployPatterns` — shell-glob patterns matching this repo's production deploy
  commands (`*` crosses `/` here; these match a command line, not a path).
  Propose them from the repo's own workflows and scripts and have the owner
  confirm. No script can tell production from staging, so these patterns *are*
  the definition of production — too broad makes the gate noise, too narrow makes
  it decoration.
- `authorisation` — optionally, what authorisation looks like here.

This is the only hook that pauses for a human, and it is out of the Build path by
construction.

### --watch

After its prerequisites and destinations have passed the batch preflight, hand
off to `/balka:watch` to apply that prepared scaffold. Its own checks still hold.

### Finally

Print what changed, what did not, and the next command — normally
`/balka:verify`, then `/balka:intent` for the first change.

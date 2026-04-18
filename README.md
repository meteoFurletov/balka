# Balka

A file-based, AI-powered personal OS that runs inside [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Learning, tasks, research, and a knowledge wiki — all plain markdown and JSON, all version-controlled, one mode.

> *A balka (Russian: балка) is a dry, flat-bottomed erosional valley typical of the Central Russian Upland — older and gentler than a ravine, where sediment and knowledge quietly accumulate over long time.*

This repo is the **public harness**: templates, rubrics, slash commands, and scripts. Zero personal data. You fork it, personalize it, and keep your content in your fork. Harness updates flow one way — from upstream to your fork.

## Quick Start

```bash
# 1. Fork this repo on GitHub, then clone your fork
git clone git@github.com:<you>/balka-private.git
cd balka-private

# 2. Add upstream so you can pull harness updates later
git remote add upstream git@github.com:meteoFurletov/balka.git

# 3. Personalize USER.md (your name, role, active focus)
$EDITOR USER.md

# 4. Start Claude Code
claude

# 5. Use it
> Start a new project on Python concurrency
> add task: review SQLMesh incremental models
> /add-epic Personal Task Management System
> /review
```

## How It Works

Everything is plain markdown files and JSON. Claude Code reads `CLAUDE.md` to understand how to be your tutor, task manager, and research assistant, then reads/writes files as you work. Git is the persistence layer; Obsidian (optional) is a visual interface over the same files.

Two modes:

- **use** (default) — you learn, manage tasks, research. Auto-commits on every file write.
- **dev** — you improve the system itself: templates, rubrics, commands, scripts.

## What it does

### Learning

1. **Curriculum** — Tell Claude what you want to learn. It generates a structured curriculum with modules and concept-based difficulty levels.
2. **Notes** — Pick a topic and Claude generates depth-aware, Zettelkasten-style notes (e.g., `L1-threading.md` for fundamentals, `L3-threading.md` for advanced). Notes check the wiki first and cross-link to existing pages.
3. **Quizzes** — Claude quizzes you one question at a time, generated fresh from concept lists. Scores tracked per concept in `progress.json` — questions are never stored.
4. **Adaptive levels** — Weak concepts and your feedback shape the next level's concept list.

### Task management

A file-based kanban. Tasks live in `tasks/NK-<N>.md`, epics in `epics/EP-<N>.md`. Board state mirrored in `board/index.md`, activity appended to `board/log.md`.

- `/add-task <title>` — create a new task (auto-assigned NK-ID)
- `/move-task NK-X <status>` — move through `idea` → `todo` → `in-progress` → `done`
- `/add-epic <title>` — create a new epic
- `/link-task NK-X EP-Y` — attach a task to an epic

### Research & wiki

- `/research <topic> for NK-X` — focused research written into the task file, with reusable findings promoted to `wiki/`
- `/wiki-ingest raw/articles/<file>` — summarize a source document into `wiki/sources/` and cross-link to concept pages

The wiki is a compounding knowledge base. Tasks link to it, notes link to it, research enriches it. Cross-references use Obsidian-style `[[category/slug]]` links and are bidirectional by convention.

### Daily scheduling

- `/schedule` — pick **one** focused action for today based on current state (stuck tasks, weak quiz concepts, mid-level progress, stale ideas), land it on the board, and DM you on Telegram. Idempotent: re-running on the same day is a no-op.

Inbound DMs to the same bot are full-function — you can send `add task: pick up the order`, `/move-task NK-12 done`, `Quiz me on module 2`, or anything else that works in a terminal session, and the live session handles it. Telegram is a transport, not a curated subset.

**Setup (one-time):**

1. **Install the Telegram plugin** and pair your Telegram account with it. Follow the plugin's own README for BotFather, pairing, and access control: `~/.claude/plugins/.../telegram/0.0.6/README.md` (or `/plugin install telegram@claude-plugins-official` from inside Claude Code). The plugin keeps the bot token in `~/.claude/channels/telegram/.env` and your numeric chat ID in `~/.claude/channels/telegram/access.json`. Balka never touches those files — it only reads the chat ID at runtime.
2. **Start a persistent session** with the channel attached. Keep it alive however you prefer (tmux, a systemd `--user` unit, `screen`, `nohup`, …):

   ```bash
   claude --channels plugin:telegram@claude-plugins-official
   ```

   This session is both your inbound listener (DMs land here) and the runtime `/schedule` fires inside.
3. **Create the daily trigger.** From that session, ask the `schedule` skill to set it up, e.g.:

   ```text
   schedule /schedule daily at 08:00 in my balka repo
   ```

   The trigger survives session restarts and re-invokes `/schedule` each morning; the command's own idempotency check prevents double-scheduling if the trigger ever re-fires the same day.

If the Telegram plugin isn't available or no user is allowlisted yet, `/schedule` still runs, still lands the task, and still commits — it just records `Notified: no — <reason>` in the daily log and moves on.

### Weekly review

- `/review` — unified learn + task + wiki + epic review over the last 7 days. Runs `scripts/lint.sh` to surface stuck tasks, orphan wiki pages, stale content, and broken links. Saves a dated report to `memory/daily/` and updates `memory/MEMORY.md`.

## Repository Structure

```text
# Harness (upstream, public)
CLAUDE.md             → System router
templates/            → Content format definitions
rubrics/              → Quality standards
scripts/              → git-sync.sh, lint.sh
.claude/commands/     → Slash commands

# Your data (fork only)
USER.md               → Personal context
projects/             → Learning projects
board/                → Kanban state (index, counter, log)
tasks/                → Task cards (NK-<N>.md)
epics/                → Epics (EP-<N>.md)
wiki/                 → Knowledge base
raw/                  → Source documents
memory/               → Curated context across sessions
```

## Pulling Harness Updates

When the upstream harness improves, pull the changes into your fork:

```bash
git fetch upstream
git checkout main
git merge upstream/main       # or rebase, if you haven't diverged
git push origin main
```

Your personal data (`projects/`, `board/`, `tasks/`, etc.) lives only in your fork and is never part of the upstream harness.

## Contributing

Pull requests to the harness are welcome. Scope: templates, rubrics, slash commands, scripts, CLAUDE.md, README.md, DESIGN.md. **Never commit personal data to the upstream repo.** If you fork and want to contribute back, branch from `main` and keep the PR limited to harness files.

See [DESIGN.md](DESIGN.md) for the full rationale behind the structure.

## Example Session

```text
You: Start a new project on Kubernetes
Claude: [asks about experience, creates project folder, generates curriculum]

You: add task: set up a local k3s cluster to practice
Claude: [creates NK-001, appends to board, git-syncs]

You: /link-task NK-001 EP-1
Claude: [links task to epic, updates both files and board]

You: research kind vs k3s vs minikube for local development for NK-001
Claude: [reads research-quality rubric, gathers, writes findings to NK-001,
         creates wiki/comparisons/local-k8s-tools.md, cross-links]

You: Quiz me on module 1 level 1
Claude: [generates a fresh question on a concept] What is a Pod?
You: [answer]
Claude: [grades, gives feedback, saves score to progress.json]

You: /move-task NK-001 in-progress
Claude: [updates frontmatter, board, log, git-syncs]

You: /review
Claude: [runs lint, reads log + progress + wiki, writes memory/daily/...-review.md,
         summarizes: 3 tasks moved, 1 quiz level completed, 1 new wiki page]
```

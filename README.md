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

Setup is a one-time thing — see [Telegram & Scheduler Setup](#telegram--scheduler-setup) below.

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

## Telegram & Scheduler Setup

One-time setup to get `/schedule` pinging you on Telegram and inbound DMs acting as a full remote control for your balka. Budget ~10 minutes, most of it in Telegram itself.

### Prerequisites

- [Bun](https://bun.sh) — the Telegram plugin runs on Bun. `curl -fsSL https://bun.sh/install | bash`.
- A Telegram account.
- This repo cloned locally and a working `claude` CLI.

### 1. Create the bot on Telegram

Open a chat with [@BotFather](https://t.me/BotFather) and send `/newbot`. BotFather asks for two things:

- **Name** — the display name (anything, spaces allowed).
- **Username** — a unique handle ending in `bot`, e.g. `my_balka_bot`. Becomes `t.me/my_balka_bot`.

BotFather replies with a token like `123456789:AAHfiqksKZ8...`. Copy the whole thing including the leading number and colon. Treat it like a password — anyone with this token can read your inbound DMs and post as the bot.

### 2. Install the Telegram plugin

Start Claude Code anywhere, then:

```text
/plugin install telegram@claude-plugins-official
/reload-plugins
/telegram:configure 123456789:AAHfiqksKZ8...
```

`/telegram:configure` writes the token to `~/.claude/channels/telegram/.env`. You can also edit that file by hand — the plugin re-reads on the next session. The token lives *outside* this repo on purpose: balka never sees it.

### 3. Start the persistent session

The Telegram bot uses a long-poll connection — only one process can hold it at a time — so you want one long-running Claude Code session that handles both inbound DMs and the daily `/schedule` push. Keep it alive however suits you; pick one:

**tmux (simple):**

```bash
tmux new -s balka
cd /path/to/balka
claude --channels plugin:telegram@claude-plugins-official
# detach: Ctrl-b d       reattach: tmux attach -t balka
```

**systemd --user unit (auto-restart on reboot):**

```ini
# ~/.config/systemd/user/balka-telegram.service
[Unit]
Description=Balka Claude Code session with Telegram channel
After=default.target

[Service]
Type=simple
WorkingDirectory=%h/Projects/balka
ExecStart=%h/.local/bin/claude --channels plugin:telegram@claude-plugins-official
Restart=on-failure

[Install]
WantedBy=default.target
```

```bash
systemctl --user daemon-reload
systemctl --user enable --now balka-telegram
journalctl --user -u balka-telegram -f    # watch logs
```

Adjust paths to match your setup (`which claude`, repo location). `systemd --user` units need `loginctl enable-linger $USER` if you want them surviving logout.

### 4. Pair your Telegram account

With the session from step 3 running, DM your bot on Telegram. The bot replies with a 6-character pairing code. In the live session, run:

```text
/telegram:access pair <code>
/telegram:access policy allowlist
```

The `allowlist` step locks the bot down so strangers who guess its username get silently dropped. After pairing, `~/.claude/channels/telegram/access.json` contains your numeric user ID — that's what `/schedule` reads when it sends the daily ping.

### 5. Create the daily trigger

Still in the live session:

```text
schedule /schedule daily at 08:00
```

That asks the `schedule` skill to wire up a `CronCreate` remote-agent trigger. It survives session restarts; the trigger fires `/schedule` each morning from within whichever live session has the Telegram channel attached. `/schedule`'s own idempotency check (`memory/daily/<date>-scheduled.md`) means a double-fire on the same day is a no-op.

Inspect or edit your triggers later with the same skill:

```text
schedule list
schedule update <trigger-id> time 09:30
schedule delete <trigger-id>
```

### 6. Smoke test

In the live session:

```text
/schedule
```

Expect:

- A new file `memory/daily/<today>-scheduled.md` describing which case (1–6) fired and why.
- A Telegram DM starting with `🌅 Today's focus`.
- A commit on `main` via `git-sync.sh`.

Then run `/schedule` again immediately. Expect `Already scheduled today:` and no second DM, no second commit.

Test the inbound path by DM'ing the bot:

```text
add task: verify telegram round-trip
```

The live session should handle it as a normal `/add-task` invocation — a new `NK-<N>.md` appears and the bot replies with the task ID.

### Troubleshooting

| Symptom | Likely cause | Fix |
| ------- | ------------ | --- |
| Bot doesn't reply to your DM | Session wasn't launched with `--channels plugin:telegram@...`, or another process is holding the token | Confirm the session you started in step 3 is still running; kill stray `bun server.ts` processes |
| `/schedule` logs `Notified: no — no allowlisted user` | You haven't paired yet, or `access.json` is empty | Re-do step 4 |
| `/schedule` logs `Notified: no — telegram channel not attached` | The session running `/schedule` wasn't launched with `--channels` | Start the session per step 3 and re-run |
| Daily trigger isn't firing | `scripts/lint.sh` will warn after 3 days of silence | `schedule list` to inspect; restart the live session if the trigger was created in a session that's since died |
| Inbound DMs get ignored | `dmPolicy` is `disabled`, or message came from a non-allowlisted user | `/telegram:access` to inspect; `/telegram:access allow <user-id>` to approve |

If Telegram is down or credentials are missing, `/schedule` still runs, still lands the task on the board, and still commits. Notification is a side-channel — the board is the source of truth.

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

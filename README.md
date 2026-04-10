# Personal Learning & Task Management System

A file-based, AI-powered personal OS that runs inside [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Learning, tasks, research, and a knowledge wiki — all plain markdown and JSON, all version-controlled, one mode.

## Quick Start

```bash
git init learning-system && cd learning-system
claude

> Start a new project on Python concurrency
> add task: review SQLMesh incremental models
> /add-epic Personal Task Management System
```

## How It Works

Everything is plain markdown files and JSON. Claude Code reads `CLAUDE.md` to understand how to be your tutor, task manager, and research assistant, then reads/writes files as you work.

Two modes:

- **use** (default, `learning` branch) — you learn, manage tasks, research. Auto-commits on every file write.
- **dev** (`main` branch) — you improve the system itself: templates, rubrics, commands, scripts.

## What it does

### Learning

1. **Curriculum** — Tell Claude what you want to learn. It generates a structured curriculum with modules and concept-based difficulty levels.
2. **Notes** — Pick a topic and Claude generates depth-aware, Zettelkasten-style notes (e.g., `L1-threading.md` for fundamentals, `L3-threading.md` for advanced).
3. **Quizzes** — Claude quizzes you one question at a time, generated fresh from concept lists. Scores tracked per concept in `progress.json` — questions are never stored.
4. **Adaptive levels** — Weak concepts and your feedback shape the next level's concept list.

### Task management

A file-based kanban. Tasks live in `tasks/NK-<N>.md`, epics in `epics/EP-<N>.md`. Board state mirrored in `board/index.md`, activity appended to `board/log.md`.

- `/add-task <title>` — create a new task (auto-assigned NK-ID)
- `/move-task NK-X <status>` — move through `idea` → `todo` → `in-progress` → `done`
- `/add-epic <title>` — create a new epic
- `/link-task NK-X EP-Y` — attach a task to an epic

### Wiki (coming in Phase 2)

A compounding knowledge base under `wiki/`. Research on tasks enriches it. Notes link to it. Everything cross-references via Obsidian-style `[[wiki-links]]`.

## Project Structure

```text
CLAUDE.md         → System router
USER.md           → Personal context
templates/        → Content format definitions
rubrics/          → Quality standards
scripts/          → Automation (git-sync)
.claude/commands/ → Slash commands

projects/         → Your learning projects
board/            → Kanban state (index, counter, log)
tasks/            → Task cards (NK-<N>.md)
epics/            → Epics (EP-<N>.md)
wiki/             → Knowledge base
raw/              → Source documents
memory/           → Curated context across sessions
```

## Example Session

```text
You: Start a new project on Kubernetes
Claude: [asks about experience, creates project folder, generates curriculum]

You: add task: set up a local k3s cluster to practice
Claude: [creates NK-001, appends to board, git-syncs]

You: Quiz me on module 1 level 1
Claude: [generates question on "pod-basics" concept]
...

You: /move-task NK-001 in-progress
Claude: [updates frontmatter, board, log, git-syncs]

You: Push
Claude: [git add, commit, push]
```

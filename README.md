# Interactive Learning System

A file-based, AI-powered learning system designed to run with [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## Quick Start

```bash
# 1. Clone or copy this repo
git init learning-system && cd learning-system

# 2. Start Claude Code
claude

# 3. Start learning
> Start a new project on Python concurrency
```

## How It Works

Everything is plain markdown files and JSON. Claude Code reads the `CLAUDE.md` to understand how to be your tutor, then reads/writes project files as you learn.

**The workflow:**

1. **Curriculum** — Tell Claude what you want to learn. It generates a structured curriculum with modules and difficulty levels.
2. **Notes** — Pick a topic and Claude generates detailed, Zettelkasten-style notes.
3. **Flashcards** — Claude generates flashcards on the fly from your notes for interactive review in conversation.
4. **Quizzes** — Claude quizzes you one question at a time in a continuous conversation. Scores are tracked per question in `progress.json` — no quiz files saved.

**Your progress is just files.** Everything saves to `projects/`, and since it's a git repo, you get full version history and can push to GitHub anytime.

## Project Structure

```text
CLAUDE.md              → System instructions for Claude Code
templates/             → Content format templates
rubrics/               → Grading and quality standards
projects/              → Your learning projects (one folder each)
```

## Example Session

```text
You: Start a new project on Kubernetes
Claude: [asks about experience, creates project folder, generates curriculum]

You: Generate notes for module 1
Claude: [creates detailed note, saves to notes/]

You: Quiz me on module 1 level 1
Claude: Question 3: What is a Pod in Kubernetes?
You: A pod is the smallest deployable unit...
Claude: [grades, gives feedback] Question 1/10 — running average: 8.0/10
Claude: Next question: ...
You: stop
Claude: [saves progress, syncs]

You: Show my progress
Claude: [reads progress.json, summarizes completion and scores]

You: Push
Claude: [git add, commit, push]
```

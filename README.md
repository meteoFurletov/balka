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
3. **Flashcards** — Claude extracts key terms from notes into interactive flashcard decks.
4. **Quizzes** — Claude quizzes you in small batches (default: 3 questions) from a 10-question bank per level. Progress carries across sessions until the level is complete.

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
Claude: Question 3: What is a Pod in Kubernetes? (1 of 3 in this batch, 0/10 answered)
You: A pod is the smallest deployable unit...
Claude: [acknowledges, moves to next question]
Claude: [after batch: grades all, shows "3/10 answered, avg: 7.8/10"]

You: Set quiz size to 5
Claude: [updates batch size to 5 for future sessions]

You: Show my progress
Claude: [reads progress.json, summarizes completion and scores]

You: Push
Claude: [git add, commit, push]
```

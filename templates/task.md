# Task Template

When creating a task, follow this structure. Tasks live in `tasks/NK-<N>.md` and are indexed in `board/index.md`.

## File Naming

`tasks/NK-<N>.md` where N is a zero-padded integer from `board/counter.json` (e.g., `NK-001.md`, `NK-042.md`).

## Format

```markdown
---
id: NK-<N>
title: <short imperative title>
status: idea
epic: <EP-X or null>
priority: <low | medium | high>
created: <YYYY-MM-DD>
updated: <YYYY-MM-DD>
linked_wiki: []
linked_project: null
scheduled: false
---

# NK-<N>: <Title>

## Description

1-3 sentences describing what the task is and why it matters. Capture the intent, not the implementation.

## Research

Left empty on creation. Populated by `/research` with findings, links, and summaries.

## Notes

Free-form decisions, context, open questions. Append as work progresses.
```

## Field Guidelines

- **id** — always matches the filename. Never reassign.
- **title** — short imperative ("Explore self-hosted Plane", not "Exploration of Plane options")
- **status** — one of: `idea`, `todo`, `in-progress`, `done`. Default `idea` on creation.
- **epic** — `EP-X` reference or `null`. Use `/link-task` to attach later.
- **priority** — `low`, `medium`, or `high`. Default `medium` unless user specifies.
- **created** / **updated** — ISO date. `updated` changes on every edit.
- **linked_wiki** — array of wiki page slugs this task references (e.g., `[concepts/event-loop]`).
- **linked_project** — slug of a learning project (e.g., `python-concurrency`) or `null`.
- **scheduled** — `true` if the task was created by `/schedule`, `false` (default) for user-created tasks. Lets `/review` and lint distinguish auto-generated tasks from intentional ones.

## Status Flow

`idea` → `todo` → `in-progress` → `done`

Moving backward is allowed but should be rare — note the reason in `## Notes`.

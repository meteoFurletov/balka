# Epic Template

Epics group related tasks toward a larger goal. Epics live in `epics/EP-<N>.md` and are indexed in `epics/index.md`.

## File Naming

`epics/EP-<N>.md` where N comes from `board/counter.json` (e.g., `EP-1.md`, `EP-12.md`).

## Format

```markdown
---
id: EP-<N>
title: <Epic Title>
status: active
created: <YYYY-MM-DD>
updated: <YYYY-MM-DD>
---

# EP-<N>: <Epic Title>

## Goal

1-2 paragraphs describing the outcome this epic is driving toward. Focus on the "why" and the end state.

## Success Criteria

- Concrete, checkable conditions that mean the epic is done.
- Prefer 3-5 criteria. If you need more, the epic is probably too large.

## Linked Tasks

<!-- Maintained by /link-task and /add-task. Do not edit by hand unless fixing drift. -->

- [[NK-001]]: <task title>
- [[NK-002]]: <task title>

## Notes

Free-form decisions, scope changes, blockers.
```

## Field Guidelines

- **id** — matches filename. Never reassign.
- **status** — one of: `active`, `paused`, `done`, `dropped`.
- **created** / **updated** — ISO date.

## Epic vs Task

- A **task** is something you do in one sitting or one focused block.
- An **epic** is a collection of tasks pointing at the same outcome. If an item will take more than ~5 tasks to complete, make it an epic.

---
description: Move a task to a new status column
---

# /move-task

Change a task's status. Usage:

- `/move-task NK-<N> <status>`
- "move NK-<N> to <status>"

Valid statuses: `idea`, `todo`, `in-progress`, `done`.

## Steps

1. **Confirm mode.** Must be `use` mode.
2. **Read `tasks/NK-<N>.md`.** If it doesn't exist, report the error and stop.
3. **Validate the target status.** Must be one of the four valid values. Reject anything else.
4. **Update the task file's frontmatter:**
   - `status: <new status>`
   - `updated: <today>`
5. **Update `board/index.md`:** remove the row from its current section and append to the new section. Preserve column order.
6. **Append to `board/log.md`:**
   `## [<date>] move | NK-<N> | <old-status> → <new-status>`
7. **Run `./scripts/git-sync.sh`** with message `task: move NK-<N> <old> → <new>`.
8. **Confirm to the user.**

## Notes

- Moving backward (e.g., `done` → `in-progress`) is allowed but should be rare. Ask the user to note a reason in the task's `## Notes` section when this happens.
- If the task is already in the target status, report that and skip the write.
- If the task has `linked_project` and the move is to `done`, suggest (but do not auto-run) that the user check learning progress for that project.

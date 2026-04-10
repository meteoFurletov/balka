---
description: Create a new task card with auto-incremented NK-ID
---

# /add-task

Create a new task card. Usage:

- `/add-task <title>`
- "add task: <title>"
- "new task: <title>" (optionally followed by description, epic, priority)

## Steps

1. **Confirm mode and branch.** Must be `use` mode on the `learning` branch. Switch if not.
2. **Parse the title.** Keep it short and imperative. Ask a clarifying question only if the title is missing or unclear.
3. **Read `board/counter.json`** to get `next_task_id`. Let `N` = that value.
4. **Increment and write back** `board/counter.json` with `next_task_id: N + 1`.
5. **Create `tasks/NK-<N>.md`** using `templates/task.md`. Zero-pad the ID in the filename to 3 digits (e.g., `NK-001.md`). Frontmatter defaults:
   - `id: NK-<N>` (not zero-padded in the id field)
   - `status: idea`
   - `epic: null`
   - `priority: medium` (unless user specified)
   - `created` / `updated`: today's date
   - `linked_wiki: []`
   - `linked_project: null`
6. **Append a row** to the `## Idea` section of `board/index.md`:
   `| NK-<N> | <title> | — | <priority> | <date> |`
7. **Append to `board/log.md`**:
   `## [<date>] create | NK-<N> | <title>`
8. **Run `./scripts/git-sync.sh`** with message `task: create NK-<N> <title>`.
9. **Confirm to the user**: show the task ID, title, and path.

## Notes

- If the user provides more detail (description, epic, priority), fill them in during step 5 and link in step 6–7.
- If the user says "add task linked to EP-X", also run the `/link-task` flow after creation.
- Never reuse an ID. If `counter.json` is missing, fail with a clear error — do not guess.

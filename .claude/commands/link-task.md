---
description: Link a task to an epic (or unlink)
---

# /link-task

Attach a task to an epic, or detach it. Usage:

- `/link-task NK-<N> EP-<M>`
- "link NK-<N> to EP-<M>"
- "unlink NK-<N>" (clears the epic field)

## Steps (link)

1. **Confirm mode and branch.** Must be `use` mode on `learning`.
2. **Read both files:** `tasks/NK-<N>.md` and `epics/EP-<M>.md`. If either is missing, report and stop.
3. **Update the task's frontmatter:**
   - `epic: EP-<M>`
   - `updated: <today>`
4. **Update the epic's body** — append to `## Linked Tasks`:
   `- [[NK-<N>]]: <task title>`
   Skip if the line already exists.
5. **Update `board/index.md`** — set the `Epic` column for NK-<N>'s row to `EP-<M>`.
6. **Append to `board/log.md`:**
   `## [<date>] link | NK-<N> → EP-<M>`
7. **Run `./scripts/git-sync.sh`** with message `link: NK-<N> → EP-<M>`.
8. **Confirm to the user.**

## Steps (unlink)

1. Read the task file. If `epic` is already `null`, report and stop.
2. Let `EP-<M>` be the current value. Read `epics/EP-<M>.md`.
3. Set task `epic: null`, update `updated`.
4. Remove the `- [[NK-<N>]]: ...` line from the epic's `## Linked Tasks`.
5. Update `board/index.md` — clear the `Epic` column for that row.
6. Append to `board/log.md`: `## [<date>] unlink | NK-<N> ⟵ EP-<M>`
7. Run `./scripts/git-sync.sh` with message `unlink: NK-<N> ⟵ EP-<M>`.
8. Confirm.

## Notes

- A task can be linked to at most one epic. Re-linking to a different epic is allowed — unlink from the old one first, then link to the new one (as one operation in the log).
- Do not auto-create epics. If the target epic doesn't exist, tell the user to run `/add-epic` first.

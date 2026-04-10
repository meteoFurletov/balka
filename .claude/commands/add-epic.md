---
description: Create a new epic with auto-incremented EP-ID
---

# /add-epic

Create a new epic. Usage:

- `/add-epic <title>`
- "add epic: <title>"

## Steps

1. **Confirm mode and branch.** Must be `use` mode on `learning`.
2. **Parse the title.** Ask for a title if missing. Optionally ask for a one-sentence goal if the user hasn't provided one.
3. **Read `board/counter.json`** to get `next_epic_id`. Let `N` = that value.
4. **Increment and write back** `board/counter.json` with `next_epic_id: N + 1`.
5. **Create `epics/EP-<N>.md`** using `templates/epic.md`. Frontmatter defaults:
   - `id: EP-<N>`
   - `status: active`
   - `created` / `updated`: today's date
   - Body: fill in `## Goal` from the user's input. Leave `## Success Criteria` with 3 placeholder bullets for the user to edit if they haven't provided them. `## Linked Tasks` is empty.
6. **Append a row** to `epics/index.md`:
   `| EP-<N> | <title> | active | <date> |`
7. **Append to `board/log.md`:**
   `## [<date>] create | EP-<N> | <title>`
8. **Run `./scripts/git-sync.sh`** with message `epic: create EP-<N> <title>`.
9. **Confirm to the user** and ask if they want to link any existing tasks to it (triggers `/link-task`).

## Notes

- If the user is ambiguous about whether they want an epic or a task, ask: "Will this take more than ~5 distinct tasks to finish? If yes, epic. If no, task."
- Never reuse an ID.

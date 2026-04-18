---
description: Pick one focused action for today based on current state and notify
---

# /schedule

Daily single-shot scheduler. Analyze the system state, pick **one** concrete action for the day, land it on the board, and send a Telegram notification. Designed to run headlessly via `claude -p "/schedule"` from a daily cron or launchd job; also works interactively.

Usage:

- `/schedule`
- `claude -p "/schedule" --permission-mode acceptEdits`

## Prerequisites

- **Mode:** `use` mode.
- **Branch:** the active branch (typically `main`). Do not switch branches.
- **One task per day.** Never batch. The whole point is to defeat procrastination by surfacing a single small thing.

## Idempotency

If `memory/daily/<YYYY-MM-DD>-scheduled.md` already exists, exit early:

```text
Already scheduled today: see memory/daily/<YYYY-MM-DD>-scheduled.md
```

Do not re-pick, do not re-notify, do not re-commit. The user can delete that file to force a re-run.

## Steps

1. **Compute today's date** (`YYYY-MM-DD`) and check the idempotency file. Exit early if it exists.

2. **Gather state.** Read in this order:
   - `board/index.md` — current board state
   - `board/log.md` — last 7 days of activity (filter by date)
   - `board/counter.json` — next task ID
   - Every `projects/*/progress.json` — quiz scores, completed levels, weak concepts (avg < 7), last activity
   - `epics/index.md` — active epics
   - `memory/MEMORY.md` — curated context
   - `USER.md` — current focus
   - **Yesterday's** `memory/daily/<YYYY-MM-DD>-scheduled.md` if present — to avoid picking the same stuck task two days in a row unless nothing else is available.

3. **Pick ONE action.** Walk this priority list and stop at the first match:

   1. **Stuck task.** Any task in `in-progress` whose `updated` date is > 7 days ago. Pick the most-stuck one. *Skip if it was yesterday's pick AND another priority-2+ candidate exists.* The "task" is a nudge: decide push forward / move back to `todo` / drop. **Do not create a new NK card** — reference the existing one.
   2. **Weak concept.** Any active project with a concept that has been tested AND has avg score < 7. Pick the weakest. **Create a new NK card** titled e.g. `Quiz review: <concept> (<project>)` with `linked_project: <slug>`, `linked_wiki: []`, `priority: high`, `status: todo`, `scheduled: true`.
   3. **Mid-level.** Any project where the current level has some concepts scored but is not yet complete (7 scored). **Create a new NK card** titled e.g. `Continue L<N> quiz: <next concept> (<project>)`. Same frontmatter as case 2.
   4. **Next level.** Any project where a level just completed and the next level exists or needs generating. **Create a new NK card** titled e.g. `Start L<N+1>: one quiz question (<project>)` or `Generate L<N+1> note on <topic>`. Default `priority: medium`.
   5. **Stale idea.** No learning trigger fired and the `idea` column has items > 14 days old. Pick the oldest. The "task" is: evaluate or drop. **Do not create a new NK card** — reference the existing one.
   6. **Fallback.** Nothing applies. **Create a new NK card** titled `Capture: what do you want to work on this week?` with `priority: medium`, `scheduled: true`. This is an invitation to add fresh ideas.

4. **Create or reference the task.**
   - **Cases 2, 3, 4, 6 (create):** follow the standard `/add-task` flow:
     1. Read `board/counter.json`, take `next_task_id` as N.
     2. Write back `next_task_id: N+1`.
     3. Write `tasks/NK-<N>.md` from `templates/task.md` with `scheduled: true` in frontmatter.
     4. Append a row to the `## Todo` section of `board/index.md` (cases 2/3/4/6 land in `todo`, not `idea`, since they're already triaged).
     5. Append `## [<date>] create | NK-<N> | <title>` to `board/log.md`.
   - **Cases 1, 5 (reference only):** no card creation, no counter increment. Carry the existing NK-ID forward.

5. **Write the daily scheduler log** to `memory/daily/<YYYY-MM-DD>-scheduled.md`:

   ```markdown
   # Scheduled — <YYYY-MM-DD>

   - **Case:** <1–6> (<short label>)
   - **State driving the pick:** <e.g., "NK-7 stuck 9 days", "GIL concept avg 5.2 in python-concurrency">
   - **Task:** <NK-ID> — <title>
   - **Created or referenced:** <created | referenced>
   - **Why (one line):** <reasoning the user can scan in 5 seconds>
   - **Notified:** <yes | no — reason if no>
   ```

6. **Send Telegram notification** via `scripts/notify.sh`:

   ```text
   🌅 Today's focus
   <NK-ID>: <title>
   <one-sentence why>
   ```

   Invocation: `./scripts/notify.sh "$(cat <<'EOF' ... EOF)"`. If the script is missing, or it warns about missing `TELEGRAM_BOT_TOKEN`/`TELEGRAM_CHAT_ID`, log `Notified: no — <reason>` in the daily log and continue. **Notification failure must never block** any other step. The notify script itself exits 0 on failure.

7. **Append to `board/log.md`:**

   ```text
   ## [<date>] schedule | <NK-ID> | case <N> | <one-line summary>
   ```

8. **Run `./scripts/git-sync.sh`** with message `schedule: <YYYY-MM-DD> case <N>`.

9. **Print a concise summary to stdout** (matters for the headless case):

   ```text
   Today's focus: <NK-ID> — <title>
   Reason: <why>
   Logged: memory/daily/<YYYY-MM-DD>-scheduled.md
   Notified: yes|no
   ```

## Notes

- **Single-shot.** Never create more than one task per run, never pick a second priority "while you're at it".
- **Stuck-task carryover.** If yesterday's pick was a stuck task and the same task is still the only candidate today, it's fine to surface it again — but check first.
- **Don't manage the user's reaction.** Whether the user moves, completes, or ignores the task is their decision. The scheduler has no follow-up state machine.
- **Headless-safe.** All file writes use deterministic content; no clarifying questions. The scheduler runs without a human at the prompt.
- **Fail soft.** A missing `progress.json`, empty board, or absent `memory/` is not an error — fall through the priority list to case 6.

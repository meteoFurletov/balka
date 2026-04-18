---
description: Saturday weekly review — unified learn + task + wiki summary
---

# /review

Run a weekly review that unifies learning progress, task movement, research, and wiki health into one narrative. Usage:

- `/review` — review the last 7 days
- `/review <N>d` — review the last N days (e.g., `/review 14d`)

## Prerequisites

- **Mode:** `use` mode.
- **Read `rubrics/grading.md`** if commenting on quiz scores.
- **Run `scripts/lint.sh`** first and include its output in the review.

## Steps

1. **Determine window.** Default 7 days ending today. Compute `since = today - window`.
2. **Read sources:**
   - `board/log.md` — filter entries with dates `>= since`.
   - `board/index.md` — current board state.
   - `epics/index.md` and each active `epics/EP-*.md` — active epic status.
   - Every `projects/*/progress.json` — quiz scores, completed levels, feedback entries.
   - `wiki/index.md` — for the lint check on orphans and stale pages.
   - `memory/MEMORY.md` — prior context to build on.
3. **Run `scripts/lint.sh`** and capture output. It reports orphan tasks, stuck tasks, stale wiki pages, broken links, and missing cross-references.
4. **Analyze.** Build these sections:
   - **Moved this week** — tasks that changed status. Group by new status.
   - **Stuck** — tasks in `in-progress` for > 7 days (check log entries).
   - **Ideas worth evaluating** — the 3 oldest items in the `idea` column.
   - **Learning progress** — for each active project: levels completed this window, quiz averages, weak concepts (avg < 7), feedback captured.
   - **Research done** — tasks that gained research content this window, plus new/updated wiki pages.
   - **Epic health** — for each active epic: task count by status, percent done, any blockers.
   - **Lint findings** — summarize the `scripts/lint.sh` output. Don't bury warnings.
   - **Connections** — surface non-obvious links. Examples:
     - "You finished Level 2 of `python-concurrency` — `NK-012` is ready to move to `in-progress`."
     - "Your research on `NK-007` touched event loops — consider a learning project on async patterns."
     - "Wiki page `concepts/idempotency` was referenced by 3 tasks this week — it may deserve a depth pass."
   - **Suggestions for next week** — 3–5 concrete next actions, ranked.
5. **Save the review** to `memory/daily/<YYYY-MM-DD>-review.md`. Header: `# Review — <YYYY-MM-DD> (window: Nd)`. Full body below.
6. **Update `memory/MEMORY.md`** with any durable insights surfaced this week. Keep `MEMORY.md` under 100 lines — if it's getting long, compress or archive older entries.
7. **Append to `board/log.md`:**
   `## [<date>] review | memory/daily/<YYYY-MM-DD>-review.md | <one-line summary>`
8. **Run `./scripts/git-sync.sh`** with message `review: <YYYY-MM-DD>`.
9. **Present a short summary** to the user in chat (not the full review file) — key numbers, 1–2 highlights, the top 3 suggestions, and a pointer to the saved file.

## Notes

- **Be direct, not cheerleading.** If a week was slow, say so without softening. The review's value is honesty.
- **Never invent activity.** If the log has nothing for a day, that day has nothing.
- **Connections are the point.** Anyone can list what moved. The review earns its keep by surfacing links the user would miss.
- **Lint is load-bearing.** Do not skip step 3. If `scripts/lint.sh` is missing or fails, report the error in the review and keep going.
- **Respect `memory/MEMORY.md`'s 100-line cap.** When compressing, keep the most recent and most referenced insights; move the rest into the dated review file for the archive.

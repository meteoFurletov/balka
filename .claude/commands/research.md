---
description: Research a topic and write findings into a task and/or the wiki
---

# /research

Do focused research on a topic, write findings into a task file, and optionally create or update a wiki page. Usage:

- `/research <topic> for NK-<N>` — research a topic, attach findings to that task
- `/research NK-<N>` — research whatever the task's `## Description` says
- `/research <topic>` — freeform; skip the task update, write straight to the wiki

## Prerequisites

- **Mode:** `use` mode.
- **Read `rubrics/research-quality.md` first.** Every time. Follow it.
- **Read `templates/wiki-page.md`** if the research may produce a new wiki page.

## Steps

1. **Understand the question.** Restate it in one sentence. If the user's request is ambiguous, ask one clarifying question before searching.
2. **Search `wiki/index.md`** for existing pages on this topic. If a relevant page exists, read it — your research should extend or update it, not duplicate.
3. **Gather.** Use web search, read any files the user points to in `raw/`, or draw on documented knowledge. Prefer primary sources. Date-stamp time-sensitive claims.
4. **Synthesize** findings per `rubrics/research-quality.md`. Be direct. Caveat uncertain claims.
5. **Write to the task** (if a task was specified): append or replace the task's `## Research` section using the structure in `rubrics/research-quality.md`. Update `updated:` in the task frontmatter.
6. **Decide on wiki pages.** For each candidate:
   - **If a relevant wiki page exists** → update it. Add new details, bump `updated:`, append `[[NK-<N>]]` to `linked_tasks` if not already there.
   - **If the research produces reusable knowledge and no page exists** → create a new page under `wiki/concepts/`, `wiki/entities/`, `wiki/sources/`, or `wiki/comparisons/` (pick the best fit). Use `templates/wiki-page.md`. Add `[[NK-<N>]]` to `linked_tasks` if applicable.
   - **If the research is task-specific trivia** → do not create a wiki page.
7. **Update `wiki/index.md`** if you created a new page. Add a single-line entry under the correct category section: `- [[<category>/<slug>]] — <one-line hook>`.
8. **Cross-link.** If you created a wiki page and attached it to a task, add the wiki page slug to the task's `linked_wiki` frontmatter array: `linked_wiki: [concepts/event-loop]`.
9. **Append to `board/log.md`** (once per invocation, combining all the work):
   `## [<date>] research | NK-<N> | <one-line summary>` — or `## [<date>] research | wiki | <one-line summary>` if no task was involved.
10. **Run `./scripts/git-sync.sh`** with message `research: NK-<N> <topic>` (or `research: wiki/<slug>` for freeform).
11. **Report to the user**: what you wrote where, which wiki pages changed, and the recommendation if one was requested.

## Notes

- **Keep the research section dense.** 150–500 words for task research unless the topic genuinely needs more. The wiki absorbs detail; the task holds the answer.
- **Never invent URLs or benchmarks.** If you don't know the source, say so.
- **Check for contradictions.** If what you found conflicts with an existing wiki page, flag it to the user and ask how to resolve before overwriting.
- **Don't auto-create learning projects** from research, even when you spot a knowledge gap. Mention it and let the user decide.

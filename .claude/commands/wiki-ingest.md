---
description: Ingest a source document from raw/ into the wiki
---

# /wiki-ingest

Summarize a source document into `wiki/sources/` and cross-link it with related concept and entity pages. Usage:

- `/wiki-ingest raw/articles/<filename>`
- "ingest raw/articles/<filename>"
- "ingest <url>" — in this case, fetch and save to `raw/articles/<slug>.md` first, then ingest

## Prerequisites

- **Mode:** `use` mode.
- **Read `rubrics/research-quality.md`.** Source summaries follow the same honesty standards.
- **Read `templates/wiki-page.md`.** Source pages follow the same template with `category: sources`.
- **raw/ is immutable.** Never edit files in `raw/`. Only read and cite them.

## Steps

1. **Confirm the source exists.** If the user passed a URL, fetch it and save the content to `raw/articles/<slug>.md` with a one-line header noting the URL and fetch date. If the user passed a local path, read it.
2. **Pick a slug.** Kebab-case, derived from the source title (e.g., `karpathy-ai-agents-2025`).
3. **Check for duplicates.** Read `wiki/index.md` to see if this source was already ingested. If yes, ask the user whether to update or skip.
4. **Read the source carefully.** Summarize per `rubrics/research-quality.md`:
   - **Summary** (100–300 words): what the source argues, its main claims, its structure.
   - **Key points** as bullets. Keep quotes minimal and marked as quotes.
   - **Relevance / why it's in the wiki:** one line on what future questions it helps answer.
5. **Create `wiki/sources/<slug>.md`** using `templates/wiki-page.md` with `category: sources`. Frontmatter:
   - `title`: the source's actual title
   - `tags`: topic tags
   - `linked_tasks: []`
   - `linked_notes: []`
   - A `source:` field with the original URL or file path
6. **Update related concept/entity pages.** For each major concept the source introduces or illuminates:
   - If a `wiki/concepts/<slug>.md` exists, add `- [[sources/<slug>]]` to its `## References` and bump `updated:`.
   - If no concept page exists but one is clearly warranted, create it per `templates/wiki-page.md` and link both ways.
   - Don't go overboard — one source shouldn't spawn a dozen new pages. If in doubt, leave a note in the source page's body and let a future `/research` invocation create the concept page when it's actually needed.
7. **Update `wiki/index.md`:** add a line under `## Sources`: `- [[sources/<slug>]] — <one-line hook>`. Add lines for any new concept pages too.
8. **Append to `board/log.md`:**
   `## [<date>] ingest | wiki/sources/<slug> | <source title>`
9. **Run `./scripts/git-sync.sh`** with message `wiki: ingest <slug>`.
10. **Report to the user**: source page path, which concept/entity pages were updated or created, and any open questions the source raised.

## Notes

- **Don't over-interpret.** Source summaries should faithfully represent the source's claims, not mix in your own analysis. Analysis belongs in `concepts/` or `comparisons/`.
- **Quotes must be exact and marked.** If you can't copy verbatim, paraphrase without quote marks.
- **Sensitive sources:** if the source contains anything that shouldn't go to a public repo, flag it to the user before committing.
- **If the fetch fails** (URL ingestion), report the error and stop. Don't invent content.

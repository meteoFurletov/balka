# Wiki Page Template

The wiki is the shared knowledge layer. Pages live in `wiki/<category>/<slug>.md` and are indexed in `wiki/index.md`.

## Categories

- `wiki/concepts/` — ideas, frameworks, mental models
- `wiki/entities/` — specific tools, people, products, companies
- `wiki/sources/` — summaries of articles, papers, videos, books
- `wiki/comparisons/` — analysis pages that compare two or more things

## File Naming

`wiki/<category>/<slug>.md` using kebab-case slugs (e.g., `wiki/concepts/progressive-disclosure.md`).

## Format

```markdown
---
title: <Full Title>
category: <concepts | entities | sources | comparisons>
created: <YYYY-MM-DD>
updated: <YYYY-MM-DD>
tags: [tag-1, tag-2]
linked_tasks: []
linked_notes: []
---

# <Title>

## Summary

One paragraph. What is this, why does it matter, and what is the one thing to remember? Someone reading only this should understand the gist.

## Details

The full explanation. Use subheadings when the page gets long. Include:
- Definitions
- Mechanisms / how it works
- Concrete examples
- Tradeoffs or failure modes (where relevant)

## References

- [[sources/<source-slug>]] — external sources this page draws from
- [[concepts/<related-concept>]] — related wiki pages (Obsidian-style links)

## Linked Tasks

<!-- Maintained by /research and /link-task. -->

- [[NK-XXX]]: <task title>

## Linked Notes

<!-- Notes from learning projects that reference this page. -->

- [[projects/<slug>/notes/L<level>-<topic>]]
```

## Guidelines

- **Summary first, always.** The summary is load-bearing — future queries may read only the summary to decide if the full page is relevant.
- **Link generously.** Use `[[wiki-links]]` to connect related pages. The wiki compounds value through connections.
- **One idea per page.** If a page grows beyond ~1000 words and covers multiple distinct ideas, split it.
- **Sources are primary-source summaries**, not original commentary. Keep interpretation in `concepts/` or `comparisons/`.
- **Update `updated` on every edit.** This lets the lint check surface stale pages.
- Pages should survive out of context — assume the reader has not read any other wiki page.

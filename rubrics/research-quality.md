# Research Quality Rubric

Standards for research output in `/research` and `/wiki-ingest`. Read this before producing any research content.

## Goals

Research should:

1. **Answer the actual question.** If the task says "evaluate Plane for self-hosting", the output should let the user make a deploy/no-deploy decision — not just summarize what Plane is.
2. **Compound over time.** Whenever the research has reusable value beyond one task, file it (or link it) into `wiki/` so future questions benefit.
3. **Be traceable.** Every claim that isn't common knowledge has a source. Sources live in `wiki/sources/` or inline links.
4. **Be honest about uncertainty.** If something can't be verified, say so. Never fabricate benchmarks, version numbers, or quotes.

## Structure

Research written into a task file (`## Research` section) follows this shape:

```markdown
## Research

**Question:** <one sentence restating what we're trying to learn>

**TL;DR:** 2–4 sentences with the answer or current best guess.

**Key findings:**
- Fact 1 — [source](url) or [[wiki/sources/slug]]
- Fact 2 — …
- Fact 3 — …

**Tradeoffs / Open questions:**
- What's unclear, risky, or depends on things we don't know yet.

**Recommendation:** (if the task asks for a decision)
One paragraph: what to do and why. Be direct.

**Related:**
- [[wiki/concepts/<slug>]] — related concept pages
- [[NK-XXX]] — related tasks
```

Research written as a wiki page follows `templates/wiki-page.md`.

## Source Handling

- **Prefer primary sources.** Official docs, source code, papers, vendor blog posts beat random articles.
- **Cite inline** when the claim matters. `Plane supports SSO (source: [plane docs](https://…))`.
- **Summarize sources into `wiki/sources/<slug>.md`** when you expect to cite them again or the source has broad value beyond this one task. Keep the summary faithful — no editorializing.
- **Don't fabricate URLs.** If you don't know the exact link, say "official docs" without inventing one.
- **Date-stamp fast-moving topics.** For anything about pricing, versions, or market state, write "(as of YYYY-MM)" next to the claim.

## When to Create Wiki Pages

Create a wiki page when any of these are true:

- The research introduces a concept you expect to reference from multiple tasks or notes.
- You needed to explain something from first principles to answer the question — that explanation is reusable.
- You compared 2+ options and the comparison is useful outside this one decision.
- A source document has broad value and should be summarized for future queries.

Do NOT create a wiki page for:

- Trivia specific to this task (versions, config snippets for this one deploy, etc.)
- Unverified rumors or speculation
- Content that duplicates an existing wiki page — update the existing page instead.

## Quality Bar

Before writing research to a file, ask:

1. **Would a busy version of the user find this useful in 6 months?** If no, compress it.
2. **Could I defend every non-obvious claim?** If no, caveat it.
3. **Did I link to what already exists?** Search `wiki/index.md` before creating new pages.
4. **Is the recommendation actionable?** Vague recommendations waste everyone's time.

## Length

- **Task research:** 150–500 words unless the topic genuinely needs more. Dense beats long.
- **Wiki concept pages:** 300–1000 words. Summary at the top, details below, links out.
- **Wiki source summaries:** 100–300 words. Enough to decide whether to read the full source.

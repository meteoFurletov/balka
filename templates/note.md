# Note Template

When generating a note, follow this structure. Notes should be comprehensive enough to serve as a standalone reference.

## File Naming

Notes are depth-aware. Name files as `<topic>-L<level>.md`:
- `threading-L1.md` — Level 1 fundamentals
- `threading-L3.md` — Level 3 advanced depth

If no level is specified, default to the level the user is currently working on.

## Format

```markdown
---
title: "<Note Title>"
module: "<Module name it belongs to>"
level: <1-4>
tags: [tag1, tag2, tag3]
created: <date>
---

# <Note Title>

## TL;DR

A 2-3 sentence summary of the key takeaway. Someone should be able to read just this and understand the core concept.

## Core Concepts

The main explanatory content. Use subheadings to organize.

### <Subtopic A>

Explanation with examples.

### <Subtopic B>

Explanation with examples.

## Practical Examples

At least 2-3 concrete, real-world examples or code snippets demonstrating the concepts.

## Common Pitfalls

What do people get wrong about this topic? What are the misconceptions?

## Connections

- **Related to:** [[other-note-name]] — how this connects to other topics at the same level (horizontal)
- **Builds on:** [[prerequisite-note-L1]] — what you should understand first (vertical — lower level)
- **Leads to:** [[next-note-L3]] — what to study next (vertical — higher level)

## Key Takeaways

- Bullet point summary of the 3-5 most important things to remember
```

## Depth Guidelines

Each level targets a different depth:

| Level | Depth | Focus |
|-------|-------|-------|
| L1 | Fundamentals | What is X, how does it work, basic usage |
| L2 | Intermediate | How X interacts with Y, comparisons, patterns |
| L3 | Advanced | Real-world application, failure modes, edge cases |
| L4 | Expert | Architecture decisions, tradeoffs, synthesis |

A Level 1 note should be accessible to beginners. A Level 3 note can assume the reader has L1 and L2 knowledge.

## Connection Types

Notes connect in two dimensions:
- **Horizontal** — same level, different topic (e.g., `threading-L2.md` ↔ `synchronization-L2.md`)
- **Vertical** — same topic, different depth (e.g., `threading-L1.md` → `threading-L3.md`)

Always include both connection types in the Connections section when applicable notes exist.

## General Guidelines

- Notes should be **1000-2000 words** — thorough but not exhausting
- Use **code examples** when the topic is technical
- Use **analogies** to explain abstract concepts
- The **Connections** section should reference actual other notes in the project when they exist
- Write for someone who has read the curriculum but hasn't studied this topic yet

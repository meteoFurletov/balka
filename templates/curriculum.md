# Curriculum Template

When generating a curriculum, follow this exact structure.

## Format

```markdown
# <Topic> — Learning Curriculum

**Experience level:** <what the user reported>
**Created:** <date>
**Modules:** <count>

---

## Module 1: <Module Title>

A 1-2 sentence description of what this module covers and why it matters.

### Level 1: Fundamentals
Concepts: <concept-a>, <concept-b>, <concept-c>, <concept-d>, <concept-e>, <concept-f>, <concept-g>

### Level 2: Intermediate
Concepts: <concept-h>, <concept-i>, <concept-j>, <concept-k>, <concept-l>, <concept-m>, <concept-n>

### Level 3: Advanced
Concepts: <concept-h>, <concept-i>, <concept-j>, <concept-k>, <concept-l>, <concept-m>, <concept-n>

### Level 4: Expert
Concepts: <concept-o>, <concept-p>, <concept-q>, <concept-r>, <concept-s>, <concept-t>, <concept-u>

## Module 2: <Module Title>
... (same structure)
```

## Guidelines

- **7 concepts per level, 4 levels per module** — this is the default
- Concepts should be **specific and assessable** — not vague topics but concrete things a learner should understand
  - Good: "thread safety guarantees of the GIL", "deadlock detection strategies"
  - Bad: "advanced threading", "miscellaneous topics"
- Each level should genuinely increase in depth:
  - Level 1: Core definitions, basic mechanisms, foundational "what is X" concepts
  - Level 2: Interactions, comparisons, "how X relates to Y" concepts
  - Level 3: Real-world application, failure modes, edge cases
  - Level 4: Architecture decisions, tradeoffs at scale, synthesis across concepts
- Concepts use **kebab-case** names: `thread-safety`, `gil-implications`, `lock-free-data-structures`
- Tailor concepts to the user's stated experience — skip what they already know
- Module titles should cover distinct aspects of the topic, not overlap
- **Curriculum is a living document** — later levels may be generated or adjusted based on quiz performance and user feedback (see adaptive level generation in CLAUDE.md)

# Flashcard Deck Template

Flashcard decks are generated from existing notes. Each deck is a markdown file that can be reviewed interactively or read as a reference.

## Format

```markdown
---
title: "Flashcards: <Topic>"
source_note: "<note-filename.md>"
card_count: <number>
created: <date>
---

# Flashcards: <Topic>

## Card 1
**Term:** <concept, keyword, or question>

**Definition:** <concise answer — 1-3 sentences max>

---

## Card 2
**Term:** <concept>

**Definition:** <answer>

---

... (continue for all cards)
```

## Interactive Review Flow

When the user wants to practice flashcards interactively:

1. Show only the **Term** side
2. Ask the user to explain/define it
3. Show the **Definition** and briefly assess their answer
4. Move to the next card
5. At the end, summarize: how many they got right, which ones to revisit

## Guidelines

- Extract **10-20 cards** per note — focus on the most important terms and concepts
- **Terms** can be:
  - A keyword or phrase: "Mutex"
  - A conceptual question: "What's the difference between concurrency and parallelism?"
  - A scenario: "When would you use X instead of Y?"
- **Definitions** should be self-contained — understandable without reading the full note
- Order cards from fundamental to advanced

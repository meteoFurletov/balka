# Note Quality Standards

Follow these standards when generating or evaluating notes.

## Required Sections

Every note must have all sections from `templates/note.md`. Missing sections mean the note is incomplete.

## Quality Criteria

### Accuracy

- All technical claims must be correct
- Code examples must be syntactically valid and functional
- If uncertain about a detail, say so explicitly rather than guessing

### Depth

- Notes should go beyond surface-level explanations
- Include the "why" — not just "what X is" but "why X exists and when to use it"
- Address edge cases and common misconceptions

### Practical Value

- At least 2 concrete examples per note
- Examples should be realistic, not toy problems
- Code examples should be copy-paste-runnable where possible

### Connections

- Every note should reference at least 1 other note in the project (if others exist)
- Connections should explain the relationship, not just link
- Include both **horizontal** (same level, different topic) and **vertical** (same topic, different level) connections when applicable

### Readability

- Use clear, direct language
- Break up long paragraphs
- Use code blocks, lists, and subheadings for structure
- Target length: 1000-2000 words (shorter is fine if the topic is narrow)

## Anti-Patterns to Avoid

- **Filler text:** "In this note, we will explore..." — just start explaining
- **Unsupported claims:** "This is the best approach" — say why or qualify it
- **Wall of text:** If a section is longer than ~200 words without a break, add structure
- **Orphan notes:** Notes that don't reference any other note in the project

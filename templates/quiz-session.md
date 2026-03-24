# Quiz Session Template

When running a quiz, follow this interaction pattern and save results in this format.

## Interaction Flow

1. Identify which module and level the user wants to be quizzed on
2. Read `progress.json` to check which questions are unanswered for that level
3. Randomly select up to `batch_size` questions from the unanswered pool
4. Present questions **ONE AT A TIME**:
   - Show the question number (from the curriculum) and text
   - Show progress context: "Question X of Y in this batch (Z/10 answered for this level)"
   - Wait for the user to answer
   - Do NOT reveal the grade yet — just acknowledge and move on
5. After the last question in the batch, grade all answers using `rubrics/grading.md`
6. Present a summary with per-question feedback
7. Show running level progress: "You've now answered N/10 questions, running average: X.X/10"
8. If the level is now complete (all 10 answered), congratulate and suggest the next level
9. Save the session file and update `progress.json`

## Saved Session Format

```markdown
---
project: "<project-slug>"
module: "<Module N: Title>"
level: "<Level N: Title>"
date: <YYYY-MM-DD>
batch: <batch-number>
questions_answered_before: <N/10>
questions_answered_after: <N/10>
batch_score: <average of this batch's scores, 0-10>
running_level_score: <average of ALL answered questions for this level>
level_complete: <true/false>
---

# Quiz: <Module> — <Level> (Batch <N>)

## Results Summary

**Batch score: <X.X>/10** | **Level progress: <N>/10 answered (avg: <X.X>/10)** | **Date:** <date>

## Question-by-Question

### Q<original_number>: <question text>

**Your answer:** <what the user typed>

**Score:** <0-10>/10

**Feedback:** <explanation of grade>

**Pro tip:** <advanced insight related to this question>

---

### Q<original_number>: <question text>
... (same structure)
```

## File Naming

Session files use the format: `<YYYY-MM-DD>-<module-slug>-<level-slug>-batch-<N>.md`

Example: `2025-01-15-module-1-level-1-batch-2.md`

The batch number is sequential per module/level (count of existing sessions + 1).

## Guidelines

- Be encouraging but honest — don't inflate scores
- If the user says "I don't know" or skips, score it 0 but give a helpful explanation
- The **Pro tip** should teach something beyond what the question asks
- If the user answers in a different language than the question, that's fine — grade the content
- Questions are selected randomly from the unanswered pool — don't go in curriculum order

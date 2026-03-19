# Quiz Session Template

When running a quiz, follow this interaction pattern and save results in this format.

## Interaction Flow

1. Identify which module and level the user wants to be quizzed on
2. Read the curriculum to get the questions for that module/level
3. Present questions **ONE AT A TIME**:
   - Show the question number and text
   - Wait for the user to answer
   - Do NOT reveal the grade yet — just acknowledge and move on
4. After the last question, grade all answers at once using `rubrics/grading.md`
5. Present a summary with per-question feedback
6. Save the session file

## Saved Session Format

```markdown
---
project: "<project-slug>"
module: "<Module N: Title>"
level: "<Level N: Title>"
date: <YYYY-MM-DD>
overall_score: <average of all scores, 0-10>
---

# Quiz: <Module> — <Level>

## Results Summary

**Score: <X.X>/10** | **Date:** <date>

## Question-by-Question

### Q1: <question text>

**Your answer:** <what the user typed>

**Score:** <0-10>/10

**Feedback:** <explanation of grade>

**Pro tip:** <advanced insight related to this question>

---

### Q2: <question text>
... (same structure)
```

## Guidelines

- Be encouraging but honest — don't inflate scores
- If the user says "I don't know" or skips, score it 0 but give a helpful explanation
- The **Pro tip** should teach something beyond what the question asks
- If the user answers in a different language than the question, that's fine — grade the content

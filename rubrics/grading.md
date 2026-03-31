# Quiz Grading Rubric

Use this rubric to score quiz answers on a 0-10 scale. Be consistent and fair.

## Scoring Scale

| Score | Label | Criteria |
| ----- | ----- | -------- |
| 0 | No answer | Blank, "I don't know", or completely irrelevant |
| 1-2 | Minimal | Shows vague awareness of the topic but no real understanding |
| 3-4 | Partial | Identifies some relevant concepts but with significant gaps or errors |
| 5-6 | Adequate | Demonstrates basic understanding; core idea is correct but lacks depth or has minor errors |
| 7-8 | Good | Solid understanding with relevant details; may miss edge cases or advanced nuances |
| 9 | Excellent | Comprehensive, accurate, well-structured; demonstrates deep understanding |
| 10 | Expert | Everything in 9, plus original insight, real-world awareness, or expert-level nuance |

## Grading Principles

- **Grade the substance, not the style.** A terse but correct answer scores higher than a verbose but vague one.
- **Partial credit is the default.** If the answer gets the main idea right but misses details, that's a 5-7, not a 0.
- **Adjust for level.** A Level 1 question answered with Level 3 depth is still a 10. A Level 4 question answered at Level 1 depth is a 3-4.
- **Wrong is wrong.** If the core claim is factually incorrect, cap the score at 4 regardless of how well-written it is.
- **"I think..." is fine.** Don't penalize uncertainty in phrasing if the content is correct.

## Feedback Guidelines

- **Explanation:** Tell the user specifically what they got right and what was missing. Never just say "good answer" or "wrong."
- **Pro tip:** Provide one advanced insight related to the question — something they wouldn't learn from a basic tutorial. This is the most valuable part of the feedback.

## Score Aggregation

### Concept Score
Each concept has an array of scores. The **concept average** is the arithmetic mean of all scores for that concept, rounded to one decimal place.

### Level Completion Score
A level is complete when all 7 concepts have at least one score. The **overall level score** is the arithmetic mean of all concept averages, rounded to one decimal place.

### Mastery Threshold

| Overall Level Score | Verdict | Action |
| ------------------- | ------- | ------ |
| >= 7.0 | **Mastery achieved** | Congratulate the user. Suggest moving to the next level. |
| < 7.0 | **Needs review** | Suggest revisiting the notes for this module, then retrying the level. Highlight the weakest concepts (lowest averages) as focus areas. |

When reporting a completed level, always state the verdict explicitly.

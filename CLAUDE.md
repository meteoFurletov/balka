# Interactive Learning System

This system operates in two modes. The user switches between them explicitly.

## Modes

### `learn` mode (default)

You are an **AI tutor**. You follow the templates and rubrics exactly. You read/write files in `projects/`. You never modify files in `templates/`, `rubrics/`, or system-level files.

**Activation:** User says "learn", "study", "quiz me", "start a project", or anything related to learning content.

**Branch:** Always work on the `learning` branch. If not on it, run `git checkout learning` before doing anything.

### `dev` mode

You are a **software developer** building and improving this learning system. You modify templates, rubrics, CLAUDE.md, scripts, and any system infrastructure. You treat this repo as a codebase.

**Activation:** User says "dev", "dev mode", "let's work on the system", or anything about improving/changing the tool itself.

**Branch:** Always work on the `main` branch. If not on it, run `git checkout main` before doing anything.

**Always confirm which mode you're in if ambiguous.**

---

## Directory Layout

```text
CLAUDE.md              ← System config (dev: editable, learn: read-only)
README.md              ← Project documentation (dev: editable)
templates/             ← Content formats (dev: editable, learn: read-only)
  curriculum.md
  note.md
  quiz-session.md
  flashcard-deck.md
  progress.json        ← Schema for progress tracking
rubrics/               ← AI behavior standards (dev: editable, learn: read-only)
  grading.md
  note-quality.md
scripts/               ← Utility scripts (dev: create and modify)
projects/              ← Learning content (learn: read/write, dev: don't touch)
  <slug>/
    curriculum.md
    progress.json
    notes/
    flashcards/
    quizzes/
```

---

## Learn Mode — Commands

### "Start a new project on <topic>"

1. Ask about their experience level and desired module count (default: 5)
2. Create `projects/<slug>/` with full directory structure
3. Read `templates/curriculum.md`, then generate `curriculum.md`
4. Initialize `progress.json` from `templates/progress.json`

### "Generate notes for <topic/module>"

1. Read project's `curriculum.md` to find the relevant section
2. Read `templates/note.md` and `rubrics/note-quality.md`
3. Generate and save to `projects/<slug>/notes/<note-slug>.md`
4. Update `progress.json`

### "Quiz me on <module/level>"

1. Read `curriculum.md` for the questions
2. Present questions **one at a time** — wait for user's answer before continuing
3. After all questions, grade using `rubrics/grading.md`
4. Save session to `projects/<slug>/quizzes/<YYYY-MM-DD-module-level>.md`
5. Update `progress.json`

### "Flashcards for <topic>"

1. Read the relevant note from `notes/`
2. Read `templates/flashcard-deck.md`
3. Generate and save to `projects/<slug>/flashcards/<topic-slug>.md`
4. Run interactive review: show term → user responds → reveal answer

### "Show my progress"

1. Read `progress.json` for current or all projects
2. Summarize: modules completed, scores, notes created, weak areas

### "Export" / "Push" / "Save"

1. Run `./scripts/git-sync.sh` with a descriptive message

### "Sync from dev" / "Update system"

1. While on the `learning` branch, rebase onto `main` to pick up template/rubric improvements:
   ```
   git fetch origin
   git rebase main
   ```
2. If conflicts arise, resolve them preserving learning content in `projects/`
3. Force-push the rebased learning branch: `git push --force-with-lease`

---

## Git Workflow

### Branch structure

- **`main`** — development branch. System files live here (CLAUDE.md, templates/, rubrics/, scripts/, README.md). Dev mode works here.
- **`learning`** — learning branch, forked from main. Learning content lives here (projects/). Learn mode works here.

### Learn mode git rules

- **Auto-commit after every file change.** After creating or modifying any file in `projects/` (notes, quizzes, flashcards, progress.json), immediately run `./scripts/git-sync.sh` with a descriptive message. Every single time — changes should appear on GitHub immediately.
- Commit message format examples:
  - `notes: create threading-basics for python-concurrency`
  - `quiz: module-1-level-2 score 7.3/10`
  - `flashcards: create threading-basics deck`
  - `progress: update python-concurrency`

### Dev mode git rules

- Commit after each meaningful change, but **do not auto-push** — let the user decide.
- **After every commit to `main`, automatically rebase `learning` onto `main`** so the learning branch always has the latest system files. Steps:
  1. `git checkout learning`
  2. `git rebase main`
  3. `git checkout main` (return to dev branch)
  4. Inform the user that `learning` was rebased. Remind them to force-push both branches when ready.
- Use `./scripts/git-sync.sh` for quick commits, or commit manually for more control.

---

## Dev Mode — Guidelines

### What you can do

- Create, modify, delete files in `templates/`, `rubrics/`, `scripts/`, root-level files
- Add new features to the system (new templates, new commands, automation scripts)
- Refactor existing templates and rubrics
- Update this CLAUDE.md
- Write and run tests or validation scripts
- Set up git hooks, CI, or any tooling

### What you should not do

- Modify files in `projects/` — that's user learning data
- Break backward compatibility with existing progress.json schemas without migration

### Development principles

- **Keep CLAUDE.md as a map**, not an encyclopedia. Point to files, don't inline everything.
- **Templates define structure**, rubrics define quality. Keep them separate.
- **Test changes** by running a quick simulated interaction before committing.
- **Document changes** — update README.md when adding features.
- **Commit often** with clear messages: `feat: add spaced repetition tracking`, `fix: quiz grading rubric edge case`

### Adding new features

When adding a new capability:

1. Create/update the template in `templates/`
2. Create/update any rubric in `rubrics/`
3. Add the command documentation to the Learn Mode section above
4. Update `progress.json` schema if needed (and note the migration)
5. Update README.md

---

## Rules (both modes)

- **Read the relevant template/rubric before generating content.** Every time. Don't rely on cached knowledge.
- **One quiz question at a time.** Never dump all questions at once.
- **Match the user's language.** If they write in Russian, respond and generate in Russian.
- **File names use kebab-case.** e.g., `python-concurrency`, `basic-data-structures`
- **Update progress.json after every meaningful action** in learn mode.
- **Auto-commit in learn mode.** After every file creation or modification in `projects/`, run `./scripts/git-sync.sh`. See Git Workflow section.
- **Check your branch.** Learn mode → `learning`. Dev mode → `main`. Switch if wrong.
- **When unsure what the user wants**, check `progress.json` and suggest the next logical step.

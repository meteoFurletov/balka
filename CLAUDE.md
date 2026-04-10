# Personal Learning & Task Management System

A file-based system powered by Claude Code. Two modes, one repo.

## Modes

| Mode | Role | Activators | Branch |
|------|------|-----------|--------|
| **use** (default) | AI tutor + task manager + researcher | "learn", "study", "quiz me", "start a project", "add task", "move", "research", "board", "review" | `learning` |
| **dev** | System developer | "dev", "dev mode", "let's work on the system" | `main` |

**Always confirm mode if ambiguous.** Never cross-write between mode scopes. Switch branches before acting if you're on the wrong one.

---

## Directory Map

```text
CLAUDE.md              ← System router (dev: editable, use: read-only)
README.md              ← Project documentation
USER.md                ← Personal context (dev: editable, use: read-only)
templates/             ← Content format definitions (dev: editable, use: read-only)
  curriculum.md
  note.md
  task.md
  epic.md
  wiki-page.md
  progress.json
rubrics/               ← Quality standards (dev: editable, use: read-only)
  grading.md
  note-quality.md
scripts/               ← Automation
  git-sync.sh          ← Auto-commit and push
.claude/commands/      ← Slash command definitions
projects/              ← Learning content (use: read/write)
  <slug>/
    curriculum.md
    progress.json
    notes/
board/                 ← Kanban state (use: read/write)
  index.md             ← Task catalog by status
  counter.json         ← Next IDs for tasks and epics
  log.md               ← Append-only activity log
tasks/                 ← One file per task (use: read/write)
  NK-<N>.md
epics/                 ← Epics (use: read/write)
  index.md
  EP-<N>.md
wiki/                  ← Knowledge base (use: read/write)
  index.md
  concepts/
  entities/
  sources/
  comparisons/
raw/                   ← Source documents (use: read/write)
memory/                ← Curated context (use: read/write)
  MEMORY.md
  daily/
```

---

## Use Mode — Commands

### Learning

- **"Start a new project on <topic>"** — ask experience level and module count (default 5). Create `projects/<slug>/`, generate curriculum from `templates/curriculum.md`, init `progress.json`.
- **"Generate notes for <topic/module>"** — read project's `curriculum.md`, `templates/note.md`, and `rubrics/note-quality.md`. Save to `projects/<slug>/notes/L<level>-<topic>.md`. Include horizontal and vertical connections. Link to relevant wiki pages if they exist.
- **"Quiz me on <module/level>"** — see [Quiz Flow](#quiz-flow) below.
- **"Flashcards for <topic>"** — generate on the fly from the relevant note. Conversation only, no files saved.
- **"Show my progress"** — read `progress.json`, summarize modules, scores, weak areas.

### Task management

All task and epic commands live in `.claude/commands/`. Read the command file before executing.

- **`/add-task`** or "add task: <title>" — see `.claude/commands/add-task.md`
- **`/move-task`** or "move NK-XXX to <status>" — see `.claude/commands/move-task.md`
- **`/add-epic`** or "add epic: <title>" — see `.claude/commands/add-epic.md`
- **`/link-task`** or "link NK-XXX to EP-Y" — see `.claude/commands/link-task.md`

Valid task statuses: `idea` → `todo` → `in-progress` → `done`.

Task and epic IDs come from `board/counter.json`. Always read, increment, write back.

### Sync

- **"Export" / "Push" / "Save"** — run `./scripts/git-sync.sh`.
- **"Sync from dev" / "Update system"** — on `learning`, `git fetch origin && git rebase main`, then `git push --force-with-lease`.

---

## Quiz Flow

A continuous one-at-a-time conversation — no batches, no saved files.

1. Read `progress.json` for the requested level's state. If no level specified, pick the next incomplete one. If already complete, ask if the user wants to redo it (resets that level).
2. Read `curriculum.md` for the concept list.
3. Pick the next concept via **smart selection**:
   1. Untouched concepts (curriculum order)
   2. Weak/declining concepts (avg < 7)
   3. Least-recently-tested
   4. Mastered concepts (avg ≥ 8) only if nothing else remains
4. **Generate a fresh question on the fly** for that concept — never pre-written. Difficulty matches level: L1 definitional, L2 comparative, L3 applied, L4 synthesis.
5. Wait for the answer. Grade using `rubrics/grading.md`. Give feedback and a pro tip.
6. Save the numeric score (0–10) to `progress.json` immediately. Never save the user's text answer.
7. Show running stats: "Concepts scored: N/7 — running average: X.X/10". Present the next question.
8. Stop on "enough"/"stop"/"that's it" or when the level is complete (7 concepts scored).
9. On level complete → run the **feedback gate**: show strong/weak concepts, ask for freeform feedback, store it keyed by level (e.g., `level-1-feedback`), then reflective summary per `rubrics/grading.md`.
10. On finish or stop → `./scripts/git-sync.sh`.

### Adaptive level generation

When the next level doesn't exist, shape it from: (1) weak concepts from the previous level carried forward, (2) user feedback from the feedback gate, (3) natural topic progression. Append to `curriculum.md` with a `<!-- Shaped by: ... -->` comment and update `progress.json`.

---

## Dev Mode — Guidelines

### Scope

- **Can modify:** `templates/`, `rubrics/`, `scripts/`, `.claude/commands/`, `CLAUDE.md`, `README.md`, `USER.md`
- **Never touch:** `projects/`, `board/`, `tasks/`, `epics/`, `wiki/`, `raw/`, `memory/` — that's personal data.

### Principles

- **CLAUDE.md is a map**, not an encyclopedia. Point to files.
- **Templates define structure, rubrics define quality.** Keep them separate.
- **Don't break `progress.json` schema** without a migration.
- **Commit after each meaningful change.** Do NOT auto-push — let the user decide.
- **After committing to `main`, rebase `learning` onto `main`:** `git checkout learning && git rebase main && git checkout main`. Tell the user to force-push when ready.
- **Update README.md** when adding features.

---

## Global Rules

1. **Read the relevant template/rubric before generating.** Every time. No cached knowledge.
2. **One quiz question at a time.** Never batch.
3. **Match the user's language.** Russian in → Russian out.
4. **Kebab-case filenames** (`python-concurrency`, not `PythonConcurrency`).
5. **Auto-commit in use mode** after every file write in `projects/`, `board/`, `tasks/`, `epics/`, `wiki/`, `raw/`, `memory/`. Run `./scripts/git-sync.sh` with a descriptive message.
6. **Check your branch.** Use → `learning`. Dev → `main`.
7. **Task/epic IDs are sequential** — read `board/counter.json`, increment, write back before creating the file.
8. **Wiki uses Obsidian `[[wiki-links]]`** for cross-references.
9. **Link across layers.** Tasks link to wiki pages and learning projects. Notes link to wiki pages. The wiki is the shared knowledge layer.
10. **When unsure what the user wants**, check `progress.json` or `board/index.md` and suggest the next step.

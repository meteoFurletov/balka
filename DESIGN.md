# Design — Balka

Why this system is shaped the way it is. Read this before proposing structural changes.

The name **balka** comes from the dry erosional valleys of the Central Russian Upland — landforms that aren't dramatic or fast-moving, but that accumulate sediment over centuries until the soil becomes the richest in the region. That's the intent: a slow, compounding personal knowledge system. Not a productivity tool. A valley.

## Goals

1. **One place for learning, tasks, research, and knowledge.** The three activities compound when they share context. Separating them into different tools loses that.
2. **Files, not a database.** Plain markdown and JSON survive tool churn, diff cleanly in git, and can be read by any editor.
3. **AI as the interface, not the storage.** Claude Code reads and writes files; the files are the source of truth. If the AI vanishes tomorrow, the content is still yours.
4. **Compound over time.** Every quiz, research pass, and note should leave the system a little smarter. The wiki is the compounding layer.
5. **Low friction for the user, high structure for the AI.** The user types plain English; the AI follows strict templates, rubrics, and command flows.

## Non-goals

- **Not a team tool.** Everything assumes one user. Multi-user collaboration is out of scope.
- **Not a replacement for domain-specific tools.** For deep note-taking, pair this with Obsidian. For source control, git is underneath. For web search, use Claude's tools.
- **Not a general-purpose agent framework.** It does a narrow set of things well.

## Key Decisions

### One unified mode for actual use

Earlier drafts split learning and task management into separate modes. That was wrong. The value of the system is in the *connections* between learning and tasks: a finished quiz level suggests moving a linked task forward; research on a task reveals a knowledge gap worth learning. Separate modes hide those connections. So `use` mode owns everything; `dev` mode is reserved for system changes.

### Public harness + private fork

Templates, rubrics, commands, and scripts are a clean piece of OSS. Personal content (projects, tasks, wiki, memory) is not. Splitting them into "upstream harness" vs "your fork" lets the harness evolve publicly while personal data stays private — and lets others adopt the system without inheriting someone else's content.

The split is enforced by convention, not tooling: the harness lives in `templates/`, `rubrics/`, `scripts/`, `.claude/commands/`, `CLAUDE.md`, `README.md`, `DESIGN.md`. Everything else is fork-local. `.gitkeep` files keep the empty directories in upstream so forks start with the right scaffolding.

### Fork, not a second repo or a second branch

The harness lives upstream; personal data lives in your fork of the upstream repo on its own `main`. One fork, one branch. Earlier drafts used a two-branch model (`main` for harness, `learning` for personal data rebased on it), but rebasing a long-lived branch on every upstream pull was noisy and error-prone. A fork is the natural unit: clone once, pull from `upstream` when the harness improves, commit personal data on your own `main`.

### CLAUDE.md as router, not encyclopedia

Claude Code loads `CLAUDE.md` on every session. If it grows past ~200 lines, it starts wasting context on rarely-needed detail. So `CLAUDE.md` is a router: it defines modes, maps directories, lists commands, and delegates everything else to files in `templates/`, `rubrics/`, and `.claude/commands/`. Those files are read on-demand only when a specific command runs.

### Templates define structure, rubrics define quality

Two different concerns. A template says "a task file has these fields and this layout". A rubric says "a good research summary cites primary sources and date-stamps fast-moving claims". Mixing them makes both harder to maintain and harder to update independently. Keeping them separate means you can tune the grading rubric without touching the curriculum template.

### Concept-based quizzing, not question banks

Storing pre-written questions biases the system toward whatever questions you happened to write the first time. Generating questions on the fly from a *concept list* lets the AI adapt to what you've already been tested on, pick fresh angles, and scale to any domain without a library. Scores are stored per concept, not per question — the concept is the durable unit of measurement.

### Wiki as the shared knowledge layer

Tasks, notes, and research all want a place to put reusable knowledge. Without a shared layer, the same concept gets re-explained in five tasks. With one, the first task creates the page and the next four link to it. The wiki isn't a separate product — it's the cross-cut everything else feeds into. Bidirectional `[[category/slug]]` links are enforced by convention so the graph stays navigable from both directions.

### Append-only activity log

`board/log.md` is append-only. Never rewrite it. Why: the log is the raw material for `/review`. Rewriting history breaks the review's ability to see what actually happened.

### No pre-written quiz questions, no saved answers

Questions are generated fresh. User answers are never saved — only the numeric score (0–10) per concept. Rationale: saved answers become a privacy liability and add no value (the AI can always regenerate a similar question). Scores are the only thing worth keeping.

### Auto-commit in `use` mode, manual commit in `dev` mode

In `use` mode, every file write runs `scripts/git-sync.sh`. The user shouldn't have to think about git. In `dev` mode, changes are structural and deserve a human decision about when to push. Auto-push in `dev` mode would let sloppy changes reach the public repo.

### The weekly review is the accountability loop

Without `/review`, the system is a pile of files. The review is what turns the pile into a habit: it forces honesty about what moved and what's stuck, it surfaces connections between learning and tasks, and it runs lint so the system doesn't rot. Skipping the review is the failure mode to watch.

### The scheduler is a push, not a pull

Without scheduling, the system waits for the user to open Claude Code and decide what to do. Procrastination wins. The `/schedule` command inverts this: every morning, Claude analyzes state and picks one concrete action, writes it to the board, and pings Telegram. The user wakes up to "today's focus: quiz on GIL" instead of a blank prompt.

Design constraints:

- **One task per day, not a bundle.** Procrastination grows with scope. A single five-minute task is harder to avoid than a list.
- **Idempotent.** Re-running on the same day is a no-op. The scheduler trusts its past decisions.
- **State-aware, not rule-based.** The scheduler reads board, progress, memory, and picks the most useful action given current state — it doesn't cycle through a fixed pattern.
- **Fails gracefully.** If Telegram is down, the task still lands on the board. If both fail, the scheduler logs and exits 0 so cron doesn't alarm.
- **Headless-first, but in-session.** `/schedule` is non-interactive — no clarifying questions, deterministic writes — so it can fire from an automated trigger. It runs *inside* a live Claude Code session, not as a standalone `claude -p` process, because two-way Telegram needs one long-lived long-poll connection.

Transport is the official Telegram plugin, not a bespoke bot. One token, one long-poll, one always-on session — inbound DMs and outbound `/schedule` pings share the same runtime. The repo is deliberately unaware of Telegram credentials: token lives in `~/.claude/channels/telegram/.env`, chat IDs in `~/.claude/channels/telegram/access.json`. Cadence is driven by a remote-agent trigger (`CronCreate` via the `schedule` skill) that invokes `/schedule` on a daily cron from within the same session. Inbound messages are routed by `CLAUDE.md` exactly like typed input — Telegram is a transport, not a separate mode.

### Lint exits 0

`scripts/lint.sh` is informational, not a gate. Warnings are for the user; the script never blocks anything. Gating on lint would create pressure to suppress warnings rather than act on them.

## Anti-patterns (what we chose not to do)

- **A dedicated web UI.** Claude Code + any markdown editor is enough. A UI would fragment the stack.
- **A database.** SQLite would be faster for queries, but then the files stop being the source of truth and the whole tool-agnostic story falls apart.
- **A task-scheduling engine inside the repo.** `/schedule` is a single-shot picker invoked by a remote-agent trigger (`CronCreate`) from inside the always-on session — the repo itself doesn't manage timers, daemons, or reminder queues. The weekly `/review` remains the reflective cadence.
- **A plugin system.** Slash commands in `.claude/commands/` are the extension point. If you need more, edit the command file or add a new one.
- **Multi-tenant memory.** `memory/MEMORY.md` is one user, one file. No profiles.
- **Auto-generating wiki pages from every research pass.** Research should be selective about what gets promoted. Automatic promotion floods the wiki with task-specific trivia.

## Open Questions

- **Memory compression.** `memory/MEMORY.md` has a 100-line cap. When it fills, older insights move into dated review files. Is 100 lines the right cap? Needs data.
- **Curriculum regeneration.** If the user's interests drift mid-project, should adaptive level generation be able to rewrite *earlier* levels too? Right now it only shapes the next level forward.
- **Wiki depth limit.** No cap on wiki page count. At 1000+ pages, `wiki/index.md` becomes unwieldy. Revisit when it gets there.
- **Cross-project wiki vs per-project.** Currently one wiki for everything. Per-project wikis would reduce noise but lose the compounding effect across domains.

# Spec: Give project documentation a clear home and keep it current through Balka

From [intent.md](intent.md) (2026-11-12). Owner: Nikita Furletov. Status: accepted. Date: 2026-11-12.

## Requirements

- R1 — Init establishes a documentation home and a readable overview of purpose, major parts, and working procedures, grounded in repository evidence with unknowns identified.
- R2 — Short entry instructions identify the home, overview, and writing policy; agents discover relevant filenames and headings before loading document contents.
- R3 — Init reuses established documentation paths and preserves maintained content; it reports conflicting edits before writing any setup changes, and reruns do not duplicate content.
- R4 — Current guidance remains distinct from historical proposals; documentation distinguishes accepted requirements, verified implementation, and observed runtime state.
- R5 — The writing policy gives project-specific concepts, decisions with reasons, constraints, and verified discoveries authoritative homes, with references instead of copied code or procedures.
- R6 — Plan identifies affected documentation and its paths, or explains specifically why no documentation change is needed; Build performs those updates and records departures normally.
- R7 — Test's existing independent verifier checks relevant current and inherited documentation for accuracy, contradictions, missing knowledge, and usable discovery paths against the contract and implementation evidence.
- R8 — Documentation corrections return to Build; contract changes return to Design with the owner; a change becomes built only after relevant findings are resolved.
- R9 — Unsupported runtime claims are corrected to describe available evidence and uncertainty; unrelated documentation debt does not require a repository-wide audit before completion.

## Constraints

- Preserve the six stages, existing acceptance gates, scenario authority, and the facts document's role.
- Preserve file history and established documentation layouts. No deletion, recreation, or renaming as an adoption route.
- Keep installed skill descriptions short; extend the existing artifact skill without adding a skill.
- Keep existing configurations compatible, including the legacy opt-in fallback. Add no configuration keys or hook exemptions.
- Tests remain offline. No network, new model-driven test harness, or new Gherkin runner.

## Scenarios

- `features/project-documentation.feature` — R1–R4; establishment, preservation, and progressive discovery.
- `features/documentation-lifecycle.feature` — R4–R9; writing, reconciliation, verification, and evidence.

No bindings: this repository has no scenario runner. These files are a manual acceptance checklist for the verifier, not executable evidence of agent behavior.

## Design

### Establish the home

Extend `init --artifacts` to inspect existing entry instructions and documentation before proposing paths. Reuse an existing home, overview, and writing policy where they serve these roles. With no existing equivalents, use `docs/`, `docs/project-overview.md`, and `docs/documentation-writing.md`.

New `project-overview.md` and `documentation-writing.md` templates supply the missing roles. Fill the overview from inspected repository evidence: purpose, major parts and relationships, relevant contracts, and how to work with the project. Link to the existing facts document, commands, and authoritative code rather than copying them. Identify missing knowledge explicitly; ask the owner for blocking facts instead of inventing them. Do not produce a full repository manual during init.

Record the actual home, overview, and policy paths as short pointers in the existing managed `AGENTS.md` block. Retain the existing `CLAUDE.md` import mechanism. These pointers also let later init runs retain the selected paths; no second inventory or config field stores them.

Preflight all setup edits before writing. Update Balka-managed blocks and create missing documents. Reuse compatible maintained documents unchanged; if an edit would alter maintained content, report the file and conflicting lines and stop without partial setup. Resolve the collision in place with the owner and rerun; do not offer deletion or relocation.

### Discover and write

The entry block points to the overview, policy, and documentation home, without embedding their contents. Use available file-listing tools for a shallow view, then explore relevant branches. Historical change directories are not routinely traversed. Search headings before reading selected sections of large documents. Neither `tree` nor a new helper is required.

Read the writing policy before editing reusable documentation. Keep one authoritative account of each concern, use descriptive filenames, preserve local reference conventions, and document project-specific knowledge that affects future decisions. Keep historical proposals available for relevant investigations, visibly distinct from current guidance. Preserve known reasons and constraints when correcting guidance; consult source history when the correction's meaning or rationale is unclear.

The facts document remains the required first read and the home for estate names and facts. Link to it from the overview. Avoid restating its content in new documents.

### Integrate with the existing stages

| Point | Change |
| --- | --- |
| Intent and Spec | Discover relevant current guidance before drafting; link current constraints and distinguish proposals from implemented behavior. |
| Plan | Assess documentation impact in Approach; list affected paths in Files that change, or explain why current guidance remains accurate. |
| Build | Update affected current guidance, including useful verified discoveries, alongside implementation; record justified departures as today. |
| Test | Give the existing fresh verifier the entry instructions, relevant documents, evidence references, and the plan's impact explanation. Add the R7 consistency checks. |
| Deploy | Include documentation in the same reviewed change. Describe rollout only to the extent supported by landing evidence. |
| Reflect | Investigate repeated discovery failures, contradictory guidance, and lost corrections; retain the existing project/plugin routes. |

Apply the writing policy by reference in commands, the artifact skill, and review instructions. The policy does not override accepted requirements or scenarios. Project documentation stays subject to the normal plan file list; do not exempt the documentation home through `artifactPaths`.

The verifier checks the affected knowledge slice, including inherited guidance needed to understand or use the change. Resolve a factual documentation error through Build and rerun verification. If evidence shows a contract disagreement, stop for the owner and the design transition. Newer text, active status, green tests alone, or matching metadata cannot settle a contradiction.

An honest statement that production has not been observed is acceptable when only implementation evidence exists. It does not excuse unresolved contradictions within the affected contract or procedures. Unrelated debt can be reported through the project's existing mechanism without widening this change.

### Adoption and release

Document the defaults, reuse behavior, rerun path, and verification limits in the README. Existing repositories opt into the new entry and policy through init; this release does not rewrite them automatically. Bump the plugin version when the implementation is released.

## Non-goals

- A documentation portal, shared remote knowledge store, required folder taxonomy, or new discovery utility.
- Generating comprehensive documentation, checking a live deployment, or migrating other repositories in this change.
- New hooks, a new approval gate, or claims that text checks prove semantic correctness.

## Acceptance

- Walk through every scenario against the changed commands, templates, and review policy using empty, established, conflicting, and legacy repository examples.
- Verify requirement coverage and the absence of contradictory instructions; report any agent behavior that was not exercised as unverified.
- Run `claude plugin validate .`, `bash tests/run.sh`, and `git diff --check` before completion. These validate packaging and existing mechanisms; they do not prove semantic documentation accuracy.

# Intent: Give project documentation a clear home and keep it current through Balka

Author: Codex, from Nikita Furletov's request. Owner: Nikita Furletov. Status: accepted. Date: 2026-11-12.

## Problem

Nikita has no clear place to read current project documentation and understand how a repository works. Balka preserves individual changes, but does not require a readable body of current project knowledge. Agents must piece that understanding together from code, past changes, and conversations, and existing documentation may be missing or stale.

## Outcome

Each adopting repository has a clear home for project documentation that Nikita can read and agents can use to understand the project. Relevant details are easy to discover without reading everything. Each completed change leaves the knowledge it affects consistent with the accepted contract and available evidence.

## Behaviours

- A person or agent can find a readable explanation of the project's purpose, how its parts fit together, and how to work with it.
- An agent can discover relevant documents and sections from a short entry point without loading the entire document and change archive.
- Current project guidance is distinguishable from historical proposals and records, and documents distinguish intended behavior, verified implementation, and observed runtime state.
- Project-specific concepts, decisions and their reasons, constraints, and verified discoveries have authoritative homes that future work can reuse.
- A change updates the affected authoritative documents alongside its implementation, or explains why no update is needed.
- Verification checks relevant documentation, including inherited guidance, against the accepted contract and implementation evidence; document status or recency alone does not establish correctness.
- Missing, misleading, conflicting, or undiscoverable guidance uses the existing correction and design routes before a change is declared built; unsupported claims remain explicitly uncertain.
- Existing projects adopt the rules incrementally while preserving their documentation layout, manually maintained content, and history.

## Out of scope

- A new SDLC stage, universal knowledge-store technology, or prohibition on skills.
- Bulk migration or modification of adopting repositories.
- Auditing or documenting the entire repository as a prerequisite for every change.
- Claims that timestamps or automated text checks prove semantic correctness.

## Open questions

None outstanding. Ready for design.

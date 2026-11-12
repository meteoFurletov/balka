# Intent: Keep reusable project knowledge current through the Balka loop

Author: Codex, from Nikita Furletov's request. Owner: Nikita Furletov. Status: draft. Date: 2026-11-12.

## Problem

Balka preserves the intent, design, implementation plan, and executable checks for a change. It does not explicitly require the change to leave reusable project knowledge consistent with the result. A later agent may therefore need to reconstruct the current system from past changes and conversations, or rely on stale guidance.

## Outcome

Each completed change leaves accurate, discoverable project knowledge that a later agent can reuse. Agents load relevant information progressively, and reusable knowledge is checked as part of completing the change.

## Behaviours

- An agent can discover relevant current knowledge from a short entry point without loading the entire document and change archive.
- Current guidance remains distinguishable from historical proposals and records.
- Documents distinguish intended behavior, verified implementation, and observed runtime state.
- A change updates the affected authoritative documents alongside its implementation, or explains why no update is needed.
- Verification finds relevant documentation that is missing, misleading, inaccessible through the entry point, or inconsistent with the accepted contract and implementation.
- Documentation findings use the existing correction and design routes before a change is declared built.
- Useful project corrections persist in authoritative guidance; process-wide improvements continue through reflection.
- Existing projects adopt the rules incrementally while preserving their documentation layout, manually maintained content, and history.

## Out of scope

- A new SDLC stage, universal knowledge-store technology, or prohibition on skills.
- Bulk migration or modification of adopting repositories.
- Claims that timestamps or automated text checks prove semantic correctness.

## Open questions

None blocking this intent. The design must choose the minimum entry and policy mechanism compatible with existing repositories.

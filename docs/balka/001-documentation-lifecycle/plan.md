# Plan: Give project documentation a clear home and keep it current through Balka

From [spec.md](spec.md) (2026-11-12), following [intent.md](intent.md). Owner: Nikita Furletov. Status: built. Date: 2026-11-12.

## Scenarios this work proves

Manual acceptance checklist; no runner or bindings, as recorded in the spec.

- `features/project-documentation.feature` — Establish documentation where none exists
- `features/project-documentation.feature` — Reuse established documentation
- `features/project-documentation.feature` — Report a setup collision before writing
- `features/project-documentation.feature` — Repeat setup without duplicating documentation
- `features/project-documentation.feature` — Load the documents relevant to a task
- `features/project-documentation.feature` — Read relevant sections of a large document
- `features/project-documentation.feature` — Distinguish a historical proposal from current guidance
- `features/documentation-lifecycle.feature` — Update documentation with changed behavior
- `features/documentation-lifecycle.feature` — Explain why documentation remains unchanged
- `features/documentation-lifecycle.feature` — Preserve a useful discovery in its authoritative home
- `features/documentation-lifecycle.feature` — Resolve contradictory inherited guidance
- `features/documentation-lifecycle.feature` — Correct documentation findings before completion (all three examples)
- `features/documentation-lifecycle.feature` — Return a contract disagreement to Design
- `features/documentation-lifecycle.feature` — Distinguish implementation from a live rollout
- `features/documentation-lifecycle.feature` — Keep unrelated documentation debt outside the change

## Approach

1. Add the two templates named in the spec. Keep the writing policy authoritative for reusable documentation; the overview supplies concise project explanations and pointers to evidence. Read the existing skill-creator guidance before updating the artifact skill.
2. Restructure init into discovery/preflight and application. Preflight every selected flag's edits, including existing legacy migration edits, before mutation. Retain selected documentation paths from the managed entry block, reuse suitable existing documents unchanged, and generate only missing roles. On reruns, retain existing facts, proposals, and owner additions; report collisions with paths and lines before writing. Keep documentation paths out of new config keys and broad hook exemptions.
3. Add short home, overview, and policy pointers to the starter entry block. Extend the artifact skill's template list and link to the policy through those pointers. Preserve its existing scope and keep the installed description concise.
4. Update Intent and Spec to discover relevant current guidance. Update Plan and its template to carry documentation impact in Approach and affected paths in the normal file list. Update Build to read the policy before writing affected documentation and preserve useful verified discoveries through ordinary departures. Existing repositories without the new pointers retain their layout: inspect available guidance and use the shipped writing policy as a fallback until init establishes the pointers.
5. Extend Test's existing verifier inputs and checks to include the relevant documentation and impact explanation. Route prose corrections through Build and contract disagreements through Design. Apply the same policy by reference in review instructions; extend Deploy's evidence wording and Reflect's investigation prompts without adding a gate or report.
6. Update the README as this plugin's existing overview: explain setup, defaults, incremental adoption, and verification limits. Keep project-specific facts in the facts document. Prepare version 0.7.0 in the plugin manifest; no marketplace change is needed.
7. Walk through the accepted scenarios against the resulting instructions using empty, established-handbook, collision, repeat-init, legacy, and contradictory-guidance examples. Check every requirement's owning text and reference path. Run `claude plugin validate .`, `bash tests/run.sh`, and `git diff --check`; use the existing fresh-context verifier for the final consistency review. Report the manual walkthrough separately from executable checks and any unexercised agent behavior as unverified.

Documentation impact: the implementation is workflow guidance. The README, command texts, templates, and artifact skill are its authoritative documentation and change together. Existing hook and watcher behavior is unchanged; keep their implementation and offline tests intact. The accepted scenarios and assertions remain unchanged.

## Files that change

- templates/project-overview.md
- templates/documentation-writing.md
- templates/AGENTS.md
- templates/plan.md
- templates/copilot-instructions.md
- commands/init.md
- commands/intent.md
- commands/spec.md
- commands/plan.md
- commands/build.md
- commands/test.md
- commands/deploy.md
- commands/reflect.md
- skills/balka-artifacts/SKILL.md
- README.md
- .claude-plugin/plugin.json

## Risks and rollback

- Setup is an agent procedure, not a transactional executable. Preflight and collision handling must be explicit before every write; a text review cannot prove arbitrary agents follow them.
- Managed entry updates must preserve the selected paths and all maintained documents. Review old and new block examples, existing imports, and legacy migration ordering.
- Repeating the writing rules across commands would create drift. Keep the rules in the policy and use concise references elsewhere; a missing local policy uses the shipped fallback.
- A passing package check or hook suite does not establish semantic documentation accuracy. Use the manual scenarios and independent verifier, and state the evidence limit.
- Roll back a released regression by reverting the implementation commits in Git. Retain adopted project documents and their history; correct affected guidance in place.

## Departures

- Independent review found that slash stages ignored the still-supported legacy config. Align their readers with the existing fallback, including `commands/verify.md` outside the original file list, so configured paths, facts, verification, and deploy settings remain authoritative without implicit migration.
- Define Verify's no-config continuation as validating and reporting commands for the session without creating an opt-in file; Build and Test use those commands when no config exists.
- Align Test and the plan template's completion instruction with the board and hooks, which read the header's first status; update that status to built instead of adding a second status under Departures.

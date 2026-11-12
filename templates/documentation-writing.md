# Project documentation

## Discover what matters

Use the documentation home and overview named in the repository's entry
instructions. Start with a shallow file listing, using available tools such as
Glob or find, then follow descriptive filenames into the relevant branches.
Neither the tree executable nor a special helper is required. Inspect headings
before choosing sections of large documents. Load the knowledge needed for the
task; do not read the whole collection or traverse change archives by default.

Current guidance explains the project as it stands. Historical proposals,
change records, and investigations retain their own homes and statuses; read
them when the task needs their history. An accepted proposal alone does not
establish implemented behavior.

## Write reusable knowledge

- Give each concern one authoritative home. Update the existing account before
  adding another. Use descriptive filenames and the repository's reference
  conventions; preserve established paths and manually maintained content.
- Explain project-specific concepts, decisions and their reasons, constraints,
  and verified discoveries that affect future work. Omit generic engineering
  advice and session transcripts. Keep estate names and facts in the facts
  document identified by the entry instructions; reference it instead of
  repeating it.
- Point to code, configuration, contracts, and existing commands instead of
  copying them. Explain when and why a source matters. Keep references usable
  from the entry instructions, with no second hand-maintained full inventory.
- Distinguish accepted requirements, behavior supported by implementation and
  checks, and behavior observed at runtime. Runtime claims identify the
  environment and observation date when relevant. Mark unsupported claims as
  uncertain; ask the owner about missing facts that block the change.
- Preserve relevant reasons and constraints when correcting guidance. Inspect
  source history when their meaning is unclear. Neither status, recency,
  metadata, nor green tests alone settles a semantic contradiction.
- Edit in place. Never delete, recreate, or rename a file to bypass a Balka rule.

## Maintain with the change

Plan assesses documentation impact in its Approach and lists affected paths,
or gives a specific reason why existing guidance remains accurate. Build
updates those documents and preserves useful verified discoveries, recording
departures through the existing plan mechanism.

Test checks the relevant knowledge, including inherited guidance needed to
understand or use the change, against the accepted contract and implementation
evidence. Missing explanations, obsolete procedures, contradictions, and broken
discovery paths are findings even when packaging and tests pass. Correct prose
through Build and rerun verification. A required contract or scenario change
returns to the owner and Design; documentation never overrides that contract.

Resolve relevant findings before declaring the change built. Honest uncertainty
about an unobserved production rollout is acceptable; an unresolved conflict in
the affected contract or procedures is not. Unrelated debt does not require a
repository-wide audit; report it through the project's existing mechanism when
useful. Process-wide improvements continue through Reflect.

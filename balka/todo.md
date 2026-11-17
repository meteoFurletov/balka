# Todo

Work to return to and develop into future intents. These entries do not define accepted scope or implementation decisions. The [capability review](capability-review.md) explains the gaps behind these entries.

## Core loop

- [ ] **BDD Design contract:** define how Design produces readable Gherkin scenarios and, where a runner exists, bindings that assert observable results and fail for the intended missing behavior. Have the owner review the scenarios before Build uses them. Include changes that preserve existing behavior without inventing new scenarios.
- [ ] **AI SDLC Test:** develop the [Test intent](006-ai-sdlc-test/intent.md) into guidance for independent verification and resolution of findings.
- [ ] **AI SDLC Deploy:** define delivery review, handling of findings, release authority, and the project's landing and rollback procedure. Keep evidence of a verified build separate from evidence of a live rollout.
- [ ] **AI SDLC Maintain:** define how observed failures produce evidence for a new draft intent and how diagnosis stays within its authority. Decide suitable signals in that intent without assuming that CI health establishes runtime health.

## Agent development

- [ ] **Project knowledge:** provide concise conventions, commands, verified project facts, and lessons from past mistakes. Make relevant documentation discoverable, maintain it with changes, and check affected guidance against implementation evidence.
- [ ] **Reusable guidance:** make applicable policies available when the task needs them.
- [ ] **Controls:** enforce mandatory boundaries through mechanisms stronger than instructions, independently of the harness.
- [ ] **Parallel work:** isolate independent changes and give helpers clearly scoped tasks.

## Other work

- [ ] **Process guidance and operations:** turn the stage intents into guidance and templates agents can discover and use, with a common way to read and update change artifacts and decisions independently of the harness.
- [ ] **Project adoption:** establish Balka's entry instructions and artifact locations in a project, reusing existing documentation and preserving maintained content. Make repeated setup safe and report conflicting edits before partial writes.
- [ ] **Change state and continuation:** define how an agent identifies a change, its owner, accepted artifacts, stage, evidence, and outstanding work so another agent can continue without the previous conversation. Cover rejected, parked, and split work without conflicting status records.
- [ ] **Change sizing and splitting:** keep changes focused on a capability; split work that spans capabilities into linked intents while preserving the parent and its decisions.
- [ ] **Verification setup:** discover and validate the project's build, test, lint, and scenario commands, their expected results, and unavailable checks before Build relies on them. Keep one authoritative home for these commands.
- [ ] **Process feedback:** capture recurring friction and corrections, then let the owner route them to project guidance, a Balka change, or a reasoned rejection.
- [ ] **Work visibility:** show changes, their stages, blockers, and next actions from authoritative state without maintaining a second status record.
- [ ] **Verify Balka itself:** test its operations and controls, and exercise representative tasks with agents. Distinguish deterministic tests, manual review, and observed agent behavior; include blocked transitions and continued work across agents.
- [ ] **Continuous evals in CI:** define regression evaluations using representative agent tasks and expected outcomes. Run them on changes to agent guidance and controls and on a schedule, retain results for comparison, and review regressions before merging. Add incident-derived regression cases. Keep the evaluation contract independent of the app, model, or harness.

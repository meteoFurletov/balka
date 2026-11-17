# Intent: AI SDLC Build — accept an implementation plan and build the change

Author: Codex. Date: 2026-11-17.

## Problem

Balka's [AI SDLC loop](../002-ai-sdlc-loop/intent.md) puts Build after an accepted design, but provides no guidance for that stage. Agents need to make their implementation approach reviewable before changing the system and leave work that Test can independently verify.

## Proposed outcome

Balka provides the Build process described in [The AI-native SDLC playbook](https://claude.com/resources/articles/the-ai-native-sdlc-playbook), using BDD acceptance scenarios as the implementation contract. The agent reads the accepted `intent.md`, `spec.md`, Gherkin `.feature` files, and any bindings, inspects the repository, and loads relevant project knowledge. Before implementation, it writes `plan.md` alongside the intent and spec, linking to them and naming the scenarios the work proves, files to change, order of work, risks and rollback, alternatives considered, and verification commands. The agent asks about unresolved decisions and revises the plan until another agent can implement it without the conversation.

The owner reviews and explicitly accepts or rejects the plan in chat, consulting a technical lead where project policy requires it. The agent records the decision in Git. Acceptance authorizes Build and Test within the agreed scope, as defined by the loop.

Where the project has a scenario runner, Build starts from the bindings agreed in Design and the recorded evidence that new scenarios fail for the intended missing behavior. The agent implements the accepted plan until those scenarios and the applicable build, test, and lint checks pass. It may adapt test setup and action steps (`Given` and `When`) to reach the implementation, while preserving the observable results asserted by `Then` steps. Unit tests support implementation but do not replace scenario evidence.

Where there is no scenario runner, the scenarios remain an acceptance checklist. The agent records which examples it checked manually and what remains unverified; it does not claim that Gherkin ran. A change with no scenario changes states that in the plan and preserves the existing scenarios.

The agent updates affected documentation and records implementation departures and their reasons in `plan.md` in the same commit as the change. The implementation, tests, updated documentation, and check evidence pass directly to Test for independent verification, without another approval for the accepted scope.

## Affected users and systems

Owners reviewing plans and agents implementing and verifying changes. Balka's process guidance and project repositories holding plans, implementation, and evidence are affected.

## Constraints

Do not implement before explicit plan acceptance. Keep work within the accepted intent and spec. Build does not create or change acceptance scenarios or their expected-result assertions to fit the implementation. Missing scenarios for new behavior, incorrect assertions, or other findings that change the accepted contract stop implementation and return to the owner and Design. Report blocked or unrun checks without claiming the change has passed.

Keep the process independent of the app, model, or harness. This intent covers implementation planning and building against the accepted BDD contract. Defining that contract in Design and further work to make Build robust are tracked in the [todo list](../todo.md) for future intents. Choosing a scenario runner or enforcement mechanism is outside this change. Independent verification and delivery remain in their respective stages.

## Open questions

None.

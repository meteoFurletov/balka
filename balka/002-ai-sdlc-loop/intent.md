# Intent: Make the AI SDLC loop the core of Balka

Author: Codex, from Nikita Furletov's request. Owner: Nikita Furletov. Status: accepted. Date: 2026-11-17.

## Core idea

The core idea comes from Anthropic's [The AI-native SDLC playbook](https://claude.com/resources/articles/the-ai-native-sdlc-playbook): six stages connected by versioned artifacts, with agents carrying work between stages, humans accountable at decision points, and maintenance evidence feeding the next intent.

## Problem

Balka needs a defined development loop. Without a common loop, agents must decide for themselves when a change is ready to move on, who accepts it, and where a finding belongs.

## Outcome

Balka provides one AI SDLC loop as its core: Plan → Design → Build → Test → Deploy → Maintain. Agents carry work through this loop using recorded decisions and evidence. Maintenance feeds new work back into Plan. Each stage will be developed through its own intent without redefining the whole loop.

## Behaviours

- Every change has one named owner before it can be accepted. Its recorded stage, decisions, evidence, and outstanding work let another agent determine where to continue.
- A change proceeds through the six stages only when the preceding stage's conditions hold. Implementation planning belongs to Build; it is not a seventh stage.
- The owner accepts the intent, then the design contract, then the implementation plan. Drafts, silence, and answers to individual questions do not count as acceptance.
- Acceptance of the implementation plan authorizes Build and Test within the accepted scope. Agents continue that work without asking again about decisions already settled; delivery remains a separate decision.
- Implementation findings return to Build and then Test. A finding that requires changing the accepted contract stops implementation and returns to the owner and the relevant earlier stage.
- Agents use relevant project knowledge throughout the loop. Affected current documentation is planned, updated, and verified with the change.
- Completion claims distinguish accepted intent, verified implementation, reviewed delivery, and observed runtime state. Evidence for one does not establish the others.
- Maintenance can produce a new draft intent from evidence. That intent follows the same acceptance and development loop as work requested by a person.

## Stages

1. Plan — agree on the problem, outcome, and scope.
2. Design — agree on the contract and acceptance scenarios.
3. Build — agree on the implementation plan, then implement until checks pass.
4. Test — independently verify the change and resolve findings.
5. Deploy — address delivery review and hand over the landing procedure.
6. Maintain — detect deterioration and turn evidence into a new intent.

## Out of scope

- Choosing storage, APIs, commands, enforcement mechanisms, review tools, or deployment platforms.
- Setup, a board, and reflection on the process itself; these support the loop but are not additional stages.

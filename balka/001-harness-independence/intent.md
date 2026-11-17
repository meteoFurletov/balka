# Intent: Make Balka independent of the agent harness

Author: Codex, from Nikita Furletov's request. Owner: Nikita Furletov. Status: accepted. Date: 2026-11-13.

## Problem

Nikita needs agents to work within the same development process regardless of their app, model, or harness. When process instructions, knowledge, controls, and work state belong to a particular client, changing the client changes how the work can be done and what the agent knows.

## Outcome

Balka provides the process instructions, project knowledge, change state, and operations agents need to carry out development work. Agents access and use these independently of their app, model, or harness. Balka defines what the work requires and provides a common way to interact with it, without tailoring the process to particular clients.

## Behaviours

- An agent can discover and load the process instructions and project knowledge relevant to its task without relying on client-specific installation paths or private memory.
- An agent can access the operations needed for its work through a common interaction contract defined by Balka.
- Another agent can continue a change using its recorded decisions, ownership, progress, and outstanding work without reconstructing the previous conversation.
- The same accepted contract, process rules, and authority boundaries apply when the app, model, or harness changes.
- Required controls remain effective independently of client-specific hooks; an instruction alone is not presented as an enforced control.
- Acceptance checks establish that the process and required operations work independently of a particular client, with actual agent exercises distinguished from deterministic tests and manual review.

## Out of scope

- Building or replacing an agent app, model, or harness.
- Maintaining separate versions of the process for particular clients.

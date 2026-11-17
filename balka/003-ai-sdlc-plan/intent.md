# Intent: AI SDLC Plan — capture and accept change intent

Author: Nikita Furletov. Date: 2026-11-17.

## Problem

Balka's [AI SDLC loop](../002-ai-sdlc-loop/intent.md) starts with Plan, but provides no guidance or intent template for that stage. People and agents need a way to make an idea concrete and preserve its meaning for the next stage.

## Proposed outcome

Balka provides the Plan process described in [The AI-native SDLC playbook](https://claude.com/resources/articles/the-ai-native-sdlc-playbook). An idea, ticket, or maintenance finding starts the work. The originator describes the need in ordinary language, and the agent asks about the problem, users, scope, constraints, and success until the idea is concrete. The agent writes `intent.md`, and the originator corrects it. The product owner explicitly accepts or rejects it in chat, and the agent records that decision in Git. An accepted intent passes to Design.

Each project keeps its intents under `balka/` in its repository. Its `AGENTS.md` explains Balka's basics so agents have that context from the start. Once an agent understands the user's request, it loads the relevant process guidance and template to proceed.

## Affected users and systems

People proposing changes, product owners reviewing them, and agents writing and continuing the work. Balka's process guidance and the project repositories holding the intents are affected.

## Constraints

Use the playbook's five-section intent example, with author and date metadata recording who wrote it and when. Keep the intent short and in the originator's terms. Record unresolved questions and ask the owner to resolve them. The process must work independently of the app, model, or harness. Design and implementation planning remain in their respective stages; ticket intake integrations, monitoring, and automatic transitions are outside this change.

Keep repository changes useful. Avoid duplicated facts, counts, and status summaries that create routine upkeep.

## Open questions

None.

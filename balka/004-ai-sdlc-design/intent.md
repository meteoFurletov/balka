# Intent: AI SDLC Design — produce and accept a requirements and design spec

Author: Codex. Date: 2026-11-17.

## Problem

Balka's [AI SDLC loop](../002-ai-sdlc-loop/intent.md) puts Design after an accepted intent, but provides no guidance for that stage. People and agents need to turn the agreed need into a requirements and design spec that Build can plan against.

## Proposed outcome

Balka provides the Design process described in [The AI-native SDLC playbook](https://claude.com/resources/articles/the-ai-native-sdlc-playbook). The agent reads the accepted `intent.md`, relevant project knowledge, and applicable standards and policies, then produces a requirements and design spec as `spec.md` alongside the intent. The spec links to the intent rather than repeating it.

The agent flags unresolved questions, conflicting requirements, and policy concerns. The owner reviews the spec against the intent, checks that its open questions are answered or carried forward, and resolves concerns with the relevant policy owners. The owner explicitly accepts or rejects the spec in chat, consulting a technical lead where project policy requires it, and the agent records that decision in Git. An accepted spec passes to implementation planning in Build.

## Affected users and systems

Owners reviewing designs, agents producing specs, and people and agents planning, building, and verifying changes. Balka's process guidance and the project repositories holding the change artifacts are affected.

## Constraints

Keep the design within the accepted intent. If design work reveals a change to its problem, outcome, or scope, return to Plan for the owner's decision. Resolve concerns that prevent acceptance before progressing to Build.

The process must work independently of the app, model, or harness. Implementation planning belongs to Build. Choosing integrations, automatic transitions, and enforcement mechanisms is outside this change.

## Open questions

None.

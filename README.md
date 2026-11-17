# Balka

Balka is being designed as a harness-agnostic SDLC system. It provides the process, project knowledge, change state, and operations agents need to work, independently of their app, model, or harness.

The core idea comes from Anthropic's [The AI-native SDLC playbook](https://claude.com/resources/articles/the-ai-native-sdlc-playbook): a development loop in which agents work from versioned artifacts, accepted work moves to the next stage, and maintenance evidence starts the next change.

See the [accepted harness-independence intent](balka/001-harness-independence/intent.md) for the direction and boundaries.

The [AI SDLC loop intent](balka/002-ai-sdlc-loop/intent.md) defines Balka's core loop: Plan → Design → Build → Test → Deploy → Maintain → a new intent. Each stage will be developed through its own intent.

The [AI SDLC Plan intent](balka/003-ai-sdlc-plan/intent.md) defines how agents clarify a need, capture it as `intent.md`, and obtain owner acceptance before Design.

The [AI SDLC Design intent](balka/004-ai-sdlc-design/intent.md) defines how agents turn an accepted intent into a requirements and design spec for owner review before Build planning.

The [AI SDLC Build intent](balka/005-ai-sdlc-build/intent.md) defines how agents obtain acceptance of an implementation plan, build and check the change, and pass the evidence to Test.

The [AI SDLC Test intent](balka/006-ai-sdlc-test/intent.md) defines independent verification, correction and reverification of findings, and the evidence passed to delivery review.

The [AI SDLC Deploy intent](balka/007-ai-sdlc-deploy/intent.md) defines agent review, enforced release approvals, and agent work in CI/CD through delivery and recovery.

The [todo list](balka/todo.md) holds work to develop into future intents.

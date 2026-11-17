# Balka

Balka is being designed as a harness-agnostic SDLC system. It provides the process, project knowledge, change state, and operations agents need to work, independently of their app, model, or harness.

The core idea comes from Anthropic's [The AI-native SDLC playbook](https://claude.com/resources/articles/the-ai-native-sdlc-playbook): a development loop in which agents work from versioned artifacts, accepted work moves to the next stage, and maintenance evidence starts the next change.

See the [accepted harness-independence intent](balka/001-harness-independence/intent.md) for the direction and boundaries.

The [AI SDLC loop intent](balka/002-ai-sdlc-loop/intent.md) defines Balka's core loop: Plan → Design → Build → Test → Deploy → Maintain → a new intent. Each stage will be developed through its own intent.

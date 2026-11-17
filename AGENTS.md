# Balka

Balka provides a harness-independent SDLC process, project knowledge, change state, and operations for agents. Read `README.md` for the project direction and `balka/001-harness-independence/intent.md` for the intent.

- Define what Balka provides and what agents need to do. Keep the process, knowledge, operations, and controls independent of the app, model, or harness; do not introduce client-specific support lists or rules.
- When defining the AI SDLC loop and its stages, follow the AI-native SDLC playbook, adapting its guidance to Balka's harness-independent direction. Within this loop work, keep additional methods and integrations for separate work requested by the owner; do not introduce them into these intents or their open questions.
- Keep project intents under `balka/` in the project repository. Keep `AGENTS.md` sufficient to explain Balka's basics at the start; once the agent understands the user's request, it loads the relevant guidance on how to proceed.
- Keep work that is not ready for an intent in `balka/todo.md`. Check the list when drafting intents and link deferred work from the relevant intent to make its scope clear. When a todo item gets its own intent, link to it from the item.
- Prioritize the core loop stages first, then project knowledge, reusable guidance, controls, and parallel work, in that order, followed by other supporting work.
- Keep repository changes useful. Avoid duplicated facts, counts, and status summaries that create routine upkeep.
- Git is the history. Edit files in place; never delete, recreate, or rename a file to bypass a rule or control.
- Write documents about what Balka provides and requires now. Keep old-version references, commit hashes, extraction notes, and conversation history out unless explicitly requested or needed to explain a current decision.
- Follow the playbook's intent example: Problem, Proposed outcome, Affected users and systems, Constraints, and Open questions. Add author and date metadata to record who wrote it and when. Do not require a Core idea section or add other sections or metadata unless requested.
- Keep links that help the reader understand or act. Omit redundant provenance lines such as "From the accepted direction."
- Include `ai-sdlc-<stage>` in AI SDLC stage directory names so their place in the loop is clear.
- An intent that defines how intents are written must itself follow those requirements.
- BDD acceptance scenarios and their expected-result assertions form the contract agreed in Design. Build changes implementation and binding glue to satisfy that contract; missing or incorrect behavior expectations return to the owner and Design. Distinguish executed scenarios from manual acceptance review when no runner exists.
- Ask the owner the open questions recorded in an intent; do not leave them only in the document.
- Record the owner's acceptance or rejection in Git after their explicit decision in chat. Explicit acceptance authorizes committing and pushing the accepted changes to the current working branch without another confirmation. Answers to open questions do not by themselves accept the intent.
- Apply the owner's explicit corrections consistently. When a correction establishes a reusable project preference, update this file in place during the same chat so future agents can follow it. Record the general rule, not the conversation; keep task-specific edits in their own documents.

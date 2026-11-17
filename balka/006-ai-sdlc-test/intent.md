# Intent: AI SDLC Test — independently verify the change and resolve findings

Author: Codex. Date: 2026-11-17.

## Problem

Balka's [AI SDLC loop](../002-ai-sdlc-loop/intent.md) puts Test after Build, but provides no guidance for that stage. Build's passing checks alone do not establish that the change satisfies the accepted requirements or that the checks still prove the agreed behavior. Agents need independent verification and a clear route for findings before delivery review.

## Proposed outcome

Balka provides the Test process described in [The AI-native SDLC playbook](https://claude.com/resources/articles/the-ai-native-sdlc-playbook). The check-and-fix feedback loop runs throughout implementation. After Build, a verifier starts with fresh context from the accepted `intent.md`, `spec.md`, acceptance scenarios and bindings, `plan.md`, relevant project knowledge, the actual change, and Build's evidence. It assesses the work independently of the assumptions and conversation that produced it.

The verifier checks requirement coverage, observable scenario assertions, implementation, recorded plan departures, and affected documentation. It checks that the acceptance contract was preserved and that passing results were not obtained by weakening, skipping, or deleting checks. It runs the applicable scenario, build, test, and lint checks and exercises the changed behavior and nearby affected flows. UI changes include visual comparison with the accepted design where applicable.

The verifier records findings and supporting evidence rather than fixing the implementation during verification. Implementation and documentation findings return to Build for correction, followed by independent verification of the fixes and affected behavior. Findings that expose missing or incorrect behavior expectations stop the work and return to the owner and Design; changes to the intent return to Plan. Agents continue corrections and verification within the accepted scope without another approval.

The result records what was checked, against which revision, the observed outcomes, unresolved findings, and unavailable checks, with links to command output or other evidence. Executed scenarios, manual acceptance review, and actual agent exercises are distinguished. Where no scenario runner exists, the verifier uses the scenarios as a manual acceptance checklist and states what remains unverified. Changes to agent guidance or controls require relevant agent exercises as well as applicable deterministic checks; passing scripts alone do not establish agent behavior.

When the required verification passes and findings are resolved, the agent records the verified result and passes the change and evidence to Deploy for delivery review. Verification does not itself authorize delivery or establish runtime health.

## Affected users and systems

Agents building and independently verifying changes, owners resolving contract findings, and people reviewing delivery. Balka's process guidance and project repositories holding the change and verification evidence are affected.

## Constraints

Keep verification within the accepted intent, spec, and implementation plan. Preserve acceptance scenarios and their expected-result assertions; do not change them to make the implementation pass. Report failed, blocked, and unrun checks without claiming success. Keep one authoritative verification result for the reviewed revision, and reverify affected checks after further changes.

Keep the process independent of the app, model, or harness. Verification setup, enforcement mechanisms, and Balka's own evaluation suite remain separate work in the [todo list](../todo.md). Defining the BDD contract belongs to Design; release authority and landing procedures belong to Deploy.

## Open questions

None.

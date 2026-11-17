# Intent: AI SDLC Maintain — observe, diagnose, and feed findings back into the loop

Author: Codex. Date: 2026-11-17.

## Problem

Balka's [AI SDLC loop](../002-ai-sdlc-loop/intent.md) ends with Maintain feeding new work into Plan, but provides no guidance for that stage. Agents need to investigate observed deterioration, security findings, and reported incidents without treating diagnosis as permission to change the system or treating passing CI as evidence of runtime health.

## Proposed outcome

Balka provides the Maintain process from [The AI-native SDLC playbook](https://claude.com/resources/articles/the-ai-native-sdlc-playbook): deterministic detection against rolling baselines; configured response tiers for logging, diagnosis, and gated action; recurring security scans with validated findings, confidence, and reasoned dismissals; and incident response that preserves the investigation, human authorization, recovery observations, and lessons. Triggers invoke agents without a person starting each investigation. Findings return through review, and released fixes add regression evaluations.

Maintain starts from [Deploy's delivery evidence](../007-ai-sdlc-deploy/intent.md), relevant project knowledge, the accepted behavior, and current observations. Each project names the service owner and responder, defines which systems and revisions are observed, and supplies its signals, observation windows, response authority, and recovery procedures. Evidence states whether it concerns runtime behavior, delivery, CI, or the development process. Missing or stale observations leave the affected health claim unverified.

Detection rules and response permissions are versioned; detection rules are tested against expected breaches and normal observations. An agent cannot promote its own response tier. Diagnosis reads the available evidence, tests hypotheses within its authority, and separates observations from suspected causes. It preserves unrelated work and records missing access or evidence. Repeated alerts update the existing finding; failed investigations remain visible to the responsible responder.

Scheduled scans define repository scope, revision, cadence, and responsible reviewer. Their records preserve validation, confidence, dispositions, and the date of coverage. Scans complement existing deterministic checks. Dismissals retain their reasons so later runs can distinguish known findings from new evidence.

Incident response can begin from an alert or a reported problem. The agent preserves the request, investigation, decisions, and actions together so responders can continue it. An operational recovery uses only the project's previously authorized procedure and environment authority. Recovery is confirmed against fresh observations and the project's success criteria; an attempted action alone does not establish recovery. Unresolved incidents pass to the named responder with the evidence and remaining work.

New change proposals become draft `intent.md` files under the [Plan process](../003-ai-sdlc-plan/intent.md), linking the finding and evidence. The responsible person triages them for action, scheduling, or dismissal and routes product decisions to the owner. Independent checks or review assess whether outputs are ready to continue or need escalation. Balka's explicit acceptance of intent, design, and implementation plan still applies, including for a small fix. Existing authorized recovery does not accept a new change.

The maintenance record links observations, diagnosis, triage, recovery, resulting changes, and versioned lessons. It supports checking response time, actionable findings, scan coverage, and recurrence without duplicating authoritative records. Incident-derived regression work passes into the change's Design and Test work; Maintain does not rewrite the accepted behavior contract.

## Affected users and systems

Agents investigating findings, service owners and responders handling incidents, and owners accepting resulting changes. Balka's process guidance, observed systems, repositories, maintenance evidence, and project knowledge are affected.

## Constraints

Keep the process independent of the app, model, or harness. Define responsibilities and authority without choosing monitoring, scanning, communication, or execution providers. Additional methods and integrations remain separate work.

Response boundaries must be enforced at the action boundary under Deploy's approval requirements. An alert, confidence score, or incident urgency does not grant additional authority. Keep diagnostic access scoped and distinguish a proposed fix, verified implementation, delivery, and observed recovery.

Stage guidance and operations, project knowledge, portable controls, and continuous evaluations remain separate work in the [todo list](../todo.md). This intent defines Maintain's responsibilities without implementing those capabilities.

## Open questions

None.

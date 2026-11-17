# Intent: AI SDLC Deploy — review, authorize, and deliver changes through CI/CD

Author: Codex. Date: 2026-11-17.

## Problem

Balka's [AI SDLC loop](../002-ai-sdlc-loop/intent.md) puts Deploy after Test, but provides no guidance for that stage. A verified change still needs delivery review, resolution of findings, release authorization, and a working route into use. Agents need to participate in CI/CD without bypassing the project's approval boundaries or treating passing checks as evidence of a successful rollout.

## Proposed outcome

Balka provides the Deploy process described in [The AI-native SDLC playbook](https://claude.com/resources/articles/the-ai-native-sdlc-playbook): AI in the review loop, enforced approval gates, and agent work inside CI/CD. The agent starts from the accepted change artifacts, relevant project knowledge and review policy, the actual revision, and [Test's verification evidence](../006-ai-sdlc-test/intent.md).

Agents both review changes and address review comments. Review follows the project's written policy, covering correctness, security, agreement with the spec and implementation plan, and applicable design principles. Findings identify the affected code and risk, distinguish blocking issues from minor suggestions, and avoid repeating checks already enforced by the pipeline. Human reviewers judge the intended behavior and acceptable risk; the implementing agent cannot approve its own change.

Each finding receives a fix or a reasoned disposition under the project's review policy. Implementation findings return to Build and then Test, followed by review of the corrections. Findings that change the accepted behavior return to the owner and Design; changes to the intent return to Plan. Agents continue corrections within the accepted scope until the change is ready for the required human decision. Recurring mistakes and outdated guidance found in review are corrected in the relevant project knowledge, so subsequent work and reviews use the correction.

CI/CD can run agents non-interactively for work requiring judgment, alongside deterministic build, test, and delivery steps. Adoption starts with read-only tasks such as diagnosing a failed build, assessing a flaky test, or preparing release notes. Write operations, including fixes and responses to review comments, follow the project's review and approval gates. Agent jobs run in isolated environments with scoped, short-lived credentials and no standing production access. Deployment, status, and rollback operations are scoped to the target environment.

The project defines the actions agents may take in each environment and the human approvals required before release. Required gates are enforced at the action boundary and cannot be bypassed by the agent performing the work. They identify the authorized approver, what approval covers, and why an action is blocked. In development an agent may deploy within the project's standing authorization; production requires authorization from the named release authority. Acceptance of the implementation plan or a passing review does not substitute for release authorization.

The agent prepares the project's delivery procedure for the reviewed revision: destination, prerequisites, order of changes, required approvals, success checks, and rollback or recovery limits. It carries out authorized operations or hands over the remaining procedure at its authority boundary. Rollback is exercised in a suitable non-production environment before it is relied on; reverting code is not assumed to reverse data changes.

The delivery record links the reviewed and delivered revisions, findings and their dispositions, approvals, pipeline runs, deployment results, and recovery actions. It distinguishes a verified change, release readiness, actual delivery, and observed behavior in the target environment. A failed or unobserved rollout is reported as such. The delivered revision, initial observations, recovery procedure, and outstanding concerns pass to Maintain for ongoing observation and feedback into the loop.

## Affected users and systems

Agents reviewing changes and working in CI/CD, owners and release authorities making approval decisions, and people operating the delivered system. Balka's process guidance, project repositories, delivery pipelines, deployment targets, and delivery evidence are affected.

## Constraints

Keep the process independent of the app, model, or harness. Projects supply their delivery procedures, review policies, and environment authority. This intent defines what agents must do and what controls must guarantee; it does not choose a review provider, CI platform, deployment integration, or enforcement implementation.

Preserve the accepted contract and keep review, verification, and release evidence tied to the relevant revision. Further changes require affected verification and review again. Agent execution success is not itself review approval, release authorization, or evidence of runtime health. Unresolved blocking findings and missing required approvals prevent delivery. Agents do not broaden their authority when delivery fails.

Stage guidance and operations, project knowledge, and implementation of portable controls remain separate work in the [todo list](../todo.md). Continuous evaluations belong to Test, and ongoing monitoring and incident feedback belong to Maintain.

## Open questions

None.

# Reusable project knowledge in Balka

Draft for Nikita Furletov. 12 November 2026.

## Recommendation

Make maintaining discoverable, current project knowledge part of Balka's existing change lifecycle. Progressive disclosure governs how agents find that knowledge; the SDLC loop governs when it changes and how it is checked.

The outcome is that a new agent can work from the repository's maintained knowledge without reconstructing the project from closed change directories or earlier conversations.

## What exists today

Inspection of `/home/meteof/Projects/balka`, version 0.6.2:

- The facts document records real names, estate facts, and how changes land. Every stage reads it.
- Intent, spec, and plan describe an individual change. They link upstream and retain their history in Git.
- Build implements an accepted plan and runs checks. Test compares the spec, scenarios, bindings, implementation, and planned files.
- Reflect routes recurring process corrections through the proposals inbox.
- Init supplies a short agent entry block and merges it with the project's existing instructions.

The missing connection is an explicit obligation to reconcile reusable project documentation with the implementation, then check that reconciliation before declaring the change built. The facts document provides a useful foundation, but should stay small rather than become an encyclopedia.

## Proposed rules

1. **Discover before loading.** Start with the repository's entry instructions and a compact view of its knowledge structure. Open only relevant documents and sections, alongside the current change's required artefacts. Other change directories and historical records are consulted when the task requires them. Directory discovery must work with an available tool; the external `tree` executable is not a prerequisite.

2. **Separate current knowledge from change history.** Current architecture, concepts, interfaces, and working procedures have stable homes. Intent, spec, plan, experiment results, and incident records explain changes and history. An accepted proposal does not automatically replace the description of the working system. Do not move or rename existing artefacts merely to adopt the convention.

3. **Give each reusable concern a canonical home.** Prefer descriptive filenames and one concern per document. Edit an existing authoritative document before creating another account of the same subject. Point to code, configuration, executable specs, and scripts instead of copying their contents. Preserve the repository's established reference conventions.

4. **State what the evidence establishes.** Distinguish intended behavior, behavior supported by the implementation and its checks, and behavior observed in a running environment. A passing test or merged configuration does not establish that production has been updated. Record the environment and observation date when a runtime claim needs them.

5. **Plan and implement documentation together.** Assess which durable documents the change affects during planning. Include their paths in the existing file list. Update them with the implementation, incorporating justified discoveries and correcting obsolete instructions. If the change leaves the documented contract and procedures accurate, say why no documentation update is needed.

6. **Check knowledge before completing the change.** Test checks whether the relevant documents are discoverable, agree with the implementation and accepted contract, and point to usable sources and commands. A documentation mismatch returns to Build. A mismatch requiring a changed requirement or scenario returns through the existing design transition. Do not manufacture a separate review report or a second approval gate.

7. **Preserve corrections where the next agent will find them.** Fix erroneous project guidance as part of the change. Retain reusable explanations, constraints, and procedures when they affect future decisions. Avoid copying a task transcript, a temporary workaround, or every implementation detail into the knowledge base. Process-wide proposals continue through Reflect.

8. **Keep adoption incremental.** Respect the project's existing documentation layout, tools, and ownership. Init supplies missing entry points and a small writing policy without overwriting maintained content. Existing repositories can adopt the rules through ordinary reruns and relevant future changes; no bulk rewrite is required.

These are obligations on the workflow. They do not imply a particular folder taxonomy, a database, a ban on skills, or a fixed token budget.

## Where the rules fit

| Existing point | Proposed addition |
|---|---|
| Init | Discover the existing knowledge layout; add concise navigation and a documentation-writing policy where needed. Preserve collisions for explicit resolution. |
| Intent | Read relevant current knowledge to establish the problem. Express the desired change as a proposal. |
| Spec | Link relevant current contracts and constraints. Put new requirements in the change's design. |
| Plan | Identify documentation impact in the existing approach and file list, or explain why the existing documentation remains correct. |
| Build | Reconcile the affected durable documents as the implementation is completed. Preserve the distinctions between intended, implemented, and observed state. |
| Test | Add documentation-to-implementation consistency and navigation to the existing verifier's checks. Route findings through the existing fix-or-stop behavior. |
| Deploy | Carry the documentation with the implementation in the same reviewed change. Make deployment claims only from actual landing evidence. |
| Reflect | Examine recurring discovery failures, duplicate or conflicting guidance, and missing reusable knowledge. Route fixes to the project or plugin as today. |

No seventh stage is needed. The same lifecycle is used for documentation-only changes.

## Proposed first implementation

The first release should express this contract in the existing stage commands, starter agent block, artifact-writing skill, and review policy. Supply one concise documentation-writing template and document adoption in the README. Share the policy by reference rather than reproducing all its rules in every command.

Keep the existing distinction between code requirements and workflow guidance. The accepted scenarios and their assertions retain their authority; documentation maintenance does not authorize rewriting them during Build.

A richer tree/outline helper can be added when discovery needs it. It should expose information from the filesystem and headings, rather than introduce a second hand-maintained inventory.

Mechanical checks can catch broken references, missing files, or invalid generated output. They cannot establish that prose is true merely because a timestamp or a checklist is present. Start with the existing verifier for semantic consistency; introduce further automation only for demonstrated failures it can reliably detect.

## Cases the design must handle

- A new capability changes documented behavior: implementation, executable checks, and the canonical behavior document arrive together.
- A bug fix restores an already documented contract: the existing document can remain unchanged, with a specific explanation in the plan.
- Deployment configuration changes without a live rollout: the document accurately describes the configuration and does not claim a production rollout occurred.
- A historical RFC contradicts the current architecture: routine discovery leads to the current account; history remains available for investigations.
- A rule exists in several files and differs between them: the change establishes one authoritative account and updates relevant pointers.
- A fresh agent starts a relevant task: entry instructions lead to the required documents and verification commands without reading the entire archive.

## Scope

This proposal concerns the public Balka plugin and the contract it installs in adopting repositories. It does not change sibling repositories, Personal OS data, installed plugin caches, or the current release.

The research supplies examples and counterexamples, not proof that one packaging strategy always wins. The strongest transferable ideas are selective discovery, authoritative current knowledge, executable evidence, and improvement from real failed sessions.

Related intent: `intent.md` gives the same capability as a short draft intent for the next SDLC transition.

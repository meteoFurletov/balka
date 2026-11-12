# Owner: Nikita Furletov. From: docs/balka/001-documentation-lifecycle/spec.md R1–R4.
# Scenarios are the contract. They change at the design transition.
# No runner: the verifier uses these scenarios as a manual acceptance checklist.

Feature: Discover readable project documentation

  Scenario: Establish documentation where none exists
    Given a repository has no current project documentation
    When the agent runs Balka init
    Then the entry instructions identify the documentation home
    And the overview explains the project's purpose
    And the overview explains how the major parts fit together
    And the overview points to working procedures
    And unsupported details are identified as unknown

  Scenario: Reuse established documentation
    Given a repository has a maintained handbook and overview
    When the agent runs Balka init
    Then the entry instructions point to that handbook and overview
    And the maintained documents keep their paths and contents
    And no competing overview is created

  Scenario: Report a setup collision before writing
    Given a setup edit would change maintained instructions
    When the agent runs Balka init
    Then the agent reports the file and conflicting lines
    And no setup changes are written
    And the proposed resolution preserves the file's history

  Scenario: Repeat setup without duplicating documentation
    Given Balka init has established the documentation pointers
    And the owner has added project knowledge to the overview
    When the agent runs Balka init again
    Then the selected documentation paths remain the same
    And the owner's additions remain unchanged
    And the documentation pointers appear once

  Scenario: Load the documents relevant to a task
    Given the documentation covers authentication and billing
    When the agent starts an authentication task
    Then the agent discovers relevant filenames before reading their contents
    And the agent reads the authentication guidance
    And the billing documents are not loaded without a task-related reason

  Scenario: Read relevant sections of a large document
    Given the relevant architecture document has several sections
    When the agent investigates authentication
    Then the agent inspects headings before choosing sections
    And the agent reads the sections needed for authentication
    And discovery works without the tree executable

  Scenario: Distinguish a historical proposal from current guidance
    Given a historical proposal describes an abandoned architecture
    And current guidance describes the implemented architecture
    When the agent investigates the current architecture
    Then the entry instructions lead to the current guidance
    And the historical proposal is distinguishable as a proposal

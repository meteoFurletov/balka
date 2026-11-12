# Owner: Nikita Furletov. From: docs/balka/001-documentation-lifecycle/spec.md R4–R9.
# Scenarios are the contract. They change at the design transition.
# No runner: the verifier uses these scenarios as a manual acceptance checklist.

Feature: Keep project documentation consistent through a change

  Scenario: Update documentation with changed behavior
    Given an accepted spec changes documented behavior
    When the agent completes the change
    Then the plan identifies the affected documentation paths
    And the implementation and current guidance describe the accepted behavior
    And the verifier has checked the updated guidance

  Scenario: Explain why documentation remains unchanged
    Given a bug fix restores the documented contract
    When the agent plans the fix
    Then the plan explains why the current guidance remains accurate

  Scenario: Preserve a useful discovery in its authoritative home
    Given the agent verifies a constraint that affects future changes
    And a current architecture document covers that concern
    When the agent documents the constraint
    Then the architecture document records the constraint and its reason
    And the document points to the supporting evidence
    And no competing account is created

  Scenario: Resolve contradictory inherited guidance
    Given two relevant documents recommend opposite procedures
    And both documents have current metadata
    When the verifier checks the change
    Then the verifier reports the contradiction
    And the contradiction is resolved against the contract and implementation evidence
    And the change remains unbuilt until the relevant findings are resolved

  Scenario Outline: Correct documentation findings before completion
    Given relevant guidance has a <problem>
    When the verifier checks the change
    Then the finding returns to Build
    And the agent corrects the guidance
    And the verifier checks the correction before the change becomes built

    Examples:
      | problem                     |
      | missing explanation         |
      | broken discovery reference  |
      | obsolete working procedure  |

  Scenario: Return a contract disagreement to Design
    Given resolving a documentation finding requires changing an accepted requirement
    When the verifier reports the finding
    Then the loop stops for the owner and the design transition
    And Build does not rewrite the accepted contract

  Scenario: Distinguish implementation from a live rollout
    Given a change updates deployment configuration
    And no observation establishes a production rollout
    When the agent updates the current guidance
    Then the guidance describes the configuration change
    And the production rollout remains explicitly unverified

  Scenario: Keep unrelated documentation debt outside the change
    Given the affected guidance agrees with the contract and implementation
    And an unrelated document is stale
    When the verifier checks the change
    Then the stale document does not require a repository-wide audit
    And completion depends on resolving findings within the affected knowledge

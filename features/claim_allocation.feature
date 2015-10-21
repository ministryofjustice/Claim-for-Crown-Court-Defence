Feature: Claim allocation
  Background:
    As a case worker admin I would like to allocate claims to case workers

    Given I am a signed in case worker admin
      And 2 case workers exist
      And 10 submitted claims exist

  Scenario: Allocate claims to case worker
     When I visit the allocation page
      And I select claims
      And I select a case worker
      And I click Allocate
     Then the claims should be allocated to the case worker
      And the allocated claims should no longer be displayed
      And I should see a notification of the claims that were allocated

  Scenario: Allocate by specifying quantity
    When I visit the allocation page
     And I enter 5 in the quantity text field
     And I select a case worker
     And I click Allocate
    Then the first 5 claims in the list should be allocated to the case worker
     And the first 5 claims should no longer be displayed

  Scenario: Show high value claims
    Given high value claims exist
    When I visit the allocation page
     And I click "high-value"
    Then I should only see high value claims
     And I click "all claims"
    Then I should see all claims

  Scenario: Show low value claims
    Given low value claims exist
     And high value claims exist
    When I visit the allocation page
     And I click "low-value"
    Then I should only see low value claims
     And I click "all claims"
    Then I should see all claims

  Scenario Outline: Filtering claims
      And There are case types in place
    Given there are <quantity> "<type>" claims
     When I visit the allocation page
      And I filter by "<type>"
     Then I should only see <quantity> "<type>" claims after filtering

    Examples:
      | type                     | quantity  |
      | all                      | 10        |
      | fixed_fee                | 10        |
      | cracked                  | 10        |
      | trial                    | 10        |
      | guilty_plea              | 10        |
      | redetermination          | 10        |
      | awaiting_written_reasons | 10        |

  Scenario: Filter then allocate
    Given There are case types in place
      And there are 2 "cracked" claims
      And there are 2 "fixed_fee" claims
      And I visit the allocation page
      And I filter by "fixed_fee"
      And I should only see 2 "fixed_fee" claims after filtering
    When I enter 1 in the quantity text field
      And I select a case worker
      And I click Allocate
    Then the first 1 claims in the list should be allocated to the case worker
      And the first 1 claims should no longer be displayed


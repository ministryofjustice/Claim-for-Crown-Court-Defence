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
      And I should see a summary of the claims that were allocated

  Scenario: Allocate by specifying quantity
    When I visit the allocation page
     And I enter 5 in the quantity text field
     And I select a case worker
     And I click Allocate
    Then the first 5 claims in the list should be allocated to the case worker
     And the first 5 claims should no longer be displayed

  Scenario Outline: Filtering claims
    Given there are <quantity> "<type>" claims
     When I visit the allocation page
      And I filter by "<type>"
     Then I should only see <quantity> "<type>" claims after filtering

    Examples:
      | type        | quantity  |
      | all         | 10        |
      | fixed_fee   | 10        |
      | cracked     | 10        |
      | trial       | 10        |
      | guilty_plea | 10        |

  @focus @javascript @webmock_allow_net_connect @failing-environment-specific
  Scenario: Select all rows
    When I visit the allocation page
     And I click "Select all"
    Then all the claims should be selected

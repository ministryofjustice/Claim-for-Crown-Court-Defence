Feature: Claim allocation
  Background:
    As a case worker admin I would like to allocate claims to case workers

    Given I am a signed in case worker admin
      And case worker "John Smith" exists
      And submitted claims exist with case numbers "T00000001, T00000002, T00000003, T00000004, T00000005"

  Scenario: Allocate claims to case worker John Smith
     When I visit the allocation page
      And I select claims "T00000001, T00000002"
      And I select case worker "John Smith"
      And I click Allocate
     Then claims "T00000001, T00000002" should be allocated to case worker "John Smith"
      And claims "T00000001, T00000002" should no longer be displayed
      And I should see a notification 2 claims were allocated to "John Smith"

  Scenario: Allocate by specifying quantity
    When I visit the allocation page
     And I enter 4 in the quantity text field
     And I select case worker "John Smith"
     And I click Allocate
    Then claims "T00000001, T00000002, T00000003, T00000004" should be allocated to case worker "John Smith"
     And claims "T00000001, T00000002, T00000003, T00000004" should no longer be displayed

  Scenario Outline: Filtering claims
     Given There are case types in place
       And there are <quantity> "<type>" claims
     When I visit the allocation page
      And I filter by "<type>"
     Then I should only see <quantity> "<type>" claims after filtering
      And the claim count should show <quantity>

    Examples:
      | type                     | quantity  |
      | all                      | 5         |
      | fixed_fee                | 2         |
      | cracked                  | 2         |
      | trial                    | 2         |
      | guilty_plea              | 2         |
      | redetermination          | 2         |
      | awaiting_written_reasons | 2         |

  Scenario Outline: Filtering by fixed_fee, cracked, trial, guilty_plea should not show redetermination or awaiting_written_reason claims
    Given There are case types in place
      And there are <quantity> "<type>" claims
      And there are 2 "redetermination" claims
      And there are 2 "awaiting_written_reasons" claims
     When I visit the allocation page
      And I filter by "<type>"
     Then I should only see <quantity> "<type>" claims after filtering
      And the claim count should show <quantity>
      And I should not see any redetermination or awaiting_written_reasons claims

    Examples:
      | type          | quantity |
      | fixed_fee     | 2        |
      | cracked       | 2        |
      | trial         | 2        |
      | guilty_plea   | 2        |

  Scenario: Filter then allocate
    Given There are case types in place
      And there are 2 "cracked" claims
      And there are 2 "fixed_fee" claims
      And I visit the allocation page
      And I filter by "fixed_fee"
      And I should only see 2 "fixed_fee" claims after filtering
      And the claim count should show 2
     When I enter 1 in the quantity text field
      And I select case worker "John Smith"
      And I click Allocate
     Then the first 1 claims in the list should be allocated to the case worker
      And the first 1 claims should no longer be displayed


@javascript @webmock_allow_localhost_connect
  Scenario: Case worker admin user decides to click on the row select claims to allocate
    When I visit the allocation page
     And I click on a claim row cell
    Then I should see that claims checkbox ticked
     And I click on a claim row cell
    Then I should see that claims checkbox unticked
    When I click on a claims row cell
    Then I should see that claims checkbox ticked
    When I click on a claims row cell
    Then I should see that claims checkbox unticked

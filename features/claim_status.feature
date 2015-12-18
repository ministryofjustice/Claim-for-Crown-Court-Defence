Feature: Claim status
  Background:
    As a case worker I need be able to update the state of a claim
    As an advocate I need to be able to view the updated status of my claims
    including visual indicators for certain states

Scenario Outline: Update claim status
    Given I am a signed in case worker
      And claims have been assigned to me
     When I visit my dashboard
      And I view status details for a claim
      And I select status <status> from select
      And I enter fees assessed of <fees> and expenses assessed of <expenses>
      And I press update button
     Then I should be able to update the status from <status>

   Examples:
      | status             | fees     | expenses | total     |
      | "Part authorised"  | "100.01" | "20.33"  | "£120.34" |
      | "Authorised"       | "200.01" | ""       | "£200.01" |
      | "Refused"          | ""       | ""       | ""        |

Scenario: Update claim status to rejected
    Given I am a signed in case worker
      And claims have been assigned to me
     When I visit my dashboard
      And I view status details for a claim
      And I select status "Rejected" from select
      And I press update button
     Then I should not see status select
      And I should see the current status set to "Rejected"



Scenario Outline: Update claim status without amount assessed raises state transition error
    Given I am a signed in case worker
      And claims have been assigned to me
     When I visit my dashboard
      And I view status details for a claim
      And I select status "<status>" from select
      And I press update button
     Then I should see error "Amount assessed cannot be zero for claims in state <status>"
      And I should not see "Cannot transition state via"

    Examples:
      | status           |
      | Part authorised  |
      | Authorised       |

Scenario Outline: View claim status
    Given I am a signed in advocate
      And I have 3 allocated claims whos status is <status> with fees assessed of <fees> and expenses assessed of <expenses>
     When I visit the advocates dashboard
      And I view status details of my first claim
     Then I should not see status select
      And I should see the current status set to <status>
      And I should see "disabled" total excluding vat assessed value of <total_exc_vat>
      And I should see "disabled" total vat assessed value of  <vat>
      And I should see "disabled" total including vat assessed value of <total_inc_vat>


   Examples:
      | status              | fees     |  expenses   | total_exc_vat | vat      | total_inc_vat |
      | "Part authorised"   | "60.01"  |  "40.00"    | "£100.01"     | "£17.50" | "£117.51"     |
      | "Rejected"          | ""       |  ""         | ""            | ""       | ""            |

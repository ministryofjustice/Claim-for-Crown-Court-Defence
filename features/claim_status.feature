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
      And I enter amount assessed value of <amount>
      And I enter remark <remark>
      And I press update button
     Then I should see "enabled" status select with <status> selected
      And I should see "enabled" amount assessed value of <amount>
      And I should see "enabled" remark <remark>

   Examples:
      | status      		| amount 	 | remark 						   |
      | "Part paid"  		| "100.01" | "Part paid remark" 	 |
      | "Paid in full"  | "200.01" | "Paid in full remark" |
      | "Refused" 	 		| ""     	 | "Refused remark"      |
      | "Rejected"  		| "" 		 	 | "Rejected remark" 	   |
      | "Awaiting info from court"      | ""       | "Awaiting info from Court remark" |

Scenario Outline: View claim status
    Given I am a signed in advocate
      And I have 3 allocated claims whos status is <status> with amount assessed of <amount> and remark of <remark>
     When I visit the advocates dashboard
      And I view status details of my first claim
     Then I should see "disabled" status select with <status> selected
      And I should see "disabled" amount assessed value of <amount>
      And I should see "disabled" remark <remark>

   Examples:
      | status          | amount   | remark                |
      | "Part paid"     | "100.01" | "Part paid remark"    |
      | "Rejected"      | ""       | "Rejected remark"     |
      | "Awaiting info from court"      | ""       | "Awaiting info from Court remark"     |

Scenario: View claim status visual indicators
   Given I am a signed in advocate
     And I have 1 allocated claims whos status is "Awaiting info from court" with amount assessed of "" and remark of "Awaiting info from court remark"
    When I visit the advocates dashboard
     And I should see an image tag with source "awaiting-info-from-court.png" against that claim

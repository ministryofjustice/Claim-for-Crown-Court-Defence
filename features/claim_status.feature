Feature: Claim status
  Background:
    As a case worker I need be able to update the state of a claim
    As an advocate I need to be able to view the updated status of my claims
    including visual indicators for certain states


Scenario Outline: Update claim status
    Given I am a signed in case worker
      And There are fee schemes in place
      And claims have been assigned to me
     When I visit my dashboard
      And I view status details for a claim
      And I select status <status> from select
      And I enter fees assessed of <fees> and expenses assessed of <expenses>
      And I press update button
     Then I should see "enabled" status select with <status> selected
      And I should see "enabled" total assessed value of <total>

   Examples:
      | status      		                | fees 	   | expenses | total     |
      | "Part authorised"  		          | "100.01" | "20.33"  | "£120.34" |
      | "Authorised"                    | "200.01" | ""       | "£200.01" |
      | "Refused" 	 		                | ""     	 | ""       | ""        |
      | "Rejected"  		                | "" 		 	 | ""       | ""        |

Scenario Outline: View claim status
    Given I am a signed in advocate
      And There are fee schemes in place
      And I have 3 allocated claims whos status is <status> with fees assessed of <fees> and expenses assessed of <expenses>
     When I visit the advocates dashboard
      And I view status details of my first claim
     Then I should see "disabled" status select with <status> selected
      And I should see "disabled" total assessed value of <total>

   Examples:
      | status              | fees     |  expenses   | total      |
      | "Part authorised"   | "60.01"  |  "40.00"    | "£100.01"  |
      | "Rejected"          | ""       |  ""         | ""         |

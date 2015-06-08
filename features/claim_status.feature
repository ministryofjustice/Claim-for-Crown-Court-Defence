Feature: Claim status
  Background:
    As a case worker I need be able to update the state of a claim
    As an advocate I need to be able to view the updated status of my claims

Scenario Outline: Update claim status
    Given I am a signed in case worker
      And claims have been assigned to me
     When I visit my dashboard
      And I view status details for a claim
      And I select status radio button label <radio_label>
      And I enter amount assessed value of <amount>
      And I enter remark <remark>
      And I press update button
     Then I should see enabled status radio button <radio_label> chosen
      And I should see remark <remark>

   Examples:
      | radio_label 		| amount 	 | remark 						   |
      | "Part paid"  		| "100.01" | "Part paid remark" 	 |
      | "Paid in full"  | "200.01" | "Paid in full remark" |
      | "Refused" 	 		| ""     	 | "Refused remark"      |
      | "Rejected"  		| "" 		 	 | "Rejected remark" 	   |

@stub_s3_upload

Feature: Advocate claims
  Scenario: Fill in claim form
    Given I am a signed in advocate
      And I am on the new claim page
     When I fill in the claim details
      And I submit the form
     Then I should be redirected to the claim summary page
      And I should see the claim total

  Scenario: Claim summary page
    Given I am on the claim summary page
     When I submit the form
     Then I should be on the claim confirmation page
      And the claim should be submitted

  Scenario: Return to claim form and re-submit
    Given I am on the claim summary page
     When I click the back button
     Then I should be on the claim edit form
     When I submit the form
     Then I should be on the claim summary page

  Scenario: Edit existing claim
    Given I am a signed in advocate
      And a claim exists with state "draft"
     When I am on the claim edit page
      And I submit the form
     Then I should be on the claim summary page
      And the claim should be in state "draft"
     When I submit the form
     Then the claim should be in state "submitted"
      And I should be on the claim confirmation page

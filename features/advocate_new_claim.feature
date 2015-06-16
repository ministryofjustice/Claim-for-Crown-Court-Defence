@stub_s3_upload

Feature: Advocate new claim
  Scenario: Fill in claim form
    Given I am a signed in advocate
      And I am on the new claim page
     When I fill in the claim details
      And I submit the form
     Then I should be redirected to the claim summary page
      And I should see the claim totals

  Scenario: Change offence class
    Given I am a signed in advocate
      And I am on the new claim page
     When I select offence class "A: Homicide and related grave offences"
     Then the Offence category does NOT contain "Activities relating to opium"
     Then the Offence category does contain "Murder"

  Scenario: Claim summary page
    Given I am on the claim summary page
     When I submit the form
     Then I should be on the claim confirmation page
      And the claim should be submitted

  @wip
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

  Scenario: Admin specifies advocate name
    Given I am a signed in advocate admin
      And There are other advocates in my chamber
      And I am on the new claim page
     Then I can view a select of all advocates in my chamber
     When I select Advocate name "Doe, John: AC135"
      And I fill in the claim details
      And I submit the form
     Then I should be redirected to the claim summary page
      And I should see the claim totals

  Scenario: Admin fails to specify advocate name
    Given I am a signed in advocate admin
      And There are basic and non-basic fee types
      And I am on the new claim page
      And I fill in the claim details
      And I submit the form
     Then I should be redirected back to the claim form with error
